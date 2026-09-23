#!/usr/bin/env python3
"""Exact-rate listening model of Dash's countdown; not CPU/APU execution."""
import argparse
import csv
import hashlib
import json
import math
from pathlib import Path
import struct
import wave

ROOT = Path(__file__).resolve().parent
BASELINE = 'c167968967e48ee77e54ca540beabe61e7272a9b4c92a7a1ad6528d1b6ed43dc'
SAMPLE_RATE = 48000
PITCH_CLOCK = 1789773  # fixed nominal NTSC reference in BOTH listening models


def phrase(source):
    block = source.split('camptown_phrase:', 1)[1].split('fanfare_phrase:', 1)[0]
    rows = []
    for line in block.splitlines():
        text = line.split(';')[0].strip()
        if text.startswith('.byte '):
            values = [int(x.strip()[1:], 16) if x.strip().startswith('$')
                      else int(x.strip()) for x in text[6:].split(',')]
            assert len(values) == 3
            rows.append(values)
    assert rows[-1] == [0, 0, 255]
    assert all(0 < row[2] < 254 for row in rows[:-1])
    return rows


def ticks(rows, rate):
    # start_phrase sets timer=1, index=0. First service is at t=0 here;
    # the real game waits for its next main-loop call, not necessarily t=0.
    timer, index, update = 1, 0, 0
    trace, events = [], []
    while True:
        before = timer
        timer -= 1
        action = 'hold'
        row_index = None
        if timer == 0:
            row_index = index
            lo, hi, duration = rows[index]
            index += 1
            if duration == 255:
                action = 'loop-boundary'
            else:
                timer = duration
                period = lo + 256 * hi
                action = 'note' if period else 'rest'
                events.append({'row': row_index, 'update': update, 'period': period,
                               'duration_updates': duration})
        trace.append({'update': update, 'requested_seconds': update / rate,
                      'serviced_seconds': update / rate, 'timer_before': before,
                      'timer_after': timer, 'action': action,
                      'row': '' if row_index is None else row_index})
        if action == 'loop-boundary':
            break  # excerpt boundary only; real routine loads row 0 in this call
        update += 1
    # Independent cumulative-duration oracle, rather than another countdown.
    expected = 0
    for event, row in zip(events, rows[:-1], strict=True):
        assert event['update'] == expected
        assert event['period'] == row[0] + 256 * row[1]
        expected += row[2]
    assert update == expected
    return trace, events, expected


def render(events, rate, total, path):
    # Ideal 50% pulse, fixed gain; no NES mixer/filter, envelope or sweep model.
    # Reset phase at each row to make repeated pitches articulated.
    samples = [0] * (SAMPLE_RATE // 4)
    for event in events:
        start = event['update'] * SAMPLE_RATE // rate
        end = (event['update'] + event['duration_updates']) * SAMPLE_RATE // rate
        period = event['period']
        frequency = PITCH_CLOCK / (16 * (period + 1)) if period else 0
        for i in range(end - start):
            value = 6000 if frequency and (i * frequency / SAMPLE_RATE) % 1 < .5 else -6000 if frequency else 0
            samples.append(value)
    samples.extend([0] * (SAMPLE_RATE // 4))
    assert len(samples) == total * SAMPLE_RATE // rate + SAMPLE_RATE // 2
    assert 0 < max(samples) < 32767 and min(samples) > -32768
    with wave.open(str(path), 'wb') as wav:
        wav.setparams((1, 2, SAMPLE_RATE, 0, 'NONE', 'not compressed'))
        wav.writeframes(struct.pack('<' + 'h' * len(samples), *samples))
    return {'seconds_with_padding': len(samples) / SAMPLE_RATE,
            'peak_pcm': max(abs(x) for x in samples),
            'rms_pcm': math.sqrt(sum(x*x for x in samples) / len(samples)),
            'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    source = (ROOT.parent / 'dash.asm').read_bytes()
    assert hashlib.sha256(source).hexdigest() == BASELINE, 'Review model against changed source before updating hash'
    rows = phrase(source.decode())
    args.output.mkdir(parents=True, exist_ok=True)
    results = {'source_sha256': BASELINE, 'scope': 'Host countdown/listening model; no native execution or measured service latency',
               'pitch_clock_hz': PITCH_CLOCK, 'sample_rate': SAMPLE_RATE, 'rates': {}}
    all_events = []
    for rate in (50, 60):
        trace, events, total = ticks(rows, rate)
        with (args.output / f'trace-{rate}.csv').open('w', newline='') as stream:
            writer = csv.DictWriter(stream, fieldnames=list(trace[0]))
            writer.writeheader()
            writer.writerows(trace)
        all_events.append(events)
        results['rates'][rate] = {'phrase_updates': total, 'phrase_seconds': total / rate,
                                  'events': events,
                                  'audio': render(events, rate, total, args.output / f'tempo-{rate}.wav')}
    assert all_events[0] == all_events[1]
    assert sum(row[2] == 6 for row in rows[:-1]) == 1
    (args.output / 'results.json').write_text(json.dumps(results, indent=2) + '\n')
    print(f'PASS: {len(rows)-1} events, {total} updates; same periods and update indices at both rates')
    print(f'Phrase: {total/50:.6f}s at 50; {total/60:.6f}s at 60 (padding excluded)')


if __name__ == '__main__':
    main()
