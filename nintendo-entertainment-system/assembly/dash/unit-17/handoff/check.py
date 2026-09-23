#!/usr/bin/env python3
"""Arrange real VBlank interruptions, inspect mailbox and bound NMI work."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

HERE=Path(__file__).resolve().parent
UNIT=HERE.parent
BASELINE='c167968967e48ee77e54ca540beabe61e7272a9b4c92a7a1ad6528d1b6ed43dc'
spec=importlib.util.spec_from_file_location('intro',UNIT.parents[1]/'meet-the-machine/verification/timing.py')
intro=importlib.util.module_from_spec(spec);spec.loader.exec_module(intro)


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def source(broken):
    s=(UNIT/'dash.asm').read_text()
    assert sha(UNIT/'dash.asm')==BASELINE
    definitions='''
request_ready = $50
request_lo = $51
request_hi = $52
handoff_stage = $53
handoff_clock = $54
handoff_count = $55
handoff_deferred = $56
full_lo = $57
full_hi = $58
handoff_done = $59
'''
    s=s.replace('main_loop:\n','main_loop:\n    jmp handoff_experiment\n',1)
    save='nmi:\n    pha\n    txa\n    pha\n    tya\n    pha\n'
    assert s.count(save)==1
    s=s.replace(save,save+'    jsr handoff_observe\n')
    experiment=(HERE/'experiment.asm').read_text()
    publication='    lda #1\n    sta request_ready\n'
    experiment=experiment.replace('; EARLY_PUBLICATION',publication if broken else '')
    experiment=experiment.replace('; LATE_PUBLICATION','' if broken else publication)
    return definitions+s.replace('.segment "VECTORS"', (HERE/'mailbox.asm').read_text()+'\n'+experiment+'\n.segment "VECTORS"')


def execute(exe,rom):
    data=rom.read_bytes()
    nmi=int.from_bytes(data[16+0x7ffa:16+0x7ffc],'little')
    m=intro.Machine(str(exe.resolve()),rom)
    measurements=[]
    try:
        for _ in range(16):
            m.call('run_until_pc',addr=nmi,max_steps=200000)
            state=m.call('memory_read',addr=0x50,len=10)['bytes']
            if state[9]:break
            start=m.query('machine.master_clock')
            registers={r:m.query('cpu.'+r) for r in ('a','x','y','sp')}
            writes=[]
            for _ in range(300):
                pc=m.query('cpu.pc')
                offset=16+pc-0x8000
                opcode=data[offset]
                if opcode==0x8d and int.from_bytes(data[offset+1:offset+3],'little') in (0x4002,0x4003):
                    writes.append([int.from_bytes(data[offset+1:offset+3],'little'),m.query('cpu.a')])
                m.call('step',instructions=1)
                if opcode==0x40:break
            else:raise AssertionError('Handler did not return')
            assert {r:m.query('cpu.'+r) for r in registers}=={**registers,'sp':(registers['sp']+3)&255}
            scanline=m.query('ppu.scanline')
            assert 241<=scanline<261,scanline
            if state[3]:
                measurements.append({'stage':state[3],'ready_at_entry':state[0],
                    'cycles_including_dma':(m.query('machine.master_clock')-start)//3,
                    'return_scanline':scanline,'pulse_period_writes':writes})
        else:raise AssertionError('Experiment did not finish')
        state=m.call('memory_read',addr=0x50,len=10)['bytes']
        mem=m.call('memory_read',addr=0x300,len=24)['bytes']
        rows=[mem[i:i+4] for i in range(0,24,4)]
        assert state[0]==0 and state[5]==6 and state[6]==1 and state[7:9]==[0x52,1] and state[9]==1,state
        return {'nmi_observations_stage_ready_low_high':rows,'final_state':state,
                'handler_measurements':measurements,'server':m.server}
    finally:m.close()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emulator',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
    rebuilt=a.output/'baseline.nes'
    subprocess.run(['asm198x','--dialect','ca65',str(UNIT/'dash.asm'),'-o',str(rebuilt)],check=True)
    assert rebuilt.read_bytes()==(UNIT/'dash.nes').read_bytes()
    results={'source_sha256':BASELINE,'emulator_sha256':sha(a.emulator),
             'configuration':'NTSC; real VBlank NMI in instrumented title fixture; no host state injection', 'variants':{}}
    for name,broken in [('early',True),('complete',False)]:
        src=a.output/f'{name}.asm';src.write_text(source(broken));rom=src.with_suffix('.nes')
        subprocess.run(['asm198x','--dialect','ca65',str(src),'-o',str(rom)],check=True)
        result=execute(a.emulator,rom)
        expected=[[1,0,0x1c,1],[2,int(broken),0xd5,1],[3,int(not broken),0xd5,0],
                  [4,1,0x52,1],[5,1,0x7c,1],[6,0,0x7c,1]]
        assert result['nmi_observations_stage_ready_low_high']==expected,result
        assert len(result['handler_measurements'])==6
        for measured,row in zip(result['handler_measurements'],expected):
            assert measured['pulse_period_writes']==([[0x4002,row[2]],[0x4003,row[3]]] if row[1] else [])
        repeat=execute(a.emulator,rom)
        assert repeat==result,'Cold repeat differs'
        result.update({'source_sha256':sha(src),'rom_sha256':sha(rom),'cold_repeat_matches':True})
        results['variants'][name]=result
        print('PASS',name,'six stages, full/refuse/retry/empty and cold repeat',flush=True)
    (a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')

if __name__=='__main__':main()
