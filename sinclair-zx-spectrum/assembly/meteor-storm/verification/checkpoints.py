"""Build every teaching checkpoint and exercise it with ordinary keyboard input.

No state writes or CPU stepping. A separate independent course model chooses
safe steering; it does not implement drawing, instructions or interrupt timing.
"""
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

transport = load('transport', ROOT.parents[1] / 'basic/meet-basic/opening/verification/verify.py')
art = load('art', ROOT / 'assets.py')

def route(events):
    tracks = {}
    spawn = 20
    end = 0
    for x, speed, delay, drift, kind in events:
        tick, y = spawn, 24
        while y < 174:
            tracks.setdefault(tick, []).append((x, y, kind))
            if kind == 1 and tick % 4 == 0:
                x += drift
                if x < 8:
                    x, drift = 8, 1
                if x > 224:
                    x, drift = 224, -1
            y += speed
            tick += 1
        end = max(end, tick)
        spawn += delay
    paths = {116: (0, [])}
    for tick in range(1, end + 1):
        objects = tracks.get(tick, [])
        danger = [x for x, y, kind in objects if kind == 1 and 146 <= y < 174]
        following = {}
        for old, (reward, path) in paths.items():
            for action in (0, -2, 2):
                x = max(8, min(224, old + action))
                if all(abs(x - meteor) >= 22 for meteor in danger):
                    bonus = sum(abs(x - sx) < 12 and 156 <= sy < 169
                                for sx, sy, kind in objects if kind == 2)
                    candidate = (reward + bonus, path + [x])
                    if x not in following or candidate[0] > following[x][0]:
                        following[x] = candidate
        assert following, ('model has no safe route', tick)
        paths = following
    return [116] + max(paths.values(), key=lambda value: value[0])[1]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--pasmo', help='Optional upstream Pasmo executable for binary parity')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    report = {'method': 'Snapshot execution, ordinary PAL frames, keyboard input and read-only state probes.',
              'emulator_sha256': hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(), 'assembler_version': subprocess.run(['asm198x', '--version'], capture_output=True, text=True, check=True).stdout.strip(), 'programs': []}
    for directory in sorted((ROOT / 'checkpoints').iterdir()):
        name = directory.name
        target = out / name
        target.mkdir(exist_ok=True)
        source = directory / 'meteor-storm.asm'
        entry = {'name': name, 'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(), 'checks': []}
        if (directory / 'assets.inc').exists():
            entry['assets_sha256'] = hashlib.sha256((directory / 'assets.inc').read_bytes()).hexdigest()
        def check(label, condition, detail=None):
            assert condition, (name, label, detail)
            entry['checks'].append({'check': label, 'detail': detail})
            print('PASS', name, label, flush=True)
        for flag, extension in [('--sna', 'sna'), ('--tapbas', 'tap'), ('', 'bin')]:
            subprocess.run(['asm198x', '--dialect', 'pasmonext', '--cpu', 'z80', *([flag] if flag else []),
                            '--sym=' + str(target / 'symbols.sym'), str(source), '-o',
                            str(target / ('program.' + extension))], check=True, capture_output=True)
        binary = (target / 'program.bin').read_bytes()
        entry['binary_sha256'] = hashlib.sha256(binary).hexdigest()
        entry['binary_bytes'] = len(binary)
        if args.pasmo:
            subprocess.run([args.pasmo, str(source), str(target / 'pasmo.bin')],
                           cwd=directory, check=True, capture_output=True)
            check('upstream Pasmo machine code matches', (target / 'program.bin').read_bytes() == (target / 'pasmo.bin').read_bytes())
        symbols = {m[1]: int(m[2], 16) for line in (target / 'symbols.sym').read_text().splitlines()
                   if (m := re.match(r'(\w+) = \$(\w+)', line))}
        m = transport.Spectrum(args.emulator, target)
        def read(label, size=1):
            return int.from_bytes(bytes(m.call('memory_read', addr=symbols[label], len=size)['bytes']), 'little')
        def key(key_name, down):
            m.call('input', events=[{'Key': {'name': key_name, 'pressed': down}}])
        def boot():
            m.call('load_snapshot', path=str(target / 'program.sna'))
            m.frames(8)
        try:
            boot()
            if name in ('one-row-shift', 'eight-shifts'):
                pairs = [m.call('memory_read', addr=0x480c + i * 256, len=2)['bytes']
                         for i in range(2 if name == 'one-row-shift' else 8)]
                expected = [[(0x8100 >> i) >> 8, (0x8100 >> i) & 255] for i in range(len(pairs))]
                check('shift carries pixels across byte boundary', pairs == expected, pairs)
            elif name in ('interrupt-clock', 'half-rate-clock'):
                before = read('updates', 2)
                m.frames(600)
                delta = (read('updates', 2) - before) & 65535
                check('counter survives byte wrap at the intended rate', delta == (600 if name == 'interrupt-clock' else 300), delta)
            elif name in ('pixel-motion', 'clocked-steering'):
                m.call('press_keys', keys=['o', 'p'], hold_frames=30)
                check('opposing keys cancel', read('ship_x') == 116)
                m.call('press_key', key='o', hold_frames=240)
                check('left bound', read('ship_x') == 8)
                # No trails anywhere across the ship's sixteen scanlines.
                for row, bits in enumerate(art.SHIP):
                    y = 160 + row
                    address = 0x4000 | ((y & 0xc0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2)
                    actual = m.call('memory_read', addr=address, len=32)['bytes']
                    expected = [0] + list((bits << 8).to_bytes(4, 'big')) + [0] * 27
                    check('ship row restored without trails ' + str(row), actual == expected)
                m.call('press_key', key='p', hold_frames=460)
                check('right bound', read('ship_x') == 224)
                if name == 'clocked-steering':
                    before = read('updates')
                    m.frames(600)
                    check('25Hz movement clock survives wrap', (read('updates') - before) & 255 == 300 & 255)
                m.call('press_key', key='r', hold_frames=4)
                m.frames(4)
                check('restart restores ship', read('ship_x') == 116)
            elif name in ('one-meteor', 'first-dodge'):
                m.frames(110)
                check('idle contact outcome', read('phase') == (2 if name == 'first-dodge' else 3), read('phase'))
                before = read('updates')
                m.frames(30)
                check('result freezes movement', read('updates') == before)
                m.call('press_key', key='r', hold_frames=4)
                m.call('press_key', key='o', hold_frames=34)
                m.frames(90)
                check('steering produces a clean pass', read('phase') == 3, read('ship_x'))
            else:
                number = art.CHECKPOINTS.index(name) + 1
                if name == 'finished':
                    m.call('press_key', key='space', hold_frames=3)
                    m.frames(4)
                check('enters flight', read('phase') == 1)
                # First verify an ordinary loss, then restart before the safe route.
                m.frames(2200)
                check('idle course loses on first impact', read('phase') == 2 and read('hull') == 0)
                m.call('press_key', key='r', hold_frames=3)
                m.frames(4)
                check('retry clears run state', read('phase') == 1 and read('ship_x') == 116 and read('wave') == 0)
                events = [(80, 2, 20, 0, 1), (116, 3, 20, 0, 1), (170, 4, 20, 0, 1)] if number == 5 else art.EVENTS
                if number < 8:
                    events = [e for e in events if e[4] == 1]
                if number < 7:
                    events = [(x, speed, delay, 0, kind) for x, speed, delay, drift, kind in events]
                positions = route(events)
                if number >= 10:
                    key('Space', True)
                last = None
                cadence = set()
                last_event_still_active = False
                for frame in range(3500):
                    if read('phase') != 1:
                        break
                    tick, x = read('ticks', 2), read('ship_x')
                    target_x = positions[min(tick + 1, len(positions) - 1)]
                    action = 'P' if target_x > x else 'O' if target_x < x else None
                    if action != last:
                        if last:
                            key(last, False)
                        if action:
                            key(action, True)
                        last = action
                    cadence.add(read('frame_delta'))
                    if read('wave') == len(events) and read('active_count'):
                        last_event_still_active = True
                    m.frames(1)
                if last:
                    key(last, False)
                key('Space', False)
                check('keyboard route finishes alive', read('phase') == 3 and read('hull') == 1, {'phase': read('phase'), 'frames': frame})
                check('completion waits beyond final spawn', last_event_still_active and read('active_count') == 0 and read('wave') == len(events))
                check('bounded object pool', read('pool_overflow') == 0)
                check('measured update cadence', (4 in cadence if name == 'boost' else cadence <= {0, 1, 2}), sorted(cadence))
                if number >= 8:
                    check('route collects stars', read('score') > 0, read('score') * 10)
                if number >= 9:
                    check('PAL elapsed clock advances', read('elapsed', 2) > 500, read('elapsed', 2))
            m.call('save_screenshot', path=str(target / 'screen.png'))
        finally:
            m.close()
        report['programs'].append(entry)
        (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')

if __name__ == '__main__':
    main()
