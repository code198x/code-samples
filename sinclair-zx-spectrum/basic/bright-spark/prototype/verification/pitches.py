#!/usr/bin/env python3
"""Measure the four recorded cues; this is a signal check, not listening."""
import argparse
import json
import math
import struct
import wave
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('wav', type=Path)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
with wave.open(str(a.wav)) as w:
    assert w.getnchannels() == 1 and w.getsampwidth() == 2
    rate = w.getframerate()
    samples = struct.unpack('<' + 'h' * w.getnframes(), w.readframes(w.getnframes()))
width = rate // 100
active = []
for i in range(0, len(samples), width):
    window = samples[i:i + width]
    active.append(math.sqrt(sum(x*x for x in window) / len(window)) > 5000)
groups = []
for i, on in enumerate(active):
    if on and (i == 0 or not active[i-1]):
        groups.append([i, i+1])
    elif on:
        groups[-1][1] = i+1
groups = [(s, e) for s, e in groups if e-s >= 5]
assert len(groups) == 4, groups
notes = []
for (start, end), expected in zip(groups, (261.6, 329.6, 392, 523.3)):
    middle = samples[(start+2)*width:(end-2)*width]
    mean = sum(middle) / len(middle)
    crossings = sum(x <= mean < y for x, y in zip(middle, middle[1:]))
    hz = crossings * rate / len(middle)
    assert abs(hz-expected) < 25, (hz, expected)
    notes.append({'start_seconds': start*.01, 'end_seconds': end*.01,
                  'estimated_hz': hz, 'expected_hz_approximately': expected})
a.output.write_text(json.dumps({'status': 'passed',
    'method': '10 ms RMS windows identify four sustained tones; positive mean crossings estimate pitch in their middle. Signal check, not listening. Tolerance 25 Hz for these short windows.',
    'notes': notes}, indent=2) + '\n')
