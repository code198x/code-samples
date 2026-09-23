#!/usr/bin/env python3
"""Compare retained execution evidence; this does not run an emulator."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name):
    directory = ROOT / 'verification/evidence' / name
    result = json.loads((directory / 'results.json').read_text())
    assert result['status'] == 'passed', name
    for path, key in [(ROOT / result['checkpoint']['source'], 'source_sha256'),
                      (directory / 'tail.tap', 'tape_sha256')]:
        assert hashlib.sha256(path.read_bytes()).hexdigest() == result[key], path
    return result


def inspect_ring(result):
    # Reconstruct physical slots from observed successful moves. These indices
    # are derived from the source algorithm, not separately recorded RAM reads.
    slots = [(8, c) for c in range(6, 10)] + [(0, 0)] * 8
    tail, head, length = 0, 3, 4
    rows = []
    for event in result['trace']:
        before = [slots[(tail + j) % 12] for j in range(length)]
        body = [tuple(cell) for cell in event['body']]
        if event['collision']:
            assert body == before
        else:
            if event['grow']:
                length += 1
            else:
                tail = (tail + 1) % 12
            head = (head + 1) % 12
            slots[head] = body[-1]
        live = [(tail + j) % 12 for j in range(length)]
        assert [slots[j] for j in live] == body
        assert live[-1] == head
        rows.append({'steps': event['steps'], 'derived_live_slots': [j + 1 for j in live],
                     'observed_body': body, 'grow': event['grow'],
                     'collision': event['collision']})
    return rows


def main():
    shift = load('shifted-body')
    ring = load('circular-body')
    food = load('fixed-food')
    diagnostic = load('fixed-food-body-test')
    assert shift['trace'] == ring['trace']
    assert food['trace'][:2] == ring['trace'][:2]
    assert food['trace'] == diagnostic['trace'][:3]
    rows = inspect_ring(ring)
    growth = inspect_ring(diagnostic)
    assert rows[7]['derived_live_slots'] == [9, 10, 11, 12]
    assert rows[8]['derived_live_slots'] == [10, 11, 12, 1]
    assert rows[11]['derived_live_slots'] == [1, 2, 3, 4]
    assert growth[2]['derived_live_slots'] == [3, 4, 5, 6, 7]
    assert growth[-1]['collision']
    assert growth[-1]['observed_body'] == growth[-2]['observed_body']
    print(json.dumps({'method': 'Retained ROM execution traces; source/tape hashes checked. Slot indices reconstructed, not new RAM observations.',
                      'matching_shift_and_ring_events': len(rows),
                      'wrap_examples': [rows[i] for i in (7, 8, 11, 12)],
                      'growth_and_collision': growth[2:]}, indent=2))


if __name__ == '__main__':
    main()
