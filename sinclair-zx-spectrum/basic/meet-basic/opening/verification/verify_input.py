#!/usr/bin/env python3
"""Verify A3 input, changed answers, and empty/long strings through the 48K ROM."""
import argparse
import hashlib
import json
import shutil
from pathlib import Path
from verify import ROOT, Spectrum


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', default='emu198x-spectrum')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    machine = Spectrum(args.emulator, args.output)
    sources = [ROOT / 'unit-02/steps/step-03.bas',
               ROOT / 'unit-03/steps/step-01.bas', ROOT / 'unit-03/steps/step-02.bas']
    previous = ''
    try:
        for path in sources:
            source = path.read_text()
            for line in source.splitlines():
                if line not in previous.splitlines():
                    machine.statement(line)
            previous = source
            if path.parent.parent.name == 'unit-02':
                continue
            cases = [('Sam',), ('Ada',)] if path.name == 'step-01.bas' else [
                ('Sam', 'sleepy', 'dragon'), ('Jo', 'enormous', 'owl'),
                ('', '', ''), ('Alexandertheexplorer', 'extraordinarily', 'hippopotamus')]
            for case_number, answers in enumerate(cases, 1):
                name = f'unit-03-{path.stem}-case-{case_number}'
                machine.statement('RUN')
                for prompt, answer in zip(['Your name', 'Describing word', 'Animal'], answers):
                    machine.check(f'{name}-waiting-{prompt.replace(" ", "-")}', [prompt], capture=False)
                    # INPUT supplies quotes and places the cursor between them.
                    machine.text(answer)
                    machine.enter()
                expected = f'Hello, {answers[0]}'.ljust(32) + 'from the Spectrum'.ljust(32)
                if len(answers) == 3:
                    expected += f'{answers[0]} met the {answers[1]} {answers[2]}'
                # Compare the whole output, including wrap and blanks, rather than
                # a substring that could occur in the input area or a listing.
                screen = machine.screen()
                rows = (len(expected) + 31) // 32
                assert ''.join(line.ljust(32) for line in screen[:rows]).rstrip() == expected.rstrip(), (name, screen, expected)
                assert screen[-1].startswith('0 OK'), (name, screen)
                machine.check(name, ['0 OK'])
        result = {'status': 'passed', 'server': machine.server,
                  'configuration': 'Spectrum 48K; ROM keyboard entry; MCP',
                  'limits': 'No native GUI, original hardware or other emulator verified; no tape check in this run.',
                  'binary_sha256': hashlib.sha256(Path(shutil.which(args.emulator) or args.emulator).read_bytes()).hexdigest(),
                  'source_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
                  'checks': machine.evidence}
        (args.output / 'input-results.json').write_text(json.dumps(result, indent=2) + '\n')
    finally:
        machine.close()


if __name__ == '__main__':
    main()
