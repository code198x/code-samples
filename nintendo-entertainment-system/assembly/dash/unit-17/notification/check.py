#!/usr/bin/env python3
"""Repeat a real NMI read/clear race and check a bounded notification counter."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
UNIT = HERE.parent
BASELINE = 'c167968967e48ee77e54ca540beabe61e7272a9b4c92a7a1ad6528d1b6ed43dc'
spec = importlib.util.spec_from_file_location('intro', UNIT.parents[1] / 'meet-the-machine/verification/timing.py')
intro = importlib.util.module_from_spec(spec)
spec.loader.exec_module(intro)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source(kind, start=0, burst=1, overflow=False):
    s = (UNIT / 'dash.asm').read_text()
    assert sha(UNIT / 'dash.asm') == BASELINE
    definitions = '''
produced = $50
consumed = $51
notification_overflow = $52
notification_clock = $53
notification_armed = $54
notification_flag = $55
notification_done = $56
notification_serviced = $57
notification_stage = $58
'''
    s = s.replace('main_loop:\n', 'main_loop:\n    jmp notification_experiment\n', 1)
    save = 'nmi:\n    pha\n    txa\n    pha\n    tya\n    pha\n'
    assert s.count(save) == 1
    s = s.replace(save, save + '    jsr notification_interrupt\n')
    counter = (HERE / 'counter.asm').read_text()
    # Arrange a real interruption after the successful nonempty check.
    if kind == 'counter' and not overflow:
        counter = counter.replace('    inc consumed\n', '    jsr inject_notification\n    inc consumed\n', 1)
    faulty = '''
    lda notification_flag
    beq notification_failed
    jsr inject_notification
    lda #0
    sta notification_flag
    inc notification_serviced
'''
    correct = '''
    jsr take_one
    bcc notification_failed
    inc notification_serviced
'''
    first = faulty if kind == 'flag' else correct
    # Overflow case deliberately starts with 254 outstanding notifications.
    initial_produced = 254 if overflow else start
    initial_consumed = 0 if overflow else start
    waits = 3 if overflow else burst
    experiment = f'''
notification_experiment:
    lda #{initial_produced}
    sta produced
    lda #{initial_consumed}
    sta consumed
    lda #{waits}
    sta notification_armed
    lda #1
    sta notification_stage
''' + '    jsr wait_notification\n' * waits
    if overflow:
        experiment += '''
    jsr take_one
    bcs notification_failed
    jsr log_notification
'''
    else:
        experiment += '    jsr log_notification\n' + first + '''
    lda #2
    sta notification_stage
    jsr log_notification
'''
        if kind == 'flag':
            experiment += '''
    lda notification_flag
    beq notification_no_second
    inc notification_serviced
notification_no_second:
'''
        else:
            # This second call does not inject: inject_notification gates on stage 1.
            experiment += '''
    jsr take_one
    bcc notification_failed
    inc notification_serviced
'''
        experiment += '''
    lda #3
    sta notification_stage
    jsr log_notification
'''
        if burst == 1 and kind == 'counter':
            experiment += '    jsr take_one\n    bcs notification_failed\n'
    experiment += '''
    lda #1
    sta notification_done
notification_idle:
    jmp notification_idle
notification_failed:
    lda #255
    sta notification_done
    jmp notification_idle

inject_notification:
    lda notification_stage
    cmp #1
    bne @return
    lda #1
    sta notification_armed
    jsr wait_notification
@return:
    rts

wait_notification:
    lda notification_clock
@wait:
    cmp notification_clock
    beq @wait
    rts

notification_interrupt:
    lda notification_armed
    beq @clock
    dec notification_armed
    jsr notify_one
    lda #1
    sta notification_flag
@clock:
    inc notification_clock
    rts

; Three rows, eight bytes each; stage indexes are 1, 2, 3.
log_notification:
    lda notification_stage
    sec
    sbc #1
    asl a
    asl a
    asl a
    tax
    lda produced
    sta $0300,x
    lda consumed
    sta $0301,x
    sec
    lda produced
    sbc consumed
    sta $0302,x
    lda notification_flag
    sta $0303,x
    lda notification_serviced
    sta $0304,x
    lda notification_overflow
    sta $0305,x
    rts
'''
    return definitions + s.replace('.segment "VECTORS"', counter + experiment + '\n.segment "VECTORS"')


def execute(exe, rom):
    data = rom.read_bytes()
    nmi = int.from_bytes(data[16+0x7ffa:16+0x7ffc], 'little')
    m = intro.Machine(str(exe.resolve()), rom)
    measures = []
    try:
        for _ in range(12):
            m.call('run_until_pc', addr=nmi, max_steps=200000)
            state = m.call('memory_read', addr=0x50, len=9)['bytes']
            if state[6]:
                break
            start = m.query('machine.master_clock')
            regs = {r:m.query('cpu.'+r) for r in ('a','x','y','sp')}
            for _ in range(300):
                pc = m.query('cpu.pc')
                opcode = data[16+pc-0x8000]
                m.call('step', instructions=1)
                if opcode == 0x40:
                    break
            else:
                raise AssertionError('NMI did not return')
            after = {r:m.query('cpu.'+r) for r in regs}
            assert after == {**regs, 'sp':(regs['sp']+3)&255}, (regs,after)
            scanline = m.query('ppu.scanline')
            assert 241 <= scanline < 261
            measures.append({'stage':state[8], 'armed':state[4],
                             'cycles_including_dma':(m.query('machine.master_clock')-start)//3,
                             'return_scanline':scanline})
        else:
            raise AssertionError('Fixture timed out')
        assert state[6] == 1, state
        rows = m.call('memory_read', addr=0x300, len=24)['bytes']
        return {'rows':[rows[i:i+6] for i in range(0,24,8)], 'final_state':state,
                'handler_measurements':measures, 'server':m.server}
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emulator', type=Path, required=True)
    p.add_argument('--output', type=Path, required=True)
    a = p.parse_args(); a.output = a.output.resolve(); a.output.mkdir(parents=True, exist_ok=True)
    rebuilt = a.output/'baseline.nes'
    subprocess.run(['asm198x','--dialect','ca65',str(UNIT/'dash.asm'),'-o',str(rebuilt)], check=True)
    assert rebuilt.read_bytes() == (UNIT/'dash.nes').read_bytes()
    cases = [('flag','flag',0,1,False), ('counter','counter',0,1,False),
             ('wrap','counter',254,1,False), ('backlog','counter',0,3,False),
             ('overflow','counter',0,1,True)]
    results = {'source_sha256':BASELINE, 'emulator_sha256':sha(a.emulator),
               'assembler':subprocess.check_output(['asm198x','--version'],text=True).strip(),
               'configuration':'NTSC; real VBlank NMI; instrumented title; no host state injection', 'variants':{}}
    for name,kind,start,burst,overflow in cases:
        src = a.output/f'{name}.asm'; src.write_text(source(kind,start,burst,overflow)); rom = src.with_suffix('.nes')
        subprocess.run(['asm198x','--dialect','ca65',str(src),'-o',str(rom)],check=True)
        result = execute(a.emulator,rom)
        if overflow:
            assert result['rows'][0] == [255,0,255,1,0,1],result
        else:
            row1,row2,row3 = result['rows']
            assert row1 == [(start+burst)&255,start,burst,1,0,0],result
            if kind == 'flag':
                assert row2 == [2,0,2,0,1,0] and row3 == [2,0,2,0,1,0],result
            else:
                assert row2 == [(start+burst+1)&255,(start+1)&255,burst,1,1,0],result
                assert row3 == [(start+burst+1)&255,(start+2)&255,burst-1,1,2,0],result
        last = result['rows'][0 if overflow else 2]
        final = result['final_state']
        assert final[:3] == [last[0], last[1], last[5]], result
        assert final[7] == last[4], result
        assert execute(a.emulator,rom) == result,'Cold repeat differs'
        result.update(source_sha256=sha(src),rom_sha256=sha(rom),cold_repeat_matches=True)
        results['variants'][name] = result
        print('PASS',name,flush=True)
    (a.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')

if __name__ == '__main__':
    main()
