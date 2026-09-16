#!/usr/bin/env python3
"""Compare distance bands through ROM editing, play, SAVE and fresh LOAD.

Requires the verified stage-six tape. Target edits for boundary checks are
entered through the ROM editor and restored before saving the experiment.
"""
import argparse
import json
from collections import Counter
from pathlib import Path
from entry import ROOT, Spectrum
from rounds import Rounds
from verify import sha

CELLS = [(r, c) for r in range(1, 9) for c in range(1, 9)]


def clue(probe, target):
    distance = sum(abs(a-b) for a, b in zip(probe, target))
    return 0 if distance == 0 else 1 if distance <= 2 else 2 if distance <= 4 else 3


def choose(candidates, used):
    # Minimise the largest remaining group; prefer a possible discovery on ties.
    def score(probe):
        groups = Counter(clue(probe, target) for target in candidates)
        return max(groups.values()), sum(n*n for n in groups.values()), probe not in candidates, probe
    return min((cell for cell in CELLS if cell not in used), key=score)


class Bands(Rounds):
    def reset_model(self):
        self.known = {}
        self.latest = None
        self.wait('Row (1-8, Q):')
        self.board_state()
        assert 'N=1-2, M=3-4, F=5+ steps.' in self.machine.screen()[21]

    def board_state(self):
        self.board()
        rows = self.machine.screen()
        assert rows[1].strip() == f'Distinct probes: {len(self.known)}', rows
        for row, col in CELLS:
            value = self.known.get((row, col))
            glyph = '. ' if value is None else [' *', ' N', ' M', ' F'][value]
            marker = '>' if (row, col) == self.latest else ' '
            y, x = 4 + 2*(row-1), 5 + 3*(col-1)
            assert rows[y][x:x+3] == marker + glyph, (row, col, rows)
        assert self.numeric()['n'] == len(self.known)

    def probe(self, row, col):
        target = self.numeric()
        expected = clue((row, col), (target['tr'], target['tc']))
        repeated = (row, col) in self.known
        self.wait('Row (1-8, Q):')
        self.answer(str(row))
        self.wait('Column (1-8, Q):')
        self.answer(str(col))
        self.wait('R another round, Q quits:' if expected == 0 else 'Row (1-8, Q):')
        self.known[(row, col)] = expected
        self.latest = (row, col)
        self.board_state()
        status = (f'Found in {len(self.known)} distinct probes.' if expected == 0
                  else 'Already probed. No extra count.' if repeated
                  else ['', 'Near: 1 or 2 steps away.', 'Medium: 3 or 4 steps away.', 'Far: at least 5 steps away.'][expected])
        assert status in self.machine.screen()[21], self.machine.screen()
        return expected

    def solve(self):
        candidates = CELLS.copy()
        used = set()
        trace = []
        while candidates:
            probe = choose(candidates, used)
            result = self.probe(*probe)
            used.add(probe)
            candidates = [target for target in candidates if clue(probe, target) == result]
            trace.append({'probe': probe, 'clue': result, 'remaining': len(candidates)})
            assert candidates
            if result == 0:
                return trace
        raise AssertionError('No candidates')

    def execute_bands(self, baseline):
        recorded = json.loads((ROOT/'verification/rounds-results.json').read_text())
        expected = next(t['sha256'] for t in recorded['tapes'] if t['stage'] == 6)
        assert sha(baseline) == expected, 'Baseline tape differs from verified stage six'
        source = ROOT/'experiments/distance-bands.bas'
        original = ROOT/'steps/step-06.bas'
        assert sha(original) == recorded['sources']['steps/step-06.bas']
        old = {int(s.split()[0]): s for s in original.read_text().splitlines()}
        new = {int(s.split()[0]): s for s in source.read_text().splitlines()}
        self.machine.call('load_media', slot='tape-1', kind='tape', path=str(baseline))
        self.machine.statement('LOAD "sonar6"')
        self.machine.call('media_transport', slot='tape-1', transport='start')
        self.wait('ENTER to search, Q quits:', limit=16000)
        self.quit()
        before = self.machine.program_lines()
        for number in old.keys() - new.keys():
            self.machine.statement(str(number))
        for number, line in new.items():
            if old.get(number) != line:
                self.machine.statement(line)
        stored = self.machine.program_lines()
        assert set(stored) == set(new)
        for number in old.keys() & new.keys():
            assert (before[number] == stored[number]) == (old[number] == new[number]), number
        self.record('ROM-edit-verified-baseline', changed_lines=[n for n in new if new[n] != old.get(n)])
        self.stage = 6
        self.machine.statement('20 LET tr = 1: LET tc = 1')
        self.start()
        for col in [2, 3, 4, 5, 6, 8]:
            self.probe(1, col)
        self.probe(8, 8)
        self.probe(1, 2)
        self.invalid('Row (1-8, Q):', '1'*80)
        self.capture('bands-boundaries')
        self.probe(1, 1)
        self.invalid('R another round, Q quits:', 'x')
        self.replay('R')
        self.quit()
        self.record('distances-1-2-3-4-5-7-14-hit-repeat-long-input-replay')
        self.machine.statement(new[20])
        assert self.machine.program_lines() == stored
        self.start()
        rounds = []
        for _ in range(8):
            rounds.append(self.solve())
            if len(rounds) == 1:
                self.capture('bands-found')
            self.replay()
        self.quit()
        self.record('eight-random-rounds-solved-from-banded-clues', rounds=rounds)
        self.machine.statement('SAVE "sonarband" LINE 10')
        self.machine.enter()
        self.wait('0 OK', limit=16000)
        tape = self.output/'sonar-bands.tap'
        self.machine.call('save_tape', path=str(tape))
        self.machine.close()
        self.machine = Spectrum(self.executable, self.output)
        self.machine.call('load_media', slot='tape-1', kind='tape', path=str(tape))
        self.machine.statement('LOAD "sonarband"')
        self.machine.call('media_transport', slot='tape-1', transport='start')
        self.wait('ENTER to search, Q quits:', limit=16000)
        assert self.machine.program_lines() == stored
        self.machine.frames(100)
        self.capture('bands-instructions')
        self.answer('')
        self.reset_model()
        self.solve()
        self.replay()
        self.quit()
        self.record('ROM-save-fresh-load-play-retry-exit')
        result = {'status': 'passed', 'server': self.machine.server,
                  'configuration': recorded['configuration'], 'rom_sha256': recorded['rom_sha256'],
                  'binary_sha256': sha(Path(self.executable)), 'baseline_tape_sha256': expected,
                  'source_sha256': sha(source), 'tape_sha256': sha(tape), 'checks': self.cases,
                  'limits': 'Scripted play verifies rules, not human enjoyment or original hardware.'}
        (self.output/'bands-results.json').write_text(json.dumps(result, indent=2)+'\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output = args.output.resolve()
    args.output.mkdir(parents=True, exist_ok=True)
    review = Bands(args.emulator, args.output)
    try:
        review.execute_bands(args.baseline.resolve())
    except Exception:
        review.capture('bands-failure')
        raise
    finally:
        review.machine.close()
