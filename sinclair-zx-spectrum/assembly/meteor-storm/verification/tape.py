"""Load the loading-screen tape through a fresh 48K ROM, as a reader would.

Builds unit 35's tape with its Makefile, mounts it, types LOAD "" and plays it.
Ordinary frames and read-only probes: no state writes, no snapshot. Checks the
loader blanks the screen, the SCREEN$ lands byte for byte, nothing prints over
it while the game loads, and the game reaches its title.
"""
import argparse
import hashlib
import importlib.util
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('transport', ROOT.parents[1] / 'basic/meet-basic/opening/verification/verify.py')
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)


def looks_black(shown):
    # Every cell shows only black: its INK and PAPER are both black, or it has
    # a visible INK but no lit pixels. Black INK text is drawn but cannot be seen.
    for cell, attribute in enumerate(shown[6144:]):
        ink, paper = attribute & 7, (attribute >> 3) & 7
        if paper:
            return False
        row, column = divmod(cell, 32)
        if ink and any(shown[((row & 0x18) << 8) | ((row & 7) << 5) | (line << 8) | column] for line in range(8)):
            return False
    return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--emulator', required=True)
    parser.add_argument('--build198x', default='build198x', help='build198x executable for the BASIC loader')
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    unit = ROOT / 'unit-35'
    subprocess.run(['make', '-B', 'BUILD198X=' + args.build198x], cwd=unit, check=True, capture_output=True)
    tape = unit / 'meteor-storm.tap'
    source = ROOT / 'checkpoints/loading-screen'
    scr = list((source / 'meteor-storm.scr').read_bytes())
    subprocess.run(['asm198x', '--dialect', 'pasmo', '--cpu', 'z80', '--sym=' + str(out / 'program.sym'),
                    str(source / 'meteor-storm.asm'), '-o', str(out / 'program.bin')], check=True, capture_output=True)
    symbols = {m[1]: int(m[2], 16) for line in (out / 'program.sym').read_text().splitlines()
               if (m := re.match(r'(\w+) = \$(\w+)', line))}
    report = {'method': 'Fresh 48K ROM, LOAD "" from the unit 35 tape, ordinary frames and read-only probes.',
              'tape_sha256': hashlib.sha256(tape.read_bytes()).hexdigest(),
              'scr_sha256': hashlib.sha256(bytes(scr)).hexdigest(),
              'emulator_sha256': hashlib.sha256(Path(args.emulator).read_bytes()).hexdigest(), 'checks': []}

    def check(label, condition, detail=None):
        assert condition, (label, detail)
        report['checks'].append({'check': label, 'detail': detail})
        print('PASS', label, flush=True)

    m = transport.Spectrum(args.emulator, out)
    try:
        def screen():
            data = []
            for address in range(0x4000, 0x5B00, 256):
                data += m.call('memory_read', addr=address, len=256)['bytes']
            return data

        def pc():
            value = m.call('query_cpu')['registers']['pc']
            return int(str(value).lstrip('$').replace('0x', ''), 16) if isinstance(value, str) else value

        m.call('load_media', slot='tape-1', kind='tape', path=str(tape))
        m.statement('LOAD ""')
        m.call('media_transport', slot='tape-1', transport='start')
        samples = []
        captured = set()
        for step in range(600):
            m.frames(25)
            shown = screen()
            running = 0x8000 <= pc() < 0xC000
            samples.append({'frame': 25 * (step + 1), 'blank': looks_black(shown),
                            'picture': shown == scr, 'bitmap_rows_loaded': sum(
                                shown[i:i + 32] == scr[i:i + 32] and any(scr[i:i + 32]) for i in range(0, 6144, 32)),
                            'running': running})
            if not running and not samples[-1]['picture'] and samples[-1]['bitmap_rows_loaded'] > 20 and 'partial' not in captured:
                m.frames(1)
                m.call('save_screenshot', path=str(out / 'loading-partial.png'))
                captured.add('partial')
            if samples[-1]['picture'] and 'picture' not in captured:
                m.frames(1)
                m.call('save_screenshot', path=str(out / 'loading-screen.png'))
                captured.add('picture')
            if running:
                break
        first_picture = next((s['frame'] for s in samples if s['picture']), None)
        before_game = [s for s in samples if not s['running']]
        check('the loader blanks the screen before the picture arrives',
              any(s['blank'] for s in samples if first_picture is None or s['frame'] < first_picture),
              {'first_blank_frame': next((s['frame'] for s in samples if s['blank']), None),
               'picture_starts_by_frame': next((s['frame'] for s in samples if s['bitmap_rows_loaded']), None)})
        check('the SCREEN$ block lands on the screen byte for byte', first_picture is not None,
              {'complete_at_frame': first_picture})
        check('nothing prints over the picture while the game loads',
              all(s['picture'] for s in before_game if s['frame'] >= first_picture),
              {'samples_after_picture': len([s for s in before_game if s['frame'] >= first_picture]),
               'game_started_by_frame': samples[-1]['frame']})
        m.frames(50)
        check('the game reaches its title', m.call('memory_read', addr=symbols['phase'], len=1)['bytes'] == [0]
              and samples[-1]['running'], {'pc': hex(pc())})
        m.call('save_screenshot', path=str(out / 'title.png'))
    finally:
        m.close()
    (out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
