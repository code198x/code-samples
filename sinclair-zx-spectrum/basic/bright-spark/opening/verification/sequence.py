#!/usr/bin/env python3
"""Verify the representation lesson by editing its predecessor through the ROM."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('prototype', ROOT.parent / 'prototype/verification/verify.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    machine = module.Spectrum(args.emulator, args.output)
    previous = {}
    hashes = {}
    cases = [('unit-02/steps/step-03.bas', []),
             ('unit-03/steps/step-01.bas', ['Order: 314']),
             ('unit-03/steps/step-02.bas', ['Order: 314', 'Length: 3', 'First: 3', 'Last: 4']),
             ('unit-03/steps/step-03.bas', ['Order: 3142', 'Length: 4', 'First: 3', 'Last: 2'])]
    try:
        for relative, expected in cases:
            source = ROOT / relative
            current = {int(line.split()[0]): line for line in source.read_text().splitlines()}
            for number in sorted(previous.keys() - current.keys()):
                machine.statement(str(number))
                machine.frames(60)
            for number, line in current.items():
                if previous.get(number) != line:
                    machine.statement(line)
                    machine.frames(60)
            machine.statement('RUN')
            machine.frames(350)
            machine.labels()
            assert not machine.stars()
            machine.check(relative.replace('/', '-').replace('.bas', ''), expected + ['9 STOP'])
            hashes[relative] = hashlib.sha256(source.read_bytes()).hexdigest()
            previous = current
        # RUN starts from the literal again; it must not keep appending.
        machine.statement('RUN')
        machine.frames(200)
        machine.check('rerun-resets-order', ['Order: 3142', 'Length: 4'], capture=False)
        machine.statement('285 LET s$=s$+"4"')
        machine.statement('RUN')
        machine.frames(200)
        machine.check('append-experiment', ['Order: 3144', 'Length: 4', 'Last: 4'])
        machine.statement('285 LET s$=s$+"2"')
        machine.statement('RUN')
        machine.frames(200)
        machine.check('restored-checkpoint', ['Order: 3142', 'Last: 2'], capture=False)
        (args.output / 'results.json').write_text(json.dumps({
            'status': 'passed', 'server': machine.server,
            'configuration': '48K Spectrum, 50 Hz, ROM key entry and sequential line edits',
            'binary_sha256': hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(),
            'sources': hashes, 'checks': machine.evidence,
            'limits': 'Emulator execution; no original hardware or native keyboard acceptance.'
        }, indent=2) + '\n')
    finally:
        machine.close()


if __name__ == '__main__':
    main()
