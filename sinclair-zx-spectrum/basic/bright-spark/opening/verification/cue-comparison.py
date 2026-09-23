#!/usr/bin/env python3
"""Capture independent unit 02 cue comparisons through the 48K ROM editor."""
import argparse
import hashlib
import importlib.util
import json
import math
from pathlib import Path
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('prototype', ROOT.parent / 'prototype/verification/verify.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def measure(path):
    with wave.open(str(path)) as wav:
        assert wav.getnchannels() == 1 and wav.getsampwidth() == 2
        rate = wav.getframerate()
        samples = struct.unpack('<' + 'h' * wav.getnframes(), wav.readframes(wav.getnframes()))
    width = rate // 100
    groups = []
    previous = False
    for index, start in enumerate(range(0, len(samples), width)):
        window = samples[start:start + width]
        active = math.sqrt(sum(x*x for x in window) / len(window)) > 5000
        if active and not previous:
            groups.append([index, index + 1])
        elif active:
            groups[-1][1] = index + 1
        previous = active
    notes = []
    for start, end in groups:
        if end - start < 5:
            continue
        middle = samples[(start + 2)*width:(end - 2)*width]
        mean = sum(middle) / len(middle)
        crossings = sum(x <= mean < y for x, y in zip(middle, middle[1:]))
        notes.append({'start_seconds': start / 100, 'duration_seconds': (end-start) / 100,
                      'estimated_hz': crossings * rate / len(middle)})
    assert len(notes) == 4, notes
    return notes


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    source_path = ROOT / 'unit-02/steps/step-03.bas'
    baseline = source_path.read_text()
    variants = [('baseline', baseline, (261.6, 329.6, 392, 523.3), .15),
                ('pitch', baseline.replace('610 IF p=3 THEN LET note=7', '610 IF p=3 THEN LET note=9'),
                 (261.6, 329.6, 440, 523.3), .15),
                ('duration', baseline.replace('920 BEEP 0.15,note', '920 BEEP 0.45,note'),
                 (261.6, 329.6, 392, 523.3), .45),
                ('restored', baseline, (261.6, 329.6, 392, 523.3), .15)]
    # Keep the learner's maintained edits tied to the sources we execute.
    for name, source, _, _ in variants[1:3]:
        edit = (ROOT / f'unit-02/experiments/{name}.bas').read_text().strip()
        number = edit.split()[0]
        expected = '\n'.join(edit if line.split()[0] == number else line
                             for line in baseline.splitlines()) + '\n'
        assert source == expected, f'{name} lesson edit differs from capture'
    for line in (ROOT / 'unit-02/experiments/restore.bas').read_text().splitlines():
        assert line in baseline.splitlines(), 'Restoration differs from baseline'
    machine = module.Spectrum(args.emulator, output)
    previous = {}
    results = []
    try:
        for name, source, pitches, duration in variants:
            current = {line.split()[0]: line for line in source.splitlines()}
            for number, line in current.items():
                if previous.get(number) != line:
                    machine.statement(line)
                    machine.frames(60)
            (output / f'{name}.bas').write_text(source)
            machine.call('start_audio_recording', path=str(output / f'{name}.wav'))
            machine.statement('RUN')
            active_panels = []
            for _ in range(450):
                machine.frames(1)
                stars = machine.stars()
                if stars and (not active_panels or stars != active_panels[-1]):
                    active_panels.append(stars)
            machine.call('stop_audio_recording')
            assert active_panels == [[(5, 7)], [(5, 23)], [(14, 7)], [(14, 23)]], active_panels
            machine.labels()
            assert not machine.stars()
            machine.check(name, ['9 STOP'])
            notes = measure(output / f'{name}.wav')
            for note, pitch in zip(notes, pitches):
                assert abs(note['estimated_hz'] - pitch) < 25, note
                assert abs(note['duration_seconds'] - duration) <= .03, note
            results.append({'name': name, 'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                            'active_panels': active_panels, 'notes': notes})
            previous = current
        (output / 'results.json').write_text(json.dumps({
            'status': 'passed', 'configuration': 'Default Spectrum 48K PAL, configured ROM, MCP ROM key entry',
            'server': machine.server, 'emulator_sha256': hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(),
            'runs': results,
            'method': '10 ms RMS windows, threshold 5000; positive mean crossings in tone centre. Pitch tolerance 25 Hz, duration tolerance 30 ms.',
            'limits': 'Emulator signal and screen checks, not subjective listening, native host keyboard acceptance or original-hardware evidence.'
        }, indent=2) + '\n')
    finally:
        machine.close()


if __name__ == '__main__':
    main()
