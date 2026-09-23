#!/usr/bin/env python3
"""Check the isolated wrong-note fault, diagnostic and repair via the 48K ROM."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('comparison', ROOT / 'verification/cue-comparison.py')
comparison = importlib.util.module_from_spec(spec)
spec.loader.exec_module(comparison)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    baseline = (ROOT / 'unit-02/steps/step-03.bas').read_text()
    fault = ROOT / 'experiments/wrong-note'
    broken = (fault / 'broken.bas').read_text()
    repair = (fault / 'repair.bas').read_text().strip()
    observation = (fault / 'observe.bas').read_text().strip()
    assert broken == baseline.replace(repair + '\n', '')
    assert repair in baseline.splitlines()
    def insert(source, line):
        return '\n'.join(sorted(source.splitlines() + [line], key=lambda s: int(s.split()[0]))) + '\n'
    repaired = insert(broken, repair)
    assert repaired == baseline
    variants = [('baseline', baseline, (261.6, 329.6, 392, 523.3)),
                ('broken', broken, (261.6, 329.6, 261.6, 523.3)),
                ('observed', insert(broken, observation), (261.6, 329.6, 261.6, 523.3)),
                ('repaired-observed', insert(repaired, observation), (261.6, 329.6, 392, 523.3)),
                ('repaired', repaired, (261.6, 329.6, 392, 523.3)),
                ('repeated', repaired, (261.6, 329.6, 392, 523.3))]
    machine = comparison.module.Spectrum(args.emulator, output)
    previous = {}
    results = []
    try:
        for name, source, pitches in variants:
            current = {int(line.split()[0]): line for line in source.splitlines()}
            for number in sorted(previous.keys() - current.keys()):
                machine.statement(str(number))
                machine.frames(60)
            for number, line in current.items():
                if previous.get(number) != line:
                    machine.statement(line)
                    machine.frames(60)
            (output / f'{name}.bas').write_text(source)
            machine.call('start_audio_recording', path=str(output / f'{name}.wav'))
            machine.statement('RUN')
            panels = []
            for _ in range(450):
                machine.frames(1)
                stars = machine.stars()
                if stars and (not panels or stars != panels[-1]):
                    panels.append(stars)
            machine.call('stop_audio_recording')
            assert panels == [[(5, 7)], [(5, 23)], [(14, 7)], [(14, 23)]], panels
            machine.labels()
            assert not machine.stars()
            machine.check(name, ['9 STOP'])
            row = machine.screen()[21].rstrip()
            if name == 'observed':
                assert row.split() == ['0', '4', '0', '12'], row
            elif name == 'repaired-observed':
                assert row.split() == ['0', '4', '7', '12'], row
            else:
                assert not row, row
            notes = comparison.measure(output / f'{name}.wav')
            for note, pitch in zip(notes, pitches):
                assert abs(note['estimated_hz'] - pitch) < 25, note
                assert abs(note['duration_seconds'] - .15) <= .03, note
            results.append({'name': name, 'source_sha256': hashlib.sha256(source.encode()).hexdigest(),
                            'active_panels': panels, 'diagnostic_row': row, 'notes': notes})
            previous = current
        (output / 'results.json').write_text(json.dumps({
            'status': 'passed', 'configuration': 'Default Spectrum 48K PAL, configured ROM, MCP ROM key entry',
            'server': machine.server, 'emulator_sha256': hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(),
            'runs': results, 'checks': machine.evidence,
            'limits': 'Signal and screen checks; not subjective listening, native keyboard acceptance or original-hardware evidence. Diagnostic PRINT adds execution time.'
        }, indent=2) + '\n')
    finally:
        machine.close()


if __name__ == '__main__':
    main()
