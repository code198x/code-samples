#!/usr/bin/env python3
"""Capture the CRASH! Live type-in cards: three short programs whose screens
are printed on the front of a card and whose listings are printed on the back.

The card's promise is that typing the listing produces the picture, so each
screen here is made by running exactly the listing that gets printed. Two are
Sinclair BASIC, typed in key by key through `typewriter` and then RUN; one is
Commodore BASIC V2, imported with `--load` and RUN, because the C64 needs no
keyword chords to show.

Each screen is cropped to the machine's display area (the Spectrum's 256×192,
the C64's 320×200) so the card frames the picture, not the border.

    python3 capture-typein.py --spectrum PATH --c64 PATH [--out DIR]

Writes <name>.script.json beside each listing, so every key that was pressed
is on record, and <name>.png into --out.
"""

import argparse
import json
import struct
import subprocess
import sys
import zlib
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from typewriter import script_for  # noqa: E402

HERE = Path(__file__).resolve().parent

SPECTRUM = [('typein-198x', 1300), ('typein-rosette', 1000)]
C64 = [('typein-198x-c64', 1500)]

# The ROM redraws the edit line when it wraps, and a key that lands during the
# redraw is lost. The typewriter's default gaps are tuned for the welcome
# capture; these listings wrap more, so the gaps are widened a little.
KEYWORD_GAP = 14


def slow(steps):
    for step in steps:
        if step.get('action') == 'run_frames' and step['frames'] == 8:
            step['frames'] = KEYWORD_GAP
        if step.get('settle_frames') == 8:
            step['settle_frames'] = KEYWORD_GAP
    return steps


def spectrum_script(listing, out_png, run_frames):
    steps = [
        {"action": "wait_for_boot", "max_frames": 800},
        {"action": "press_key", "key": "Enter", "hold_frames": 4},
        {"action": "run_frames", "frames": 30},
    ]
    steps += slow(script_for(listing))
    steps += script_for('RUN\n')
    steps += [
        {"action": "run_frames", "frames": run_frames},
        {"action": "save_screenshot", "path": str(out_png)},
    ]
    return steps


def c64_script(out_png, run_frames):
    return [
        {"action": "wait_for_boot", "max_frames": 600},
        {"action": "run_frames", "frames": 60},
        {"action": "type_string", "text": "RUN\n", "hold_frames": 3, "settle_frames": 10},
        {"action": "run_frames", "frames": run_frames},
        {"action": "save_screenshot", "path": str(out_png)},
    ]


def run(cmd):
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        sys.exit(f'emulator failed:\n{result.stderr or result.stdout}')


# --- PNG crop, dependency-free -------------------------------------------------

def _png_read(path):
    data = Path(path).read_bytes()
    pos, width, height, ctype, idat = 8, 0, 0, 0, b''
    while pos < len(data):
        length = struct.unpack('>I', data[pos:pos + 4])[0]
        kind, body = data[pos + 4:pos + 8], data[pos + 8:pos + 8 + length]
        if kind == b'IHDR':
            width, height, _, ctype = struct.unpack('>IIBB', body[:10])
        elif kind == b'IDAT':
            idat += body
        pos += 12 + length
    bpp = {2: 3, 6: 4}[ctype]
    raw, stride, rows, prev, p = zlib.decompress(idat), width * bpp, [], bytearray(width * bpp), 0
    for _ in range(height):
        flt, line = raw[p], bytearray(raw[p + 1:p + 1 + stride])
        p += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if flt == 1:
                line[x] = (line[x] + a) & 255
            elif flt == 2:
                line[x] = (line[x] + b) & 255
            elif flt == 3:
                line[x] = (line[x] + (a + b) // 2) & 255
            elif flt == 4:
                pp = a + b - c
                pa, pb, pc = abs(pp - a), abs(pp - b), abs(pp - c)
                line[x] = (line[x] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        rows.append(bytes(line))
        prev = line
    return width, height, bpp, rows


def _png_write(path, width, height, bpp, rows):
    def chunk(kind, body):
        return struct.pack('>I', len(body)) + kind + body + struct.pack('>I', zlib.crc32(kind + body) & 0xffffffff)
    ihdr = struct.pack('>IIBBBBB', width, height, 8, 2 if bpp == 3 else 6, 0, 0, 0)
    body = zlib.compress(b''.join(b'\x00' + r for r in rows), 9)
    Path(path).write_bytes(b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr) + chunk(b'IDAT', body) + chunk(b'IEND', b''))


def crop(path, x0, y0, width, height):
    """Keep width×height at (x0, y0): the display without its border. The
    Spectrum's PAL frame is not symmetrical (48 lines above, 56 below), so the
    offsets are stated rather than centred."""
    fw, fh, bpp, rows = _png_read(path)
    cropped = [r[x0 * bpp:(x0 + width) * bpp] for r in rows[y0:y0 + height]]
    _png_write(path, width, height, bpp, cropped)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--spectrum', help='path to emu198x-spectrum')
    ap.add_argument('--c64', help='path to emu198x-c64')
    ap.add_argument('--out', default=HERE, help='directory for the cropped PNGs')
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    if args.spectrum:
        for name, frames in SPECTRUM:
            png = (out / name).with_suffix('.png').resolve()
            steps = spectrum_script((HERE / f'{name}.bas').read_text(), png, frames)
            script = HERE / f'{name}.script.json'
            script.write_text(json.dumps(steps, indent=1) + '\n')
            run([args.spectrum, '--script', str(script)])
            crop(png, 48, 48, 256, 192)
            print(f'wrote {png}')

    if args.c64:
        for name, frames in C64:
            png = (out / name).with_suffix('.png').resolve()
            script = HERE / f'{name}.script.json'
            script.write_text(json.dumps(c64_script(png, frames), indent=1) + '\n')
            run([args.c64, '--load', str(HERE / f'{name}.bas'), '--script', str(script)])
            crop(png, 48, 56, 320, 200)
            print(f'wrote {png}')


if __name__ == '__main__':
    main()
