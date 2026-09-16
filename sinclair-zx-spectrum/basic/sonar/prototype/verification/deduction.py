#!/usr/bin/env python3
"""Enumerate the information supplied by two exact top-corner clues.

This checks the proposed rule mathematically. It is not emulator execution or
human play evidence; verify.py separately checks the BASIC implementation.
"""
import json


def distance(first, second):
    return abs(first[0] - second[0]) + abs(first[1] - second[1])


def analyse():
    cells = [(row, col) for row in range(1, 9) for col in range(1, 9)]
    outcomes = []
    for target in cells:
        clues = [distance(target, corner) for corner in [(1, 1), (1, 8)]]
        candidates = [cell for cell in cells
                      if distance(cell, (1, 1)) == clues[0]
                      and distance(cell, (1, 8)) == clues[1]]
        assert candidates == [target], (target, clues, candidates)
        recovered = ((clues[0] + clues[1] - 5) / 2,
                     (clues[0] - clues[1] + 9) / 2)
        assert recovered == target
        outcomes.append({'target': target, 'clues': clues, 'candidates': candidates})
    return {'rule': 'Exact row difference plus column difference on an 8x8 board',
            'corner_probes': [[1, 1], [1, 8]],
            'unique_targets_after_two_clues': len(outcomes),
            'interpretation': 'At most a third probe finds the target. Replay value remains a human question.',
            'outcomes': outcomes}


if __name__ == '__main__':
    print(json.dumps(analyse(), indent=2))
