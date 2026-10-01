"""Execute maintained beeper code, trace its writes and measure captured PCM."""
import argparse
from array import array
import hashlib
import importlib.util
import json
from pathlib import Path
import re
from statistics import mean, median
import subprocess
import sys
import wave

ROOT = Path(__file__).resolve().parents[1]
SPECTRUM = ROOT.parents[3]
spec = importlib.util.spec_from_file_location(
    'transport', SPECTRUM / 'basic/meet-basic/opening/verification/verify.py')
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)


def sha(file):
    return hashlib.sha256(file.read_bytes()).hexdigest()


def assemble(source, output, pasmo=None):
    symbols = output / 'program.sym'
    for flag, suffix in [('', 'bin'), ('--sna', 'sna'), ('--tapbas', 'tap')]:
        subprocess.run(['asm198x', '--dialect', 'pasmo', '--cpu', 'z80',
                        *([flag] if flag else []), '--sym=' + str(symbols),
                        str(source), '-o', str(output / ('program.' + suffix))],
                       check=True, capture_output=True, cwd=source.parent)
    if pasmo:
        reference = output / 'reference.bin'
        subprocess.run([pasmo, '--bin', str(source), str(reference)], check=True,
                       capture_output=True, cwd=source.parent)
        assert reference.read_bytes() == (output / 'program.bin').read_bytes()
    return {name: int(value, 16) for name, value in
            re.findall(r'^(\w+) = \$(\w+)', symbols.read_text(), re.M)}


def pcm(file):
    with wave.open(str(file)) as stream:
        assert stream.getsampwidth() == 2 and stream.getnchannels() == 1
        rate = stream.getframerate()
        samples = array('h', stream.readframes(stream.getnframes()))
    if sys.byteorder != 'little':
        samples.byteswap()
    midpoint = (min(samples) + max(samples)) / 2
    rising = [i for i in range(1, len(samples))
              if samples[i - 1] < midpoint <= samples[i]]
    assert len(rising) >= 4, 'Captured audio has no measurable tone'
    periods = [b - a for a, b in zip(rising, rising[1:])]
    return rate, rising, periods


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--pasmo')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    report = {
        'target': 'Stock 48K PAL; code $8000, stack $FF00; DI during tones',
        'method': 'Snapshot callers, complete I/O traces, PCM crossings; separate fresh ROM tape load',
        'emulator_sha256': sha(Path(args.emulator)),
        'sources': {p.name: sha(p) for p in ROOT.glob('*.asm')},
        'includes': {p.name: sha(p) for p in ROOT.glob('*.inc')},
        'cases': [],
        'limits': 'Emulator observations; no physical hardware or listening claim.',
    }
    if args.pasmo:
        banner = subprocess.run([args.pasmo], capture_output=True, text=True)
        report['alternate_assembler'] = (banner.stdout + banner.stderr).splitlines()[0]
    cases = [('low', 255, 105, 1), ('high', 127, 105, 1),
             ('high-long', 127, 210, 1), ('low-short', 255, 20, 1),
             ('mic-high', 255, 105, 9), ('success', 200, 16, 1),
             ('error', 88, 16, 1), ('click', 127, 12, 1)]
    for name, delay, cycles, base in cases:
        target = out / name
        target.mkdir(exist_ok=True)
        routine = 'sound_' + name if name in ('success', 'error', 'click') else 'sound_beep'
        source = target / 'caller.asm'
        source.write_text(f'''    org 32768
start:
    di
    ld sp,$ff00
    ld bc,$1234
    ld de,$5678
    ld hl,${delay:02x}{cycles:02x}
    ld a,(ula_output)
    call {routine}
    ld (after_hl),hl
    ld (after_bc),bc
    ld (after_de),de
    ld (after_sp),sp
    ld a,i
    push af
    pop bc
    ld a,c
    and 4
    ld (after_iff),a
    ld a,1
    ld (done),a
    ei
hold:
    halt
    jr hold
    include "{ROOT / 'sound-beep.inc'}"
    include "{ROOT / 'effects.inc'}"
ula_output: defb {base}
after_hl: defw 0
after_bc: defw 0
after_de: defw 0
after_sp: defw 0
after_iff: defb 255
done: defb 0
    end start
''')
        symbols = assemble(source, target, args.pasmo)
        machine = transport.Spectrum(args.emulator, target)
        try:
            machine.call('load_snapshot', path=str(target / 'program.sna'))
            machine.call('clear_audio_capture')
            trace = machine.call('io_trace', frames=20, limit=4096)
            assert trace['total_events'] <= 4096, 'I/O sample was truncated'
            writes = [int(e['value'][1:], 16) for e in trace['events'] if e['dir'] == 'out']
            notes = ([200 - 16 * i for i in range(8)] if name == 'success' else
                     [88 + 16 * i for i in range(8)] if name == 'error' else [delay])
            count = 128 if name in ('success', 'error') else cycles
            assert writes == [value for _ in range(count) for value in [base | 16, base]], writes
            def memory(label, length=1):
                return machine.call('memory_read', addr=symbols[label], len=length)['bytes']
            assert memory('done') == [1] and memory('after_iff') == [0]
            assert memory('after_sp', 2) == [0, 255]
            assert memory('after_bc', 2)[0] == 0x34 and memory('after_de', 2)[0] == 0x78
            if routine == 'sound_beep':
                assert memory('after_hl', 2) == [0, delay]
            audio = target / 'tone.wav'
            machine.call('save_audio_capture', path=str(audio))
            rate, rising, periods = pcm(audio)
            assert count - 1 <= len(rising) <= count + 1, (name, count, len(rising))
            frequencies = []
            for i, half in enumerate(notes):
                window = periods[i * 16:i * 16 + 15] if len(notes) > 1 else periods
                measured = rate / mean(window)
                expected = 3_500_000 / (26 * half + 51)
                assert abs(measured / expected - 1) < 0.025, (name, i, measured, expected)
                frequencies.append(measured)
            if name in ('success', 'error'):
                assert all((b > a) == (name == 'success')
                           for a, b in zip(frequencies, frequencies[1:]))
            duration = (rising[-1] - rising[0] + median(periods)) / rate
            entry = {'name': name, 'frequency_hz': frequencies,
                     'observed_tone_seconds': duration, 'cycles': count,
                     'port_writes': len(writes), 'base_output': base,
                     'source_sha256': sha(source), 'binary_sha256': sha(target / 'program.bin'),
                     'wav_sha256': sha(audio), 'checks': [
                         'Complete alternating speaker writes preserve border/MIC',
                         'Caller resumes with stack, C, E and disabled interrupt state preserved',
                         'PCM pitch matches the nominal instruction-cost derivation',
                         'PCM cycle count matches the bus trace']}
            report['cases'].append(entry)
            print('PASS', name, [round(f, 1) for f in frequencies], round(duration, 4), flush=True)
        finally:
            machine.close()
    results = {item['name']: item for item in report['cases']}
    assert 1.95 < results['high']['frequency_hz'][0] / results['low']['frequency_hz'][0] < 2.05
    assert 0.46 < results['high']['observed_tone_seconds'] / results['low']['observed_tone_seconds'] < 0.54
    assert 0.97 < results['high-long']['observed_tone_seconds'] / results['low']['observed_tone_seconds'] < 1.03
    assert abs(results['low-short']['frequency_hz'][0] / results['low']['frequency_hz'][0] - 1) < 0.01
    assert results['low-short']['observed_tone_seconds'] < results['low']['observed_tone_seconds'] / 4
    demo = out / 'demo'
    demo.mkdir(exist_ok=True)
    symbols = assemble(ROOT / 'demo.asm', demo, args.pasmo)
    machine = transport.Spectrum(args.emulator, demo)
    try:
        machine.call('load_media', slot='tape-1', kind='tape', path=str(demo / 'program.tap'))
        machine.statement('LOAD ""')
        machine.call('media_transport', slot='tape-1', transport='start')
        machine.frames(3000)
        assert machine.call('memory_read', addr=symbols['done'], len=1)['bytes'] == [1]
        report['fresh_tape_sequence_completed'] = True
        print('PASS fresh ROM tape load completes all four sounds', flush=True)
    finally:
        machine.close()
    report['status'] = 'passed'
    (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
