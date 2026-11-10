#!/usr/bin/env python3
"""Check the bounded NMI handler and rendering-disabled controller experiment."""
import argparse
import hashlib
import importlib.util
import json
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
# This record stays on Emu198x 0.45.1: from 0.46.1 the frame phase after
# power-on moves by one frame (emu198x#2349). Re-record on the newest release
# once that issue closes.
EMULATOR_PIN = {'release': '0.45.1', 'issue': 'emu198x#2349',
                'reason': 'from 0.46.1 the frame phase after power-on moves by one frame'}
# The checked-in ROMs the machine runs, by unit, and the exercise built here.
UNITS = [('09', 'heartbeat'), ('10', 'read-pad')]


def slow_source():
    """Unit 09 with the five-shift exercise applied; the sample is never replaced."""
    return (ROOT / 'unit-09/heartbeat.asm').read_text().replace(
        '    lda COUNTER\n', '    lda COUNTER\n' + '    lsr a\n' * 5)


def build_programs(assembler, output):
    """Build each program the machine runs into output, without the emulator.

    The units are built by their own Makefiles, into output rather than over
    the checked-in ROMs.
    """
    out = Path(output).resolve()
    for unit, name in UNITS:
        (out / f'unit-{unit}').mkdir(parents=True, exist_ok=True)
        subprocess.run(['make', '-s', '-B', '-C', str(ROOT / f'unit-{unit}'), f'ASM={assembler}',
                        f'ROM={out / f"unit-{unit}/{name}.nes"}'], check=True, capture_output=True)
    (out / 'slow.asm').write_text(slow_source())
    subprocess.run([assembler, '--dialect', 'ca65', str(out / 'slow.asm'), '-o', str(out / 'slow.nes')],
                   check=True, capture_output=True)


def evidence_bytes():
    """The shared evidence module, loaded only when recording."""
    found = importlib.util.spec_from_file_location(
        'evidence_bytes', ROOT.parents[2] / 'scripts/evidence_bytes.py')
    value = importlib.util.module_from_spec(found)
    found.loader.exec_module(value)
    return value

class Machine:
    def __init__(self, binary, rom):
        self.process = subprocess.Popen([binary, '--mcp', '--region', 'ntsc', '--rom', str(rom)],
                                        stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        self.sequence = 0
        self.server = self.rpc('initialize', {'protocolVersion':'2025-06-18', 'capabilities':{},
                                            'clientInfo':{'name':'curriculum-timing','version':'1'}})
    def rpc(self, method, params):
        self.sequence += 1
        self.process.stdin.write(json.dumps({'jsonrpc':'2.0','id':self.sequence,'method':method,'params':params})+'\n')
        self.process.stdin.flush()
        while True:
            line = self.process.stdout.readline()
            if not line: raise RuntimeError('Emulator exited')
            response = json.loads(line)
            if response.get('id') == self.sequence:
                if 'error' in response: raise RuntimeError(response)
                return response['result']
    def call(self, name, **args):
        result = self.rpc('tools/call', {'name':name,'arguments':args})
        if result.get('isError'): raise RuntimeError(result)
        return json.loads(result['content'][0]['text'])
    def query(self, path):
        return self.call('query', path=path)['result']['value']
    def close(self):
        self.process.stdin.close()
        self.process.wait(timeout=10)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emulator',required=True)
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--assembler',default='asm198x')
    a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True)
    # The machine runs the checked-in ROMs, so they must be what the assembler builds.
    build_programs(a.assembler, a.output)
    for unit, name in UNITS:
        assert (a.output/f'unit-{unit}/{name}.nes').read_bytes()==(ROOT/f'unit-{unit}/{name}.nes').read_bytes(), name
    results=[]
    for unit,name in UNITS:
        rom=ROOT/f'unit-{unit}/{name}.nes'
        m=Machine(a.emulator,rom)
        try:
            m.call('run_frames',frames=5)
            assert m.query('ppu.mask') == 0
            if unit=='09':
                data=rom.read_bytes()
                nmi=int.from_bytes(data[16+0x7ffa:16+0x7ffc],'little')
                idle=nmi-3
                assert data[16+idle-0x8000:16+nmi-0x8000] == bytes([0x4c,idle&255,idle>>8])
                m.call('run_until_pc',addr=idle,max_steps=100000)
                before={r:m.query('cpu.'+r) for r in ('a','x','y','p','sp')}
                assert before['a']==128, before
                colours=[]
                for _ in range(4):
                    m.call('run_frames',frames=1)
                    m.call('run_until_pc',addr=idle,max_steps=100000)
                    after={r:m.query('cpu.'+r) for r in before}
                    assert after==before,(before,after)
                    colours.append(m.call('dump_palette')['background_palette'].split()[0])
                assert len(set(colours))==4,colours
                assert m.query('ppu.ctrl')==128
                results.append({'unit':unit,'registers_at_idle':before,'successive_palette_entries':colours})
            else:
                assert m.query('ppu.ctrl')==0
                colours=[]
                for held in [False,True,False]:
                    m.call('input',events=[{'Button':{'port':1,'name':'a','pressed':held}}])
                    m.call('run_frames',frames=3)
                    colours.append(m.call('dump_palette')['background_palette'].split()[0])
                assert colours==['16','2A','16'],colours
                results.append({'unit':unit,'released_held_released_palette_entries':colours})
            m.call('save_screenshot',path=str(a.output/f'unit-{unit}.png'))
            results[-1]['source_sha256']=hashlib.sha256((ROOT/f'unit-{unit}/{name}.asm').read_bytes()).hexdigest()
            results[-1]['rom_sha256']=hashlib.sha256(rom.read_bytes()).hexdigest()
            print('PASS',unit,flush=True)
        finally:m.close()
    # The exact five-shift exercise, built by build_programs; never replace the sample.
    slow_rom = a.output/'slow.nes'
    m=Machine(a.emulator,slow_rom)
    try:
        m.call('run_frames',frames=5)
        previous=None; changes=[]
        for frame in range(100):
            m.call('run_frames',frames=1)
            colour=int(m.call('dump_palette')['background_palette'].split()[0],16)
            assert 0<=colour<=7,colour
            if previous is not None and colour!=previous: changes.append(frame)
            previous=colour
        assert len(changes)>=3 and all(b-a==32 for a,b in zip(changes,changes[1:])),changes
        results.append({'exercise':'five shifts','colour_change_frames':changes,
                        'source_sha256':hashlib.sha256(slow_source().encode()).hexdigest()})
        print('PASS five-shift exercise',flush=True)
    finally:m.close()
    (a.output/'results.json').write_text(json.dumps({'status':'passed','configuration':'NES NTSC, rendering disabled',
        'server':m.server,'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),
        'assembler_sha256':hashlib.sha256(Path(shutil.which(a.assembler) or a.assembler).read_bytes()).hexdigest(),
        # Each program the machine runs, so the checker can rebuild it.
        'programs':{**{f'unit-{u}/{n}.nes':hashlib.sha256((ROOT/f'unit-{u}/{n}.nes').read_bytes()).hexdigest() for u,n in UNITS},
                    'slow.nes':hashlib.sha256(slow_rom.read_bytes()).hexdigest()},
        'tools':{'assembler':evidence_bytes().tool_identity(a.assembler),'emulator':evidence_bytes().tool_identity(a.emulator)},
        'emulator_pin':EMULATOR_PIN,
        'checks':results,'limits':'Emulator MCP input/register/palette observations; not native keyboard, original hardware, or proof of a general VBlank budget.'},indent=2)+'\n')

if __name__=='__main__':main()
