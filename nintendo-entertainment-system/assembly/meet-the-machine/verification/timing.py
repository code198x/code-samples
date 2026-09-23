#!/usr/bin/env python3
"""Check the bounded NMI handler and rendering-disabled controller experiment."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]

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
    results=[]
    for unit,name in [('09','heartbeat'),('10','read-pad')]:
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
    # Build the exact five-shift exercise separately; never replace the sample.
    slow_source = (ROOT/'unit-09/heartbeat.asm').read_text().replace(
        '    lda COUNTER\n', '    lda COUNTER\n' + '    lsr a\n'*5)
    slow_path = a.output/'slow.asm'; slow_path.write_text(slow_source)
    slow_rom = a.output/'slow.nes'
    subprocess.run([a.assembler,'--dialect','ca65',str(slow_path),'-o',str(slow_rom)],check=True)
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
                        'source_sha256':hashlib.sha256(slow_source.encode()).hexdigest()})
        print('PASS five-shift exercise',flush=True)
    finally:m.close()
    (a.output/'results.json').write_text(json.dumps({'status':'passed','configuration':'NES NTSC, rendering disabled',
        'server':m.server,'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),
        'checks':results,'limits':'Emulator MCP input/register/palette observations; not native keyboard, original hardware, or proof of a general VBlank budget.'},indent=2)+'\n')

if __name__=='__main__':main()
