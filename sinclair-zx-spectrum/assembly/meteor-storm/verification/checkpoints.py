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

def route(events, spawn=20):
    tracks = {}
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

def bitmap_address(y, x=0):
    return ((y & 0xc0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2) | (x >> 3)

def bitmap(m):
    data = []
    for address in range(0x4000, 0x5800, 256):
        data += m.call('memory_read', addr=address, len=256)['bytes']
    return data

def lit_rows(m, rows):
    # Character rows (of eight scanlines) holding any set pixel.
    screen = bitmap(m)
    return [row for row in rows if any(screen[bitmap_address(row * 8 + scan) + col]
                                       for scan in range(8) for col in range(32))]

def text_at(m, row, column, length):
    # Read characters back from the bitmap by matching the ROM font.
    font = []
    for address in range(0x3d00, 0x4000, 256):
        font += m.call('memory_read', addr=address, len=256)['bytes']
    screen = bitmap(m)
    glyphs = {tuple(font[i * 8:i * 8 + 8]): chr(32 + i) for i in range(96)}
    return ''.join(glyphs.get(tuple(screen[bitmap_address(row * 8 + scan) + column + i] for scan in range(8)), '?')
                   for i in range(length))

def attributes_by_row(m):
    # The 768-byte attribute map at $5800, one list of 32 cells per character row.
    data = []
    for address in range(0x5800, 0x5b00, 256):
        data += m.call('memory_read', addr=address, len=256)['bytes']
    return [data[row * 32:row * 32 + 32] for row in range(24)]

def check_bands(m, symbols, check, label):
    """Every cell of each character row holds that row's byte from row_colours."""
    table = m.call('memory_read', addr=symbols['row_colours'], len=24)['bytes']
    rows = attributes_by_row(m)
    check(label, rows == [[byte] * 32 for byte in table],
          {'row_colours': ['$%02X' % byte for byte in table]})

def destroyed_phase(m, read, symbols, check, target):
    """Watch the destroyed phase frame by frame, pressing R and Q during it.

    At each halted frame the debris pieces, drawn from their records, are
    XORed out of the bitmap. What remains is the storm under the debris; it
    must never change, which rules out trails. Frames where the CPU is still
    running an update (the impact sound delays it) are not compared.
    """
    for _ in range(2200):
        if read('hull') == 0:
            break
        m.frames(1)
    while not read('debris_time'):
        m.frames(1)
    check('contact starts the destroyed phase', read('phase') == 2 and read('debris_time') > 0, read('debris_time'))
    check('contact flashes the border', read('border') == symbols['FLASH_BORDER'], read('border'))
    pieces, rows, pool = symbols['DEBRIS'], symbols['DEBRIS_ROWS'], symbols['state_end'] - symbols['objects']
    def objects():
        return m.call('memory_read', addr=symbols['objects'], len=pool)['bytes']
    ticks, frozen = read('ticks', 2), objects()
    start, elapsed, storm, compared, moved, pressed = read('frames'), 0, None, 0, set(), []
    flash_frames, lowest, highest = None, 255, 0
    while read('debris_time'):
        if flash_frames is None and read('border') == 0:
            flash_frames = elapsed
        if m.call('query_cpu')['registers']['halt']:
            screen = bitmap(m)
            records = m.call('memory_read', addr=symbols['debris'], len=4 * pieces)['bytes']
            for piece in range(pieces):
                x, y = records[4 * piece], records[4 * piece + 1]
                moved.add((piece, x, y))
                lowest, highest = min(lowest, y), max(highest, y)
                for row, bits in enumerate(art.DEBRIS[piece][:rows]):
                    for column in range(24):
                        if bits >> (23 - column) & 1:
                            screen[bitmap_address(y + row, x + column)] ^= 0x80 >> ((x + column) & 7)
            storm = storm or screen
            assert screen == storm, ('storm changed under the debris', elapsed)
            compared += 1
        if len(pressed) < 2 and elapsed >= (6, 14)[len(pressed)]:
            key = 'rq'[len(pressed)]
            m.call('press_key', key=key, hold_frames=3)
            pressed.append({'key': key, 'phase': read('phase'), 'debris_time': read('debris_time')})
        else:
            m.frames(1)
        elapsed = (read('frames') - start) & 255
        # Frame 2 is the first with the pieces drawn in place of the ship.
        for frame, label in [(2, 'impact'), (10, 'early'), (24, 'debris'), (44, 'late')]:
            if elapsed == frame:
                m.call('save_screenshot', path=str(target / f'destroyed-{label}.png'))
                if 'row_colours' in symbols and label == 'late':
                    check_bands(m, symbols, check, 'debris changes no attribute')
    records = m.call('memory_read', addr=symbols['debris'], len=4 * pieces)['bytes']
    landed = sum(records[4 * piece + 1] == symbols['DEBRIS_FLOOR'] for piece in range(pieces))
    check('R and Q cannot cut the destroyed phase short', all(p['phase'] == 2 for p in pressed), pressed)
    check('destroyed phase lasts 25 updates', 48 <= elapsed <= 52, {'frames': elapsed})
    check('border flash ends within the phase', flash_frames is not None and read('border') == 0, {'flash_frames': flash_frames})
    check('storm stays frozen and drawn', read('ticks', 2) == ticks and objects() == frozen)
    check('debris moves without trails', compared >= 12 and len(moved) > 3 * pieces, {'compared_frames': compared})
    # The HUD ends at y=24 and the controls line starts at y=184.
    check('debris stays between the HUD and the controls line', lowest >= 24 and highest + rows <= 184,
          {'highest_y': lowest, 'lowest_y': highest, 'landed': landed})
    m.frames(30)
    check('result screen keeps no debris', read('phase') == 2 and read('border') == 0
          and not lit_rows(m, [3, 4, 5, 7, 8, 9, 11, 13, 15, 16, 19, 20, 21, 22, 23]))
    m.call('save_screenshot', path=str(target / 'destroyed-result.png'))

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--pasmo', help='Optional upstream Pasmo 0.5.5 executable for binary parity; its banner is recorded')
    parser.add_argument('--only', nargs='+', help='Run selected named checkpoints')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    report = {'method': 'Snapshot execution, ordinary PAL frames, keyboard input and read-only state probes.',
              'emulator_sha256': hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(), 'programs': []}
    # asm198x prints its version on stderr.
    version = subprocess.run(['asm198x', '--version'], capture_output=True, text=True, check=True)
    report['assembler_version'] = (version.stdout + version.stderr).strip()
    if args.pasmo:
        # Pasmo has no version flag; its usage banner names the build. PasmoNext is a
        # different assembler, so the parity check below would be mislabelled.
        banner = subprocess.run([args.pasmo], capture_output=True, text=True)
        report['pasmo_version'] = (banner.stdout + banner.stderr).strip().splitlines()[0]
        assert report['pasmo_version'].startswith('Pasmo v. 0.5.5'), report['pasmo_version']
    for directory in sorted((ROOT / 'checkpoints').iterdir()):
        name = directory.name
        if args.only and name not in args.only:
            continue
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
            subprocess.run(['asm198x', '--dialect', 'pasmo', '--cpu', 'z80', *([flag] if flag else []),
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
        # From two-byte-score on the score and best score are words, printed by decimal4.
        score_bytes = 2 if 'decimal4' in symbols else 1
        def key(key_name, down):
            m.call('input', events=[{'Key': {'name': key_name, 'pressed': down}}])
        def active():
            # object-records has no count yet: add the three records' active bytes.
            if 'active_count' in symbols:
                return read('active_count')
            return sum(m.call('memory_read', addr=symbols['objects'] + 2 + 4 * i, len=1)['bytes'][0] > 0
                       for i in range(3))
        def boot():
            m.call('load_snapshot', path=str(target / 'program.sna'))
            m.frames(8)
        try:
            boot()
            if name == 'pixel-address':
                check('coordinate maps to expected bitmap byte', read('address', 2) == 0x4801)
                check('pixel pattern reaches that address', m.call('memory_read', addr=0x4801, len=1)['bytes'] == [2])
            elif name == 'draw-ship':
                for row, bits in enumerate(art.SHIP):
                    y = 160 + row
                    address = 0x4000 | ((y & 0xc0) << 5) | ((y & 7) << 8) | ((y & 0x38) << 2)
                    actual = m.call('memory_read', addr=address, len=32)['bytes']
                    check('static ship row ' + str(row), actual == list((bits << 116).to_bytes(32, 'big')))
            elif name in ('one-row-shift', 'eight-shifts'):
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
            elif name == 'phases':
                check('starts at the title', read('phase') == 0)
                m.call('save_screenshot', path=str(target / 'title.png'))
                key('Space', True)
                m.frames(20)
                check('held launch waits for release', read('phase') == 0)
                key('Space', False)
                m.frames(4)
                check('release starts one flight', read('phase') == 1 and read('hull') == 1)
                m.frames(40)
                m.call('save_screenshot', path=str(target / 'play.png'))
                m.frames(70)
                check('idle flight is destroyed', read('phase') == 2 and read('hull') == 0, read('phase'))
                frozen = read('meteor_y')
                m.frames(30)
                check('result freezes movement', read('meteor_y') == frozen)
                m.call('save_screenshot', path=str(target / 'lost.png'))
                m.call('press_key', key='r', hold_frames=4)
                m.frames(4)
                check('retry clears the run block', read('phase') == 1 and read('hull') == 1
                      and read('ship_x') == 116 and read('meteor_y') <= 30, read('meteor_y'))
                m.call('press_key', key='o', hold_frames=34)
                m.frames(90)
                check('steering produces a clean pass', read('phase') == 3 and read('hull') == 1, read('ship_x'))
                m.call('save_screenshot', path=str(target / 'won.png'))
                m.call('press_key', key='q', hold_frames=3)
                m.frames(4)
                check('Q at a result returns to the title', read('phase') == 0)
                m.call('press_key', key='space', hold_frames=3)
                m.frames(10)
                m.call('press_key', key='q', hold_frames=3)
                m.frames(4)
                check('Q in flight returns to the title', read('phase') == 0)
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
                number = art.CHECKPOINTS.index(art.SAME_DATA.get(name, name)) + 1
                if 'row_colours' in symbols:
                    check_bands(m, symbols, check, 'title colours each row from its table byte')
                m.call('press_key', key='space', hold_frames=3)
                m.frames(4)
                check('enters flight', read('phase') == 1)
                if 'row_colours' in symbols:
                    check_bands(m, symbols, check, 'flight colours each row from its table byte')
                # First verify an ordinary loss, then restart before the safe route.
                if 'debris_time' in symbols:
                    destroyed_phase(m, read, symbols, check, target)
                    if 'row_colours' in symbols:
                        check_bands(m, symbols, check, 'result keeps the row colours')
                else:
                    m.frames(2200)
                check('idle course loses on first impact', read('phase') == 2 and read('hull') == 0)
                m.call('press_key', key='r', hold_frames=3)
                m.frames(4)
                check('retry clears run state', read('phase') == 1 and read('ship_x') == 116
                      and ('wave' not in symbols or read('wave') == 0))
                if 'debris_time' in symbols:
                    check('next run starts without debris', read('border') == 0 and not lit_rows(m, range(3, 20)) and not lit_rows(m, [22]))
                # object-pool starts three meteors together; later courses read the event table.
                events = [(80, 2, 0, 0, 1), (116, 3, 0, 0, 1), (170, 4, 0, 0, 1)] if number == 5 else art.EVENTS
                if number < 8:
                    events = [e for e in events if e[4] == 1]
                if number < 7:
                    events = [(x, speed, delay, 0, kind) for x, speed, delay, drift, kind in events]
                # From voyage on each storm has its own course, flown from the centre.
                courses = art.VOYAGE if 'storm' in symbols else [events]
                routes = [route(course, 0 if number == 5 else 20) for course in courses]
                if 'storm' in symbols:
                    # The browser pilot flies the same routes: ship X for each course step.
                    (target / 'routes.json').write_text(json.dumps({'seeds': list(range(1986, 1986 + len(courses))),
                                                                    'routes': routes}) + '\n')
                # Before drift there is no course-step counter to read. Count the
                # even frames that start updates, from a known step: the first
                # event's countdown, or the first meteor's height at speed 2.
                if 'ticks' in symbols:
                    course_step = lambda: read('ticks', 2)
                else:
                    counted = {'step': 20 - read('wave_timer') if 'wave_timer' in symbols
                               else (m.call('memory_read', addr=symbols['objects'] + 1, len=1)['bytes'][0] - 24) // 2,
                               'frame': read('frames')}
                    def course_step():
                        now = read('frames')
                        while counted['frame'] != now:
                            counted['frame'] = (counted['frame'] + 1) & 255
                            counted['step'] += counted['frame'] % 2 == 0
                        return counted['step']
                if number >= 10:
                    key('Space', True)
                last = None
                cadence = set()
                last_event_still_active = False
                band_samples = []
                storm_starts = []
                storm_seconds = []
                score_wrapped = False
                last_score = read('score', score_bytes) if 'storm' in symbols else 0
                interlude_seen = False
                # From storm-bonus on: the score just before each clear space, and each storm's bonus.
                flight_score = 0
                bonuses = []
                if 'row_colours' in symbols:
                    check_bands(m, symbols, check, 'retry restores the row colours')
                    bands = attributes_by_row(m)
                for frame in range(3500 * len(courses)):
                    if read('phase') != 1:
                        break
                    storm = read('storm') if 'storm' in symbols else 0
                    if 'storm' in symbols:
                        if len(storm_starts) == storm:
                            storm_starts.append({'storm': storm + 1, 'ship_x': read('ship_x'),
                                                 'elapsed': read('elapsed', 2), 'ticks': read('ticks', 2),
                                                 'score': read('score', score_bytes) * 10,
                                                 'lit_playfield_rows': lit_rows(m, range(3, 20))})
                            if storm:
                                # `storm` changes before the HUD is redrawn, and a capture shows the
                                # last finished frame: let both catch up first.
                                m.frames(2)
                                m.call('save_screenshot', path=str(target / f'storm-{storm + 1}-start.png'))
                            storm_starts[-1]['hud'] = text_at(m, 0, 22, 9)
                            storm_seconds.append(0)
                        storm_seconds[storm] = max(storm_seconds[storm], read('elapsed', 2) / 50)
                        if storm == 1 and not (target / 'storm-2-flight.png').exists() and read('ticks', 2) >= 400:
                            # Mid-way through the second storm: its own course, not the first one's.
                            m.frames(1)
                            m.call('save_screenshot', path=str(target / 'storm-2-flight.png'))
                        score = read('score', score_bytes)
                        score_wrapped |= score < last_score
                        last_score = score
                        clearing = read('wave') == len(events) and not active()
                        if not clearing:
                            flight_score = score
                        elif 'bonus_storm' in symbols and len(bonuses) == storm and lit_rows(m, [15]):
                            # The interlude is up: the bonus has been added n times and its line printed.
                            bonuses.append({'storm': storm + 1, 'finish_points': read('finish_points'),
                                            'added': score - flight_score, 'line': text_at(m, 12, 5, 20)})
                            if storm == 2:
                                m.frames(1)
                                m.call('save_screenshot', path=str(target / 'interlude-3.png'))
                        if not interlude_seen and storm == 0 and read('wave') == len(events) \
                                and not active() and lit_rows(m, [15]):
                            # The first interlude: CLEAR SPACE, the bonus and NEXT STORM on screen.
                            interlude_seen = True
                            m.frames(1)
                            m.call('save_screenshot', path=str(target / 'interlude.png'))
                    if 'row_colours' in symbols and frame % 100 == 50:
                        band_samples.append(attributes_by_row(m))
                    tick, x = course_step(), read('ship_x')
                    positions = routes[storm]
                    target_x = positions[min(tick + 1, len(positions) - 1)]
                    action = 'P' if target_x > x else 'O' if target_x < x else None
                    if action != last:
                        if last:
                            key(last, False)
                        if action:
                            key(action, True)
                        last = action
                    if 'frame_delta' in symbols:
                        cadence.add(read('frame_delta'))
                    if ('wave' not in symbols or read('wave') == len(events)) and active():
                        last_event_still_active = True
                    m.frames(1)
                if last:
                    key(last, False)
                key('Space', False)
                check('keyboard route finishes alive', read('phase') == 3 and read('hull') == 1, {'phase': read('phase'), 'frames': frame})
                check('completion waits beyond final spawn', last_event_still_active and active() == 0
                      and ('wave' not in symbols or read('wave') == len(events)))
                if 'row_colours' in symbols:
                    check('flight never changes an attribute', band_samples and band_samples == [bands] * len(band_samples),
                          {'sampled_frames': len(band_samples)})
                if 'pool_overflow' in symbols:
                    check('bounded object pool', read('pool_overflow') == 0)
                if 'frame_delta' in symbols:
                    check('measured update cadence', (4 in cadence if name == 'boost' else cadence <= {0, 1, 2}), sorted(cadence))
                if number >= 8:
                    check('route collects stars', read('score', score_bytes) > 0, read('score', score_bytes) * 10)
                if number >= 9:
                    check('PAL elapsed clock advances', read('elapsed', 2) > 500, read('elapsed', 2))
                if 'storm' in symbols:
                    check('the route crosses every storm', read('storm') == len(courses) - 1
                          and len(storm_starts) == len(courses), storm_starts)
                    # The first storm starts at launch, a few frames before the route begins.
                    check('each later storm starts from the centre with the clock and course step at zero',
                          all(s['ship_x'] == 116 and s['elapsed'] < 4 and s['ticks'] < 2 for s in storm_starts[1:]), storm_starts)
                    check('the HUD names each storm', [s['hud'] for s in storm_starts]
                          == ['STORM %d/%d' % (s['storm'], len(courses)) for s in storm_starts], storm_starts)
                    check('each later storm starts on an empty playfield',
                          all(not s['lit_playfield_rows'] for s in storm_starts[1:]), storm_starts)
                    check('each storm fits the two-digit time display', max(storm_seconds) < 100,
                          [round(seconds, 2) for seconds in storm_seconds])
                    check('the interlude shows between storms', interlude_seen)
                    # The browser pilot compares its end state with this one.
                    check('the voyage ends in clear space after the last storm',
                          read('phase') == 3 and read('hull') == 1,
                          {'ticks': read('ticks', 2), 'elapsed': read('elapsed', 2), 'score': read('score', score_bytes),
                           'best_time': read('best_time', 2), 'best_score': read('best_score', score_bytes)})
                    scores = {'storm_start_scores': [s['score'] for s in storm_starts], 'final_score': read('score', score_bytes) * 10}
                    if 'bonus_storm' in symbols:
                        m.frames(10)
                        bonuses.append({'storm': len(courses), 'finish_points': read('finish_points'),
                                        'added': read('score', score_bytes) - flight_score, 'line': text_at(m, 12, 5, 20)})
                        # A star taken on the update that clears the storm adds 1 or 2 more.
                        check('each storm adds its bonus times its number',
                              len(bonuses) == len(courses) and all(
                                  b['finish_points'] > 0 and b['added'] - b['finish_points'] * b['storm'] in (0, 1, 2)
                                  for b in bonuses), bonuses)
                        check('the bonus line shows the bonus and its multiplier',
                              all(b['line'] == 'FINISH BONUS %03d0 X%d' % (b['finish_points'], b['storm']) for b in bonuses),
                              [b['line'] for b in bonuses])
                    if score_bytes == 1:
                        check('the one-byte score wraps past 255', score_wrapped, scores)
                    else:
                        check('the two-byte score counts the whole voyage without wrapping',
                              not score_wrapped and scores['final_score'] > 2550, scores)
                        # Let the result screen finish drawing, then read its score lines back from the bitmap.
                        m.frames(10)
                        shown = {'hud': text_at(m, 2, 1, 11), 'record': text_at(m, 18, 3, 16)}
                        m.call('save_screenshot', path=str(target / 'result.png'))
                        check('decimal4 prints the score and the best score in full', shown ==
                              {'hud': 'SCORE %05d' % scores['final_score'],
                               'record': 'BEST SCORE %05d' % (read('best_score', 2) * 10)}, shown)
            m.call('save_screenshot', path=str(target / 'screen.png'))
        finally:
            m.close()
        report['programs'].append(entry)
        (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')

if __name__ == '__main__':
    main()
