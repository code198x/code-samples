"""Run the maintained SID note routines on Emu198x's C64 and check what they do.

Three programs are built from sid-note.inc and run on a PAL C64 booted from
its own ROMs, each started with a typed RUN:

- ownership: the routines aimed at a RAM copy of a voice, to show which
  bytes they write and which registers they keep;
- envelope: the routines on voice 3, sampling ENV3 ($D41C) to time the
  attack, retrigger and release;
- demo: the maintained demonstration, with its audio captured and measured.

Results are emulator observations, not original-hardware measurements.
"""
import argparse
from array import array
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
PAL_HZ = 985_248          # PAL C64 system clock (phi2)
FRAME_CYCLES = 312 * 63   # PAL VIC-II frame: 312 lines of 63 cycles

STUB = '''* = $0801
    !byte $0b, $08, $0a, $00, $9e
    !text "2064"
    !byte $00, $00, $00
* = $0810
'''

OWNERSHIP = STUB + '''SID_VOICE = $0c07          ; mirror + 7: a RAM stand-in for voice 2
start:
    lda #$12
    ldx #$34
    ldy #$56
    jsr sid_voice_setup
    stx after + 0
    sty after + 1
    ldx #31
copy1:
    lda mirror, x
    sta snap1, x
    dex
    bpl copy1
    lda #$11
    ldx #$67
    ldy #$9a
    jsr sid_note_on
    stx after + 2
    sty after + 3
    ldx #31
copy2:
    lda mirror, x
    sta snap2, x
    dex
    bpl copy2
    ldx #$bc
    ldy #$de
    jsr sid_note_off
    stx after + 4
    sty after + 5
    ldx #31
copy3:
    lda mirror, x
    sta snap3, x
    dex
    bpl copy3
    lda #1
    sta done
hold:
    jmp hold
!source "sid-note.inc"
* = $0c00
mirror: !fill 32, $a5
snap1: !fill 32, 0
snap2: !fill 32, 0
snap3: !fill 32, 0
after: !fill 6, 0
done: !byte 0
'''

ENVELOPE = STUB + '''SID_VOICE = $d40e          ; voice 3, whose envelope ENV3 reports
PTR = $fb
start:
    sei
    lda #$0b                ; blank the screen so no VIC-II DMA pauses the samples
    sta $d011
    ldy #2
    jsr wait_frames
    lda #$0f
    sta $d418

    lda #$00                ; attack 0, decay 0; sustain 15, release 9
    ldx #$f9
    jsr sid_voice_setup
    ldy #5
    jsr wait_frames
    lda #$11
    ldx #$67
    jsr sid_note_on
    jsr wait_nonzero
    stx attack_wait
    sty attack_wait + 1
    lda #<attack_samples
    ldx #>attack_samples
    jsr sample_fast
    ldy #5
    jsr wait_frames
    lda $d41c
    sta peak_hold
    jsr sid_note_off
    lda #<release_frames
    ldx #>release_frames
    jsr sample_frames

    lda #$00                ; attack 0, decay 0; sustain 8, release 9
    ldx #$89
    jsr sid_voice_setup
    lda #$11
    ldx #$67
    jsr sid_note_on
    ldy #3
    jsr wait_frames
    lda $d41c
    sta sustain_level
    lda #SID_WAVE_PULSE | SID_GATE   ; write a set gate again, without clearing it
    sta SID_VOICE + 4
    ldy #2
    jsr wait_frames
    lda $d41c
    sta after_repeat
    lda #$11
    ldx #$67
    jsr sid_note_on
    lda #<retrigger_samples
    ldx #>retrigger_samples
    jsr sample_fast
    lda #1
    sta done
hold:
    jmp hold

!source "sid-note.inc"

* = $0c00                   ; one page, so no branch crosses a page boundary
; 256 ENV3 samples, 15 cycles apart, into the page at A (low) / X (high).
sample_fast:
    sta PTR
    stx PTR + 1
    ldy #0
fast_loop:
    lda $d41c               ; 4
    sta (PTR), y            ; 6
    iny                     ; 2
    bne fast_loop           ; 3
    rts
; X/Y = number of 11-cycle polls before ENV3 left zero.
wait_nonzero:
    ldx #0
    ldy #0
zero_loop:
    lda $d41c               ; 4
    bne zero_end            ; 2
    inx                     ; 2
    bne zero_loop           ; 3
    iny
    bne zero_loop
zero_end:
    rts
; 100 ENV3 samples, one per frame at raster line 255.
sample_frames:
    sta PTR
    stx PTR + 1
    ldy #0
frame_loop:
    jsr wait_frame
    lda $d41c
    sta (PTR), y
    iny
    cpy #100
    bne frame_loop
    rts
wait_frames:
    jsr wait_frame
    dey
    bne wait_frames
    rts
wait_frame:
    lda $d012
    cmp #$ff
    bne wait_frame
frame_end:
    lda $d012
    cmp #$ff
    beq frame_end
    rts

* = $1000
attack_samples: !fill 256, 0
retrigger_samples: !fill 256, 0
release_frames: !fill 100, 0
attack_wait: !word 0
peak_hold: !byte 0
sustain_level: !byte 0
after_repeat: !byte 0
done: !byte 0
'''


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def assemble(source, output, name):
    output.mkdir(parents=True, exist_ok=True)
    prg = output / (name + '.prg')
    symbols = output / (name + '.sym')
    listing = output / (name + '.lst.json')
    subprocess.run(['asm198x', '--dialect', 'acme', '--prg', '-I', str(ROOT),
                    '--sym=' + str(symbols),
                    '--listing-json=' + str(listing), str(source), '-o', str(prg)],
                   check=True, capture_output=True, cwd=ROOT)
    table = {}
    for line in symbols.read_text().splitlines():
        label, value = line.split(' = $')
        table[label] = int(value, 16)
    return prg, table, json.loads(listing.read_text())


def run(emulator, prg, output, name, frames, reads, audio=None):
    """Type RUN after the PRG import, run, then read memory (and audio)."""
    script = [] if audio is None else [{'action': 'clear_audio_capture'}]
    for key in ['R', 'U', 'N', 'RETURN']:
        for pressed, hold in [(True, 4), (False, 3)]:
            script += [{'action': 'input', 'events': [{'Key': {'name': key, 'pressed': pressed}}]},
                       {'action': 'run_frames', 'frames': hold}]
    script.append({'action': 'run_frames', 'frames': frames})
    script += [{'action': 'memory_read', 'addr': addr, 'len': length} for addr, length in reads]
    if audio is not None:
        script.append({'action': 'save_audio_capture', 'path': str(audio)})
    path = output / (name + '.script.json')
    path.write_text(json.dumps(script, indent=2) + '\n')
    result = subprocess.run([str(emulator), '--model', 'pal', '--load', str(prg),
                             '--script', str(path)], capture_output=True, text=True, check=True)
    report = json.loads(result.stdout)
    assert report['boot_detected'], report['boot_reason']
    return [o['bytes'] for o in report['observations'] if o['kind'] == 'memory_read']


def check_costs(listing):
    labels = {item['name']: item for item in listing['labels']}
    costs = {}
    for name, size, cycles in [('sid_voice_setup', 22, 32), ('sid_note_on', 17, 26),
                               ('sid_note_off', 6, 12)]:
        item = labels[name]
        assert item['bytes'] == size, (name, item)
        assert item['cycles'] == {'min': cycles, 'max': cycles}, (name, item)
        costs[name] = {'bytes': size, 'cycles_through_rts': cycles}
    print('PASS listing costs', costs, flush=True)
    return costs


def check_ownership(emulator, output):
    output.mkdir(parents=True, exist_ok=True)
    source = output / 'ownership.asm'
    source.write_text(OWNERSHIP)
    prg, symbols, listing = assemble(source, output, 'ownership')
    snap1, snap2, snap3, after, done = run(emulator, prg, output, 'ownership', 20, [
        (symbols['snap1'], 32), (symbols['snap2'], 32), (symbols['snap3'], 32),
        (symbols['after'], 6), (symbols['done'], 1)])
    assert done == [1]
    untouched = [0xa5] * 7

    def voice(*registers):
        return untouched + list(registers) + [0xa5] * 18
    assert snap1 == voice(0xa5, 0xa5, 0x00, 0x08, 0x40, 0x12, 0x34), snap1
    assert snap2 == voice(0x67, 0x11, 0x00, 0x08, 0x41, 0x12, 0x34), snap2
    assert snap3 == voice(0x67, 0x11, 0x00, 0x08, 0x40, 0x12, 0x34), snap3
    assert after == [0x34, 0x56, 0x67, 0x9a, 0xbc, 0xde], after
    print('PASS ownership: only the seven voice bytes change; X and Y kept', flush=True)
    return {'source_sha256': sha(source), 'prg_sha256': sha(prg),
            'after_setup': snap1[7:14], 'after_note_on': snap2[7:14],
            'after_note_off': snap3[7:14]}


def check_envelope(emulator, output):
    output.mkdir(parents=True, exist_ok=True)
    source = output / 'envelope.asm'
    source.write_text(ENVELOPE)
    prg, symbols, listing = assemble(source, output, 'envelope')
    names = [('attack_samples', 256), ('retrigger_samples', 256), ('release_frames', 100),
             ('attack_wait', 2), ('peak_hold', 1), ('sustain_level', 1),
             ('after_repeat', 1), ('done', 1)]
    values = dict(zip([n for n, _ in names], run(
        emulator, prg, output, 'envelope', 300, [(symbols[n], size) for n, size in names])))
    assert values['done'] == [1]
    attack = values['attack_samples']
    wait_polls = values['attack_wait'][0] | values['attack_wait'][1] << 8
    # Attack rate 0: ENV3 climbs in steps; it is not at peak on the first sample.
    assert attack[0] < 0x40, attack[:8]
    # Samples are 15 cycles apart and attack 0 steps faster, so the peak
    # sample can be $FE rather than $FF.
    rise = attack.index(max(attack))
    assert attack[rise] >= 0xfe, attack
    assert all(b >= a for a, b in zip(attack, attack[1:rise + 1])), attack
    rise_cycles = rise * 15
    rise_ms = rise_cycles / PAL_HZ * 1000
    assert 1500 <= rise_cycles <= 4000, rise_cycles
    assert values['peak_hold'] == [0xff]
    release = values['release_frames']
    assert all(b <= a for a, b in zip(release, release[1:])), release
    release_frames = release.index(0) + 1
    release_ms = release_frames * FRAME_CYCLES / PAL_HZ * 1000
    assert 600 <= release_ms <= 950, release_ms
    wait_ms = wait_polls * 11 / PAL_HZ * 1000
    print(f'PASS attack 0 rises over {rise_ms:.2f} ms, starting {wait_ms:.1f} ms after the gate; '
          f'release 9 from peak reaches 0 within {release_ms:.0f} ms', flush=True)
    assert values['sustain_level'] == [0x88], values['sustain_level']
    retrigger = values['retrigger_samples']
    peak = retrigger.index(max(retrigger))
    assert retrigger[peak] >= 0xfe, retrigger
    assert 0x80 <= retrigger[0] < 0xa0, retrigger[:8]
    assert all(b >= a for a, b in zip(retrigger, retrigger[1:peak + 1])), retrigger
    assert retrigger[-1] == 0x88, retrigger[-8:]
    retrigger_cycles = peak * 15
    assert retrigger_cycles < rise_cycles, (retrigger_cycles, rise_cycles)
    print(f'PASS retrigger from sustain $88 climbs to peak in {retrigger_cycles} cycles '
          f'without first falling to zero, then decays back to $88', flush=True)
    # Emulator observation, not a page claim: a repeated write of a set gate
    # does not start another attack in Emu198x's SID.
    repeat = values['after_repeat'][0]
    print(f'NOTE repeated set gate left ENV3 at ${repeat:02X}', flush=True)
    return {'source_sha256': sha(source), 'prg_sha256': sha(prg),
            'attack0_zero_polls_before_rise': wait_polls,
            'attack0_start_ms_after_gate': round(wait_ms, 1),
            'attack0_rise_cycles': rise_cycles, 'attack0_rise_ms': round(rise_ms, 3),
            'attack0_first_samples': attack[:12],
            'release9_frames_to_zero': release_frames, 'release9_ms_upper': round(release_ms, 1),
            'sustain8_level': values['sustain_level'][0],
            'repeated_set_gate_env3': repeat,
            'retrigger_first_samples': retrigger[:12], 'retrigger_rise_cycles': retrigger_cycles}


def check_demo(emulator, output):
    prg, symbols, listing = assemble(ROOT / 'demo.asm', output, 'demo')
    audio = output / 'demo.wav'
    (done,) = run(emulator, prg, output, 'demo', 150, [(symbols['done'], 1)], audio)
    assert done == [1]
    with wave.open(str(audio)) as stream:
        assert stream.getsampwidth() == 2 and stream.getnchannels() == 1
        rate = stream.getframerate()
        samples = array('h', stream.readframes(stream.getnframes()))
    if sys.byteorder != 'little':
        samples.byteswap()
    window = rate // 100
    levels = []
    for start in range(0, len(samples) - window, window):
        chunk = samples[start:start + window]
        centre = sum(chunk) / window
        levels.append((sum((s - centre) ** 2 for s in chunk) / window) ** 0.5)
    loud = max(levels)
    # The note is the first run of 20 or more 10 ms windows above half the
    # loudest level. (Writing $D418 earlier makes a brief click.)
    onset = next(i for i in range(len(levels) - 20)
                 if all(level > loud / 2 for level in levels[i:i + 20]))
    held_level = sum(levels[onset + 5:onset + 45]) / 40
    hold_end = next(i for i in range(onset + 5, len(levels)) if levels[i] < held_level * 0.9)
    hold_ms = (hold_end - onset) * 10
    assert 450 <= hold_ms <= 550, hold_ms
    # Pitch over 300 ms of the held note, counting rising crossings with
    # hysteresis so filter ringing on the pulse edges is not counted.
    note = samples[(onset + 10) * window:(onset + 40) * window]
    middle = (max(note) + min(note)) / 2
    band = (max(note) - min(note)) / 4
    rising, low = [], False
    for i, sample in enumerate(note):
        if sample < middle - band:
            low = True
        elif low and sample > middle + band:
            rising.append(i)
            low = False
    pitch = (len(rising) - 1) * rate / (rising[-1] - rising[0])
    expected = 0x1167 * PAL_HZ / 2 ** 24
    assert abs(pitch / expected - 1) < 0.01, (pitch, expected)
    # After the gate clears, the level falls gradually, not in one step.
    release = levels[hold_end:]
    assert release[0] > held_level * 0.5, release[:5]
    fade_ms = next(i for i, level in enumerate(release) if level < held_level * 0.01) * 10
    assert 150 <= fade_ms <= 900, fade_ms
    print(f'PASS demo: {pitch:.2f} Hz (expected {expected:.2f}); held {hold_ms} ms; '
          f'fell below 1% of the held level {fade_ms} ms after the hold', flush=True)
    return {'prg_sha256': sha(prg), 'wav_sha256': sha(audio), 'measured_hz': round(pitch, 2),
            'expected_hz': round(expected, 2), 'hold_ms': hold_ms,
            'release_ms_to_one_percent_level': fade_ms}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', type=Path, required=True,
                        help='emu198x-c64 binary with C64 ROMs configured')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    _, _, listing = assemble(ROOT / 'demo.asm', out / 'costs', 'demo')
    report = {
        'target': 'C64 PAL, booted from its ROMs; PRG imported, started with RUN',
        'emulator_sha256': sha(args.emulator),
        'sources': {p.name: sha(p) for p in sorted(ROOT.glob('*.asm'))},
        'includes': {p.name: sha(p) for p in sorted(ROOT.glob('*.inc'))},
        'costs': check_costs(listing),
        'ownership': check_ownership(args.emulator, out / 'ownership'),
        'envelope': check_envelope(args.emulator, out / 'envelope'),
        'demo': check_demo(args.emulator, out / 'demo'),
        'limits': 'Emulator observations; no original-hardware measurement or listening claim.',
        'status': 'passed',
    }
    (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
