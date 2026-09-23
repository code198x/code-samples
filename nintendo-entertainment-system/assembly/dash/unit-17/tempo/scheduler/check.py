#!/usr/bin/env python3
"""Build isolated Dash tempo variants and compare guest event records."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import struct
import wave

HERE = Path(__file__).resolve().parent
UNIT = HERE.parents[1]
spec = importlib.util.spec_from_file_location('intro', UNIT.parents[1] / 'meet-the-machine/verification/timing.py')
intro = importlib.util.module_from_spec(spec)
spec.loader.exec_module(intro)
BASELINE = 'c167968967e48ee77e54ca540beabe61e7272a9b4c92a7a1ad6528d1b6ed43dc'


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def source(mode):
    s = (UNIT / 'dash.asm').read_text()
    assert sha(UNIT / 'dash.asm') == BASELINE
    # Diagnostic data sits outside game zero page and OAM; reset clears it.
    defines = '''
tempo_phase = $40
tempo_started = $41
tempo_fault = $42
tempo_frame = $43
tempo_frame_hi = $44
tempo_gate = $45
tempo_count = $46
tempo_old_idx = $47
'''
    s = defines + s
    s = s.replace('    jsr tune_tick\n', '    jsr tempo_wrapper\n', 1)
    s = s.replace('    sta tune_timer\n    rts', '    sta tune_timer\n    lda #0\n    sta tempo_phase\n    sta tempo_started\n    sta tempo_fault\n    rts', 1)
    gate = '''    inc tempo_gate
    lda tempo_gate
    cmp #6
    bne @request
    lda #0
    sta tempo_gate
    rts
@request:
''' if mode == 'slow' else ''
    fault = '''    lda tempo_frame_hi
    bne @normal
    lda tempo_frame
    cmp #120
    bne @normal
    lda #30
    bne @service
@normal:
''' if mode == 'overload' else ''
    wrapper = '''
tempo_wrapper:
    inc tempo_frame
    bne @counted
    inc tempo_frame_hi
@counted:
''' + gate + '''    lda tune_idx
    sta tempo_old_idx
''' + fault + f'''    lda #{6 if mode == 'slow' else 5}
@service:
    jsr tempo_service
    lda tune_idx
    cmp tempo_old_idx
    beq @done
    lda tempo_count
    cmp #28
    bcs @done
    asl a
    asl a
    tax
    lda tempo_frame
    sta $0300,x
    lda tempo_frame_hi
    sta $0301,x
    lda tune_idx
    sta $0302,x
    lda tune_timer
    sta $0303,x
    inc tempo_count
@done:
    rts
'''
    return s.replace('.segment "VECTORS"', wrapper + (HERE / 'scheduler.asm').read_text() + '\n.segment "VECTORS"')


def oracle(mode):
    # Event schedule from cumulative phrase durations, independent of guest timer.
    source_text = (UNIT / 'dash.asm').read_text().split('camptown_phrase:', 1)[1].split('fanfare_phrase:', 1)[0]
    durations = []
    for line in source_text.splitlines():
        line = line.split(';')[0].strip()
        if line.startswith('.byte'):
            value = line.split(',')[-1].strip()
            if not value.startswith('$'):
                durations.append(int(value))
    deadlines = [0]
    for duration in durations:
        deadlines.append(deadlines[-1] + duration)
    services = []
    # First service at game opportunity 1, then carry fractional phase forward.
    phase = 0
    for frame in range(1, 400):
        if mode == 'slow' and frame % 6 == 0:
            continue
        if frame == 1:
            services.append(frame)
            continue
        phase += 6 if mode == 'slow' else 5
        if phase >= 6:
            phase -= 6
            services.append(frame)
    return [[services[d], (i % len(durations) + 1)*3, durations[i % len(durations)]]
            for i, d in enumerate(deadlines)]


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emulator', required=True, type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    rebuilt = args.output/'baseline.nes'
    subprocess.run(['asm198x','--dialect','ca65',str(UNIT/'dash.asm'),'-o',str(rebuilt)],check=True)
    assert rebuilt.read_bytes() == (UNIT/'dash.nes').read_bytes()
    results = {'source_sha256':BASELINE, 'emulator_sha256':sha(args.emulator), 'variants':{}}
    for mode in ('fast', 'slow', 'overload'):
        src = args.output / f'{mode}.asm'
        src.write_text(source(mode))
        rom = src.with_suffix('.nes')
        subprocess.run(['asm198x','--dialect','ca65',str(src),'-o',str(rom)],check=True)
        m = intro.Machine(str(args.emulator.resolve()), rom)
        try:
            m.call('start_audio_recording',path=str(args.output/f'{mode}.wav'))
            m.call('run_frames',frames=380)
            m.call('stop_audio_recording')
            with wave.open(str(args.output/f'{mode}.wav'),'rb') as wav:
                frames,rate,channels=wav.getnframes(),wav.getframerate(),wav.getnchannels()
                raw=wav.readframes(frames)
            samples=struct.unpack('<'+'h'*(len(raw)//2),raw)
            peak=max(map(abs,samples))
            assert 0 < peak < 32767
            if mode == 'overload':
                assert max(map(abs,samples[4*rate*channels:])) == 0
            audio={'seconds':frames/rate,'peak_pcm':peak,'sha256':sha(args.output/f'{mode}.wav')}

            mem = m.call('memory_read',addr=0x300,len=112)['bytes']
            control = m.call('memory_read',addr=0x40,len=8)['bytes']
            count = control[6]
            rows = [[mem[i]+256*mem[i+1], mem[i+2], mem[i+3]] for i in range(0,count*4,4)]
            if mode == 'overload':
                assert control[2] == 1
                assert m.call('memory_read',addr=22,len=1)['bytes'] == [0]
                assert rows == oracle('fast')[:11]
            else:
                assert control[2] == 0 and count == 28
                assert rows == oracle(mode), (mode, rows, oracle(mode))
            results['variants'][mode] = {'events_frame_index_timer':rows, 'control':control,
                'source_sha256':sha(src),'rom_sha256':sha(rom), 'audio':audio}
            print('PASS',mode,len(rows),'guest events',flush=True)

        finally:
            m.close()
    fast = results['variants']['fast']['events_frame_index_timer']
    slow = results['variants']['slow']['events_frame_index_timer']
    assert all(a[1:] == b[1:] and 0 <= a[0]-b[0] <= 1 for a,b in zip(fast,slow))
    # Fresh-process regression: same frame-scheduled input, selected game state.
    fields = [0,1,2,6,7,10,11,12,14,15,16,17,18,19,27]
    regressions = {}
    for mode in ('baseline','fast','slow','overload'):
        rom = UNIT/'dash.nes' if mode == 'baseline' else args.output/f'{mode}.nes'
        m = intro.Machine(str(args.emulator.resolve()),rom)
        try:
            m.call('run_frames',frames=380)
            states=[]
            for key,held,frames in [('start',True,2),('start',False,2),
                                    ('right',True,8),('right',False,2),
                                    ('a',True,6),('a',False,3)]:
                m.call('input',events=[{'Button':{'port':1,'name':key,'pressed':held}}])
                m.call('run_frames',frames=frames)
                memory=m.call('memory_read',addr=0,len=28)['bytes']
                states.append([memory[i] for i in fields])
            assert states[0][7] == 1, states[0] # playing state
            assert memory[22] == 0 # title music stopped on entering play
            regressions[mode]=states
            if mode != 'baseline':
                assert states == regressions['baseline'], mode
            # Complete one playing NMI and measure its actual transfer window.
            data=rom.read_bytes()
            nmi=int.from_bytes(data[16+0x7ffa:16+0x7ffc],'little')
            m.call('run_until_pc',addr=nmi,max_steps=100000)
            start=m.query('machine.master_clock')
            registers={r:m.query('cpu.'+r) for r in ('a','x','y','sp')}
            for _ in range(250):
                pc=m.query('cpu.pc')
                opcode=data[16+pc-0x8000]
                m.call('step',instructions=1)
                if opcode == 0x40:
                    break
            else:
                raise AssertionError('NMI did not return')
            assert 241 <= m.query('ppu.scanline') < 261
            assert {r:m.query('cpu.'+r) for r in registers} == {**registers,'sp':(registers['sp']+3)&255}
            results.setdefault('playing_nmi',{})[mode] = {
                'cycles_including_dma':(m.query('machine.master_clock')-start)//3,
                'return_scanline':m.query('ppu.scanline')}
            print('PASS',mode,'start/movement/jump and playing NMI',flush=True)
        finally:
            m.close()
    results['regression_fields_zero_page']=fields
    results['regression_states']=regressions
    results['configuration']='NTSC native emulator; slow requests omit every sixth main opportunity, not PAL; guest logs are instrumented'
    results['limits']='No general missed-frame detector; elapsed inputs are supplied by fixture. One playing handler path, not worst-case game budget or hardware.'
    (args.output/'results.json').write_text(json.dumps(results,indent=2)+'\n')


if __name__ == '__main__':
    main()
