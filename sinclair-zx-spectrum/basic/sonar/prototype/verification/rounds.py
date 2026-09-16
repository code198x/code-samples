#!/usr/bin/env python3
"""ROM execution of remembered probes, fixed rounds and random rounds (stages 4–6)."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

from entry import ROOT, Spectrum
from verify import Review, sha

spec = importlib.util.spec_from_file_location(
    'spectrum_state', ROOT.parents[1] / 'touchdown/prototype/verification/state.py')
state = importlib.util.module_from_spec(spec)
spec.loader.exec_module(state)


class Rounds(Review):
    def __init__(self, executable, output):
        super().__init__(executable, output)
        self.previous = {}
        self.known = {}
        self.latest = None
        self.stage = 4
        self.hashes = {}

    def edit(self, stage):
        source = ROOT / f'steps/step-{stage:02}.bas'
        current = {int(line.split()[0]): line for line in source.read_text().splitlines()}
        for number in self.previous.keys() - current.keys():
            self.machine.statement(str(number))
        for number, line in current.items():
            if self.previous.get(number) != line:
                self.machine.statement(line)
                assert number in self.machine.program_lines(), (line, self.machine.screen())
        assert set(self.machine.program_lines()) == set(current)
        self.previous = current
        self.hashes[str(source.relative_to(ROOT))] = sha(source)
        print('ROM entered stage', stage, flush=True)

    def numeric(self):
        return state.variables(self.machine)

    def capture(self, name):
        # Screen-memory text may be complete before the next emitted video
        # frame. Let the static prompt finish appearing in the capture.
        self.machine.frames(5)
        super().capture(name)

    def board_state(self):
        self.board()
        rows = self.machine.screen()
        assert rows[1].strip() == f'Distinct probes: {len(self.known)}', rows
        for row in range(1, 9):
            for col in range(1, 9):
                value = self.known.get((row, col))
                glyph = '. ' if value is None else (' *' if value == 0 else f'{value:2}')
                marker = '>' if (row, col) == self.latest else ' '
                y, x = 4 + 2*(row-1), 5 + 3*(col-1)
                assert rows[y][x:x+3] == marker + glyph, (row, col, marker + glyph, rows)
        assert self.numeric()['n'] == len(self.known)

    def reset_model(self):
        self.known = {}
        self.latest = None
        self.wait('Row (1-8, Q):')
        self.board_state()
        values = self.numeric()
        assert values['lr'] == values['lc'] == values['pr'] == values['pc'] == 0
        assert 1 <= values['tr'] <= 8 and 1 <= values['tc'] <= 8
        assert values['tr'] == int(values['tr']) and values['tc'] == int(values['tc'])
        assert 'Distance = rows + columns.' in self.machine.screen()[21]

    def start(self):
        self.machine.statement('RUN')
        if self.stage > 4:
            self.wait('ENTER to search, Q quits:')
            self.answer('')
        self.reset_model()

    def probe(self, row, col):
        target = self.numeric()
        expected = len(range(min(row, int(target['tr'])), max(row, int(target['tr']))))
        expected += len(range(min(col, int(target['tc'])), max(col, int(target['tc']))))
        repeated = (row, col) in self.known
        self.wait('Row (1-8, Q):')
        self.answer(str(row))
        self.wait('Column (1-8, Q):')
        self.answer(str(col))
        self.wait('R another round, Q quits:' if expected == 0 and self.stage > 4 else 'Row (1-8, Q):')
        self.known[(row, col)] = expected
        self.latest = (row, col)
        self.board_state()
        status = self.machine.screen()[21]
        expected_status = (f'Found in {len(self.known)} distinct probes.' if expected == 0
                           else 'Already probed. No extra count.' if repeated
                           else f'Distance {expected}: rows + columns')
        assert expected_status in status, (expected_status, status)
        return expected

    def invalid(self, phase, text):
        before = self.numeric()
        self.answer(text)
        self.wait(phase)
        self.board_state()
        after = self.numeric()
        for name in ['tr', 'tc', 'n', 'lr', 'lc', 'pr']:
            assert before[name] == after[name], (name, before, after)

    def solve(self):
        # Use displayed clues to choose a third probe. Target reads above only
        # verify the result; this strategy does not use them to choose a cell.
        if self.probe(1, 1) == 0:
            return
        if self.probe(1, 8) == 0:
            return
        d1, d2 = self.known[(1, 1)], self.known[(1, 8)]
        candidates = [(r, c) for r in range(1, 9) for c in range(1, 9)
                      if r-1+c-1 == d1 and r-1+8-c == d2]
        assert len(candidates) == 1
        assert self.probe(*candidates[0]) == 0

    def replay(self, key='r'):
        self.answer(key)
        self.reset_model()

    def save_round(self, stage, stored):
        name = f'sonar{stage}'
        assert self.machine.program_lines() == stored
        self.machine.statement(f'SAVE "{name}" LINE 10')
        self.machine.enter()
        self.wait('0 OK', limit=16000)
        tape = self.output / f'{name}.tap'
        self.machine.call('save_tape', path=str(tape))
        self.tapes.append({'stage': stage, 'file': tape.name, 'sha256': sha(tape)})
        self.machine.close()
        self.machine = Spectrum(self.executable, self.output)
        self.machine.call('load_media', slot='tape-1', kind='tape', path=str(tape))
        self.machine.statement(f'LOAD "{name}"')
        self.machine.call('media_transport', slot='tape-1', transport='start')
        self.wait('ENTER to search, Q quits:' if stage > 4 else 'Row (1-8, Q):', limit=16000)
        assert self.machine.program_lines() == stored
        if stage > 4:
            self.answer('')
        self.reset_model()
        self.solve()
        if stage > 4:
            self.replay()
            self.solve()
        self.quit()
        suffix = 'play-retry-exit' if stage > 4 else 'play-exit'
        self.record(f'stage-{stage}-ROM-save-fresh-load-{suffix}')

    def execute(self):
        rom = []
        for address in range(0, 16384, 128):
            rom += self.machine.call('memory_read', addr=address, len=128)['bytes']
        for stage in [4, 5, 6]:
            self.stage = stage
            self.edit(stage)
            stored = self.machine.program_lines()
            self.start()
            if stage == 4:
                self.probe(1, 2)
                self.probe(8, 8)
                self.probe(1, 2)
                self.probe(1, 2)
                self.record('repeated-and-consecutive-probes-preserve-count')
                self.capture('stage-04-remembered')
                for text in ['', '0', '9', '-1', '1.5', 'x', '1+1', ' 2', '2 ', '1'*40, '1'*80]:
                    self.invalid('Row (1-8, Q):', text)
                self.answer('3')
                self.wait('Column (1-8, Q):')
                for text in ['', '0', '9', '1.5', 'x', '1+1', '1'*80]:
                    self.invalid('Column (1-8, Q):', text)
                self.answer('6')
                self.wait('Found in')
                self.known[(3, 6)] = 0
                self.latest = (3, 6)
                self.board_state()
                self.record('invalid-input-preserves-history-count-target-and-selected-row')
                self.probe(3, 6)
                self.record('repeated-hit-counted-once')
                # Destroy only the display, then rebuild through a direct ROM
                # command. No memory injection or program edits are used.
                self.quit()
                before = self.numeric()
                self.machine.statement('CLS')
                self.machine.statement('GO SUB 1000')
                self.machine.frames(400)
                self.board_state()
                after = self.numeric()
                for name in ['tr', 'tc', 'n', 'lr', 'lc']:
                    assert before[name] == after[name]
                self.capture('stage-04-redrawn')
                self.machine.statement('GO TO 100')
                self.wait('Row (1-8, Q):')
                self.record('CLS-and-full-redraw-from-array-without-state-change')
                for row in range(1, 9):
                    for col in range(1, 9):
                        self.probe(row, col)
                assert len(self.known) == 64
                self.capture('stage-04-all-cells')
                self.record('all-64-clues-retained-and-counted-once')
                self.quit()
                self.start()
                self.record('RUN-clears-complete-probe-history')
                self.answer('8')
                self.wait('Column (1-8, Q):')
                self.quit('Q')
                self.record('stage-4-quit-column')
            else:
                if stage == 5:
                    self.solve()
                    self.capture('stage-05-found')
                    for text in ['', 'x', 'rr', '1'*80]:
                        self.invalid('R another round, Q quits:', text)
                    self.record('invalid-retry-retains-winning-board-and-count')
                    for key in ['r', 'R', 'r']:
                        self.replay(key)
                        assert self.numeric()['tr'] == 3 and self.numeric()['tc'] == 6
                        self.solve()
                    self.record('three-fixed-site-retries-no-state-leaks')
                    self.quit('Q')
                    self.machine.statement('RUN')
                    self.wait('ENTER to search, Q quits:')
                    self.capture('stage-05-instructions')
                    for text in ['x', '1'*80]:
                        self.answer(text)
                        self.wait('ENTER to search, Q quits:')
                        assert self.has('Clues count rows plus columns.')
                    self.quit()
                    self.record('invalid-title-and-title-quit')
                    self.start()
                    self.quit()
                    self.start()
                    self.answer('4')
                    self.wait('Column (1-8, Q):')
                    self.quit()
                    self.record('fixed-round-quit-row-and-column')
                else:
                    rounds = []
                    for index in range(12):
                        values = self.numeric()
                        target = [values['tr'], values['tc']]
                        self.solve()
                        rounds.append({'target': target, 'probes': [[*cell, value] for cell, value in self.known.items()]})
                        if index == 0:
                            self.capture('stage-06-found')
                        self.replay()
                    assert len({tuple(r['target']) for r in rounds}) > 1
                    self.capture('stage-06-new-round')
                    self.record('twelve-random-rounds-range-counts-retries', rounds=rounds,
                                limitation='Observed rounds do not establish uniformity or human replay value.')
                    self.quit()
            self.save_round(stage, stored)
        result = {'status': 'passed', 'server': self.machine.server,
                  'configuration': 'Stock 48K ZX Spectrum, PAL; ROM entry and MCP keyboard events',
                  'binary_sha256': sha(Path(self.executable)),
                  'rom_sha256': hashlib.sha256(bytes(rom)).hexdigest(),
                  'sources': self.hashes, 'tapes': self.tapes, 'checks': self.cases,
                  'limits': 'No new native host-keyboard, original-hardware or human replay-value acceptance. No audio added.'}
        (self.output / 'rounds-results.json').write_text(json.dumps(result, indent=2) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    review = Rounds(args.emulator, args.output)
    try:
        review.execute()
    except Exception:
        review.capture('failure')
        (args.output / 'partial-rounds-results.json').write_text(json.dumps(review.cases, indent=2) + '\n')
        raise
    finally:
        review.machine.close()


if __name__ == '__main__':
    main()
