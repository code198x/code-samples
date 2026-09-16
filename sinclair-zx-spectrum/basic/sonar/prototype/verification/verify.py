#!/usr/bin/env python3
"""Execute Sonar stages 1–3 via ROM keys, then save and fresh-load native-play tapes.

No program/state injection. Declared target edits are typed into the ROM editor
and removed before saving. Screen and ROM memory reads are observation only.
"""
import argparse
import hashlib
import json
from pathlib import Path

from entry import ROOT, Spectrum


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Review:
    def __init__(self, executable, output):
        self.executable = executable
        self.output = output
        self.machine = Spectrum(executable, output)
        self.cases = []
        self.tapes = []

    def has(self, text):
        return any(text in row for row in self.machine.screen())

    def wait(self, text, limit=2000):
        for _ in range(limit // 10):
            if self.has(text):
                return
            self.machine.frames(10)
        raise AssertionError((text, self.machine.screen()))

    def record(self, name, **details):
        self.cases.append({'check': name, **details})
        print('PASS', name, flush=True)

    def capture(self, name):
        self.machine.call('save_screenshot', path=str(self.output / (name + '.png')))

    def board(self):
        rows = self.machine.screen()
        for cell in range(1, 9):
            assert rows[2][6 + 3 * (cell-1)] == str(cell), rows
            assert rows[4 + 2 * (cell-1)][2] == str(cell), rows
        for row in [3, 20]:
            assert rows[row][4:30] == '+------------------------+', rows
        for row in range(4, 20):
            assert rows[row][4] == ':' and rows[row][29] == ':', rows

    def answer(self, text):
        self.machine.text(text)
        self.machine.enter()
        self.machine.frames(30)

    def probe(self, row, col, expected, stage=3):
        self.wait('Row (1-8, Q):')
        self.answer(str(row))
        self.wait('Column (1-8, Q):')
        self.answer(str(col))
        self.wait('Row (1-8, Q):')
        rows = self.machine.screen()
        value = ' *' if expected == 0 else (f'{expected:2}' if stage == 3 else ' -')
        y, x = 4 + 2 * (row-1), 5 + 3 * (col-1)
        assert rows[y][x:x+3] == '>' + value, (row, col, expected, rows)
        assert sum(line.count('>') for line in rows[:21]) == 1, rows
        result = 'Found!' if expected == 0 else (f'Distance {expected}:' if stage == 3 else 'Miss.')
        assert result in rows[21], rows
        self.board()

    def quit(self, key='q'):
        self.answer(key)
        self.wait('9 STOP')
        assert self.has('Finished.'), self.machine.screen()

    def run(self):
        self.machine.statement('RUN')
        self.wait('Row (1-8, Q):')
        self.board()

    def invalid_inputs(self):
        # LINE input must reject expressions too; VAL must see only one digit.
        for prompt in ['Row', 'Column']:
            if prompt == 'Column':
                self.answer('3')
            for invalid in ['', '0', '9', '-1', '1.5', 'x', '18', '1+1', ' 2', '2 ', '"', '1' * 40, '1' * 80]:
                self.answer(invalid)
                self.wait(prompt + ' (1-8, Q):')
                assert self.has('Use one digit from 1 to 8.'), self.machine.screen()
                self.board()
                # Invalid input must preserve the latest marker as well as labels.
                assert sum(line.count('>') for line in self.machine.screen()[:21]) == 1
                self.record('reject-' + prompt.lower(), input=invalid)
        self.answer('6')
        self.wait('Found!')
        self.record('valid-hit-after-rejected-input')

    def save(self, stage, expected_lines):
        name = f'sonar{stage}'
        assert self.machine.program_lines() == expected_lines, 'Stored source changed before tape save'
        self.machine.statement(f'SAVE "{name}" LINE 10')
        self.machine.enter()
        self.wait('0 OK', limit=12000)
        tape = self.output / f'{name}.tap'
        self.machine.call('save_tape', path=str(tape))
        self.tapes.append({'stage': stage, 'file': tape.name, 'sha256': sha(tape)})
        self.record('ROM-save-' + name)
        self.machine.close()
        self.machine = Spectrum(self.executable, self.output)
        self.machine.call('load_media', slot='tape-1', kind='tape', path=str(tape))
        self.machine.statement(f'LOAD "{name}"')
        self.machine.call('media_transport', slot='tape-1', transport='start')
        self.wait('9 STOP' if stage == 1 else 'Row (1-8, Q):', limit=12000)
        assert self.machine.program_lines() == expected_lines, 'Fresh-loaded program differs'
        self.board()
        if stage > 1:
            self.probe(1, 2, 6 if stage == 3 else 1, stage)
            self.probe(3, 6, 0, stage)
            self.quit()
        self.record('fresh-process-autoload-' + name)

    def execute(self):
        server = self.machine.server
        rom = []
        for address in range(0, 16384, 128):
            rom += self.machine.call('memory_read', addr=address, len=128)['bytes']
        sources = {}
        for stage in [1, 2, 3]:
            if stage > 1:
                self.machine.close()
                self.machine = Spectrum(self.executable, self.output)
            source = ROOT / f'steps/step-{stage:02}.bas'
            sources[str(source.relative_to(ROOT))] = sha(source)
            self.machine.load_source(source)
            stored = self.machine.program_lines()
            self.machine.statement('RUN')
            self.wait('9 STOP' if stage == 1 else 'Row (1-8, Q):')
            self.board()
            if stage == 1:
                rows = self.machine.screen()
                assert rows[8][20:23] == ' X ', rows
                assert rows[18][26:29] == '>14', rows
                self.capture('stage-01-layout')
                self.record('visible-target-two-digit-layout')
            else:
                self.capture(f'stage-{stage:02}-opening')
                if stage == 2:
                    self.probe(1, 2, 1, stage)
                    self.probe(3, 6, 0, stage)
                    self.answer('1' * 40)
                    self.wait('Row (1-8, Q):')
                    self.board()
                    assert self.machine.screen()[8][20:23] == '> *'
                    self.capture('stage-02-hit')
                    self.record('fixed-target-hit-and-miss-with-long-input-recovery')
                else:
                    rows = self.machine.screen()
                    assert rows[8][20:23] == ' . ', rows
                    self.probe(1, 2, 6)
                    self.capture('stage-03-worked-example')
                    self.record('worked-example', probe=[1, 2], target=[3, 6], distance=6)
                    # Count horizontal and vertical steps independently of BASIC's ABS expression.
                    distances = []
                    for row in range(1, 9):
                        for col in range(1, 9):
                            distance = len(range(min(row, 3), max(row, 3))) + len(range(min(col, 6), max(col, 6)))
                            self.probe(row, col, distance)
                            distances.append([row, col, distance])
                    self.record('all-64-cells-fixed-target', target=[3, 6], probes=distances)
                    self.probe(8, 8, 7)
                    self.record('repeated-probe-same-distance')
                    self.invalid_inputs()
                self.quit()
                self.record(f'stage-{stage}-quit-row')
                self.run()
                self.answer('8')
                self.wait('Column (1-8, Q):')
                self.quit('Q')
                self.record(f'stage-{stage}-quit-column-uppercase')
                if stage == 3:
                    # Isolate max distance and reversed coordinate differences with ROM edits.
                    for target in [1, 8]:
                        self.machine.statement(f'20 LET tr = {target}: LET tc = {target}')
                        self.run()
                        opposite = 9-target
                        self.probe(opposite, opposite, 14)
                        self.capture(f'stage-03-distance-14-target-{target}')
                        self.probe(target, target, 0)
                        self.quit()
                        self.record('edited-corner-target', line=f'20 LET tr = {target}: LET tc = {target}', probes=[[opposite, opposite, 14], [target, target, 0]])
                    self.machine.statement('20 LET tr = 3: LET tc = 6')
                    assert self.machine.program_lines() == stored
                    self.run()
                    self.probe(1, 1, 7)
                    self.probe(1, 8, 4)
                    self.probe(3, 6, 0)
                    self.capture('stage-03-found')
                    self.quit()
                    self.record('two-clue-shortcut', probes=[[1, 1, 7], [1, 8, 4], [3, 6, 0]], interpretation='Scripted coordinate deduction, not human play evidence')
            self.save(stage, stored)
        result = {
            'status': 'passed', 'server': server,
            'configuration': 'Stock 48K ZX Spectrum, PAL, configured 16 KiB ROM; MCP keyboard events',
            'binary_sha256': sha(Path(self.executable)),
            'rom_sha256': hashlib.sha256(bytes(rom)).hexdigest(),
            'sources': sources, 'tapes': self.tapes, 'checks': self.cases,
            'limits': 'Stages 1–3 only. Latest probe only; no array, distinct-probe count, random target, replay menu or sound. No native host-event, human play or original-hardware acceptance.'
        }
        (self.output / 'results.json').write_text(json.dumps(result, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    review = Review(args.emulator, args.output)
    try:
        review.execute()
    except Exception:
        review.capture('failure')
        (args.output / 'partial-results.json').write_text(json.dumps(review.cases, indent=2) + '\n')
        raise
    finally:
        review.machine.close()


if __name__ == '__main__':
    main()
