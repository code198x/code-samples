#!/usr/bin/env python3
"""Does a still ship stay on the screen? Run on the lesson 7 endpoint and lesson 9.

A still ship needs no drawing at all. Two measurements, each with no key held
after S starts the flight:

- Instruction-stepped: how many times the ship routine's PLOT line (3010) runs
  in each pass of the main loop. Every visit toggles the whole ship.
- Ordinary frames: at each video-frame boundary, is the complete ship in the
  display memory, absent, or part-drawn?

The check passes only with no toggles and the ship complete at every frame. It
must fail on `finished` (which erases and redraws on every pass) and pass on
`steady`; the script asserts both, so a check that cannot fail is caught here.
"""
import argparse, importlib.util, json, sys
from pathlib import Path
from PIL import Image
HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
# Two modules are called check: the prototype's endpoint harness, which the
# teaching check imports as `check`, and the teaching check itself.
sys.path[:0] = [str(ROOT.parent / 'prototype/verification'), str(HERE)]
spec = importlib.util.spec_from_file_location('teaching_check', HERE / 'check.py')
teaching = importlib.util.module_from_spec(spec)
spec.loader.exec_module(teaching)
import picture
Review, state, line, sha = teaching.Review, teaching.state, teaching.line, teaching.sha

PASSES = 20
FRAMES = 300


def displayed(path):
    with Image.open(path) as im:
        assert im.size == (352, 296)
        rgb = im.convert('RGB')
        return {(x, 175 - y) for y in range(176) for x in range(256) if rgb.getpixel((48 + x, 48 + y)) != (0, 0, 0)}


def measure(item, exe, evidence, out):
    r = Review(item, exe, evidence)
    try:
        r.load()
        s = state(r.m)
        ship = picture.ship(s, 48, 56, 2)
        whole = {(x, 175 - y) for x, y in r.memory_pixels()}
        background = whole ^ ship
        assert not any(abs(x - 48) <= 8 and abs(y - 56) <= 8 for x, y in r.playfield() ^ ship), 'first ship differs from the model'
        # Ordinary frames come before instruction stepping: after a long
        # stepped run, this emulator's run_frames showed the program standing
        # still for many frames, so samples taken then would see no change.
        # The settle frames below are not sampled; loop_passes proves the
        # program ran while sampling.
        r.m.frames(100)
        first = state(r.m)['steps']
        # Ordinary frames: classify the display memory at each frame boundary.
        counts = {'complete': 0, 'absent': 0, 'part-drawn': 0}
        capture = None
        for frame in range(FRAMES):
            r.m.frames(1)
            memory = {(x, 175 - y) for x, y in r.memory_pixels()}
            kind = 'complete' if memory == background ^ ship else 'absent' if memory == background else 'part-drawn'
            counts[kind] += 1
            want = 'absent' if item['name'] == 'finished' else 'complete'
            if capture is None and kind == want:
                # Keep an original frame only if what was shown matches RAM.
                target = out / f"{item['name']}-still.png"
                r.m.call('save_screenshot', path=str(target))
                if displayed(target) == memory:
                    capture = dict(name=target.name, frame=frame, shows=kind, sha256=sha(target),
                                   scope='Normal video-frame execution; original PNG display area matches the RAM bitmap; no image editing.')
                else:
                    target.unlink()
        assert capture, ('no matching capture', item['name'], counts)
        loop_passes = state(r.m)['steps'] - first
        assert loop_passes >= 10, ('the loop did not run while sampling', loop_passes)
        # Instruction-stepped: count entries to line 3010 over whole passes.
        r.boundary({200})
        toggles, passes, previous = 0, 0, 200
        while passes < PASSES:
            r.m.call('run_until_mem_change', addrs=[23621, 23622], max_steps=200000)
            at = line(r.m)
            if at != previous and at == 3010:
                toggles += 1
            if at != previous and at == 200:
                passes += 1
            previous = at
        s = state(r.m)
        assert (s['x'], s['y'], s['h'], s['vx'], s['vy']) == (48, 56, 2, 0, 0), s
        passed = toggles == 0 and counts['complete'] == FRAMES
        return dict(checkpoint=item['name'], source=item['source'], source_sha256=json.loads((evidence / item['name'] / 'build.json').read_text())['source_sha256'],
                    tape_sha256=sha(evidence / item['name'] / 'drift.tap'), passes=PASSES,
                    ship_toggles=toggles, toggles_per_pass=toggles / PASSES, frames=FRAMES, frame_states=counts, loop_passes_while_sampling=loop_passes,
                    capture=capture, status='passed' if passed else 'failed')
    finally:
        r.m.close()


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--emulator', required=True)
    p.add_argument('--output', type=Path, required=True, help='evidence folder holding finished/ and steady/ tapes')
    a = p.parse_args()
    evidence = a.output.resolve()
    out = evidence / 'redraw'
    out.mkdir(parents=True, exist_ok=True)
    items = {i['name']: i for i in json.loads((ROOT / 'checkpoints.json').read_text())}
    results = [measure(items[name], a.emulator, evidence, out) for name in ('finished', 'steady')]
    for result in results:
        print(result['checkpoint'], result['status'], 'toggles/pass', result['toggles_per_pass'], result['frame_states'], flush=True)
    before, after = results
    assert before['status'] == 'failed' and before['ship_toggles'] == 2 * PASSES, before
    assert after['status'] == 'passed', after
    (out / 'redraw.json').write_text(json.dumps(dict(
        status='passed', binary_sha256=sha(Path(a.emulator)),
        method='Fresh tape loads from the build evidence; S then no key; instruction-stepped line visits; display memory read at ordinary frame boundaries. Frame-boundary samples show what display memory holds then, not every raster line the viewer saw.',
        expectation='finished fails (two whole-ship toggles per still pass); steady passes (none, ship complete at every frame)',
        results=results), indent=2) + '\n')
