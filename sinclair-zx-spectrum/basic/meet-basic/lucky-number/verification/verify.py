#!/usr/bin/env python3
"""Type and check Lucky Number's first six checkpoints with a real 48K ROM.

Reuse the opening's MCP transport, but enter each added BASIC token through its
ROM key chord. No BASIC injection, memory patching or bundled firmware.
"""
import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('opening_verify', ROOT.parent / 'opening/verification/verify.py')
opening = importlib.util.module_from_spec(spec)
spec.loader.exec_module(opening)


class Spectrum(opening.Spectrum):
    def text(self, text):
        symbols = {'<': 'r', '>': 't', '+': 'k', '-': 'j', '.': 'm', '!': '1', ':': 'z'}
        for c in text:
            if c in symbols:
                self.key('symbol', symbols[c])
            else:
                super().text(c)

    def statement(self, line):
        commands = {'PRINT': 'p', 'LET': 'l', 'RUN': 'r', 'LIST': 'k',
                    'SAVE': 's', 'LOAD': 'j', 'INPUT': 'i', 'CLS': 'v',
                    'IF': 'u', 'GO TO': 'g', 'STOP': 'a'}
        for part in re.split(r'("[^"]*"|\b(?:GO TO|PRINT|LET|RUN|LIST|SAVE|LOAD|INPUT|CLS|IF|STOP|THEN|INT)\b|<>)', line):
            if part == 'THEN':
                self.key('symbol', 'g')
            elif part == '<>':
                self.key('symbol', 'w')
            elif part == 'INT':
                self.key('caps', 'symbol')
                self.key('r')
            elif part == 'STOP':
                self.key('symbol', 'a')
            elif part in commands:
                self.key(commands[part])
            else:
                self.text(part)
        self.enter()

    def result(self, name, rows, finished=False, stopped=False):
        screen = [s.rstrip() for s in self.screen()]
        assert screen[:len(rows)] == rows, (name, rows, screen)
        assert all(not row for row in screen[len(rows):22]), (name, screen)
        if finished:
            assert screen[-1].startswith('9 STOP' if stopped else '0 OK'), (name, screen)
        else:
            assert any('Your guess' in row for row in screen[22:]), (name, screen)
        self.check(name, rows, capture=True)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emulator', required=True)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    m = Spectrum(args.emulator, args.output)
    previous = ''
    sources = sorted(p for p in ROOT.glob('unit-*/steps/*.bas') if p.parent.parent.name in ('unit-05', 'unit-06'))
    try:
        for path in sources:
            source = path.read_text()
            for line in source.splitlines():
                if line not in previous.splitlines():
                    m.statement(line)
            previous = source
            label = path.parent.parent.name + '-' + path.stem
            if 'unit-05' in label:
                stage = int(path.stem[-2:])
                for guess in [4, 7, 9]:
                    m.statement('RUN')
                    m.text(str(guess)); m.enter()
                    response = ['Correct!'] if guess == 7 else (['Too low'] if guess < 7 and stage >= 2 else ['Too high'] if guess > 7 and stage >= 3 else [])
                    m.result(f'{label}-guess-{guess}', ['Guess a whole number 1 to 10'] + response, finished=True)
            else:
                stage = int(path.stem[-2:])
                cases = [['4', '9', '7'], ['7']]
                if stage == 3:
                    cases += [['0', '11', '6.5', '1', '10', '7'], ['1', '7'], ['10', '7'], ['4'] * 25 + ['7']]
                for ci, guesses in enumerate(cases, 1):
                    m.statement('RUN')
                    count = 0
                    for gi, guess in enumerate(guesses, 1):
                        m.text(guess); m.enter()
                        valid = stage < 3 or (1 <= float(guess) <= 10 and float(guess).is_integer())
                        count += valid
                        correct = guess == '7'
                        rows = (['Whole number from 1 to 10'] if not valid else
                                ['Correct!'] + ([f'Guesses: {count}'] if stage >= 2 else []) if correct else
                                ['Too low' if float(guess) < 7 else 'Too high'])
                        m.result(f'{label}-case-{ci}-guess-{gi}', rows, finished=correct, stopped=stage==3)
        m.statement('SAVE "lucky"')
        m.check('save-prompt', ['Start tape, then press any key'], capture=False)
        m.enter(); m.frames(1400)
        m.check('save-complete', ['0 OK'], capture=False)
        m.call('save_tape', path=str(args.output / 'lucky.tap'))
        evidence = m.evidence
        m.close()
        m = Spectrum(args.emulator, args.output)
        m.call('load_media', slot='tape-1', kind='tape', path=str(args.output / 'lucky.tap'))
        m.statement('LOAD "lucky"')
        m.call('media_transport', slot='tape-1', transport='start')
        m.frames(1800)
        m.statement('RUN')
        for guess in ['0', '4', '7']:
            m.text(guess); m.enter()
        m.result('fresh-load-and-play', ['Correct!', 'Guesses: 2'], finished=True, stopped=True)
        result = {'status': 'passed', 'server': m.server,
                  'configuration': 'Spectrum 48K; ROM key entry through MCP; fresh-process named TAP load',
                  'limits': 'No native GUI, native host-key events, audio or original hardware verified.',
                  'binary_sha256': hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(),
                  'source_sha256': {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},
                  'checks': evidence + m.evidence}
        (args.output / 'results.json').write_text(json.dumps(result, indent=2)+'\n')
    finally:
        if m.process.poll() is None:
            m.close()


if __name__ == '__main__':
    main()
