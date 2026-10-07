#!/usr/bin/env python3
"""Exercise the real profiler and its deliberate failure cases without firmware."""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assembler', default='asm198x')
    parser.add_argument('--emulator', default='emu198x-spectrum')
    args = parser.parse_args()
    command = [sys.executable, str(ROOT / 'verify.py'),
               '--assembler', args.assembler, '--emulator', args.emulator]
    checks = []
    with tempfile.TemporaryDirectory(prefix='profile-routine-') as directory:
        root = Path(directory)
        two = (ROOT / 'loop.asm').read_text().replace('ld b,32', 'ld b,16')
        two = two.replace('        djnz fill_loop',
                          '        ld (hl),a\n        inc hl\n        djnz fill_loop')
        (root / 'two-at-a-time.asm').write_text(two)
        (root / 'too-many.asm').write_text(
            (ROOT / 'unrolled.asm').read_text().replace('ld b,8', 'ld b,32'))
        cases = [
            ('baseline', [], 0, None),
            ('two-at-a-time', ['--source', str(root / 'two-at-a-time.asm')], 0, None),
            ('buffer-overrun', ['--source', str(root / 'too-many.asm'),
                                '--ticks', '16384'], 1, 'unchanged boundary guards'),
            ('unfinished-capture', ['--ticks', '256'], 1, 'did not complete exactly once'),
            # Reuse the passing baseline directory to check stale-result removal.
            ('failed-rerun', ['--ticks', '256'], 1, 'did not complete exactly once'),
        ]
        for name, options, expected_exit, diagnostic in cases:
            output = root / ('baseline' if name == 'failed-rerun' else name)
            result = subprocess.run([*command, *options, '--output', str(output)],
                                    capture_output=True, text=True, timeout=120)
            if result.returncode != expected_exit:
                raise RuntimeError(f'{name}: {result.stdout}\n{result.stderr}')
            summary = output / 'results.json'
            if diagnostic:
                if diagnostic not in result.stderr or summary.exists():
                    raise RuntimeError(f'{name}: failure or stale-result check failed')
            if name == 'two-at-a-time':
                row = json.loads(summary.read_text())['cases'][0]
                if (row['routine_bytes'], row['routine_t_states']) != (9, 636):
                    raise RuntimeError('The guided two-byte edit changed its cost')
            checks.append({'case': name, 'expected_exit': expected_exit,
                           'observed_exit': result.returncode, 'passed': True})
            print(f'PASS {name}')
    print(json.dumps({'checks': checks}, indent=2))


if __name__ == '__main__':
    main()
