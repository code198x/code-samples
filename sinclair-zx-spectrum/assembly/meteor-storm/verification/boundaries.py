"""Keyboard-only collision boundary experiment on the first-dodge checkpoint."""
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('transport', ROOT.parents[1] / 'basic/meet-basic/opening/verification/verify.py')
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    source = ROOT / 'checkpoints/first-dodge/meteor-storm.asm'
    subprocess.run(['asm198x', '--dialect', 'pasmo', '--cpu', 'z80', '--sna',
                    '--sym=' + str(out / 'symbols.sym'), str(source), '-o', str(out / 'program.sna')], check=True)
    symbols = {match[1]: int(match[2], 16) for line in (out / 'symbols.sym').read_text().splitlines()
               if (match := re.match(r'(\w+) = \$(\w+)', line))}
    report = {'method': 'Ordinary frames and keyboard input only; no state writes or stepping.',
              'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'cases': []}
    machine = transport.Spectrum(args.emulator, out)
    try:
        def read(name):
            return machine.call('memory_read', addr=symbols[name], len=1)['bytes'][0]
        for target in [100, 102, 130, 132]:
            machine.call('load_snapshot', path=str(out / 'program.sna'))
            machine.frames(8)
            key = 'O' if target < 116 else 'P'
            machine.call('input', events=[{'Key': {'name': key, 'pressed': True}}])
            for _ in range(30):
                if read('ship_x') == target:
                    break
                machine.frames(1)
            machine.call('input', events=[{'Key': {'name': key, 'pressed': False}}])
            assert read('ship_x') == target
            machine.frames(120)
            expected = 2 if abs(target - 116) < 16 else 3
            actual = read('phase')
            assert actual == expected, (target, actual, expected)
            report['cases'].append({'ship_x': target, 'meteor_x': 116,
                                    'horizontal_separation': abs(target - 116),
                                    'result': 'hit' if actual == 2 else 'miss'})
            print('PASS', report['cases'][-1], flush=True)
            machine.frames(1)
            machine.call('save_screenshot', path=str(out / f'x-{target}.png'))
        (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    finally:
        machine.close()


if __name__ == '__main__':
    main()
