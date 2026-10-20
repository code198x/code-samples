"""Execute six drawing components; compare independent pixel models and full memory.

Released original reset fixtures only: this does not test manufacturer OS loading.
Every request completes through a native caller, including the deliberately faulty
build. Memory is compared after EACH call, not just after later calls can erase it.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/drawing-foundations"


def load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    assert spec and spec.loader
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


T = load("drawing_transport", ROOT / "scripts/verify-game-loops.py")
B = load("drawing_builder", SHARED / "build.py")
PNG = load("drawing_png", ROOT / "scripts/verify-tilemaps.py")


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def read(m, addr: int, length: int) -> bytes:
    return bytes(
        v
        for i in range(0, length, 128)
        for v in m.call("memory_read", addr=addr + i, len=min(128, length - i))["bytes"]
    )


def write(m, addr: int, data: bytes) -> None:
    for i, v in enumerate(data):
        m.call("poke_byte", addr=addr + i, value=v)


def request(m, c: dict, command: int, data: bytes) -> bytes:
    write(m, c["context"], data)
    m.call("poke_byte", addr=c["command"], value=command)
    for _ in range(40):
        m.call("run_frames", frames=2)
        if read(m, c["command"], 1) == b"\0":
            break
    else:
        raise AssertionError(f"{c['machine_id']} command {command} never completed")
    # Complete a clean frame after each update. These are not frame-budget timings.
    m.call("run_frames", frames=2)
    return read(m, c["context"], 48 if c["family"] == "pixels-and-boxes" else 24)


def word(data: bytes, order: str = "little") -> int:
    return int.from_bytes(data, order)


def pixel_memory(c: dict, grid: list[bytearray]) -> bytes:
    data = bytearray(c["width"] * c["height"] // 8)
    for y, row in enumerate(grid):
        for x, p in enumerate(row):
            if not p:
                continue
            if c["machine_id"] == "spectrum":
                offset = (
                    (y // 64) * 2048 + (y % 8) * 256 + ((y % 64) // 8) * 32 + x // 8
                )
            elif c["machine_id"] == "acorn-bbc-micro":
                offset = (y // 8) * 320 + (x // 8) * 8 + y % 8
            else:
                offset = y * 32 + x // 8
            data[offset] |= 1 << (7 - x % 8)
    return bytes(data)


def pixel_cases(w: int, h: int) -> list[tuple]:
    cases = [
        ("fill", 0, 0, w, h, 1),
        ("fill", 8, 8, 40, 16, 0),
        ("fill", 9, 18, 41, 26, 0),
        ("fill", 4, 10, 19, 15, 2),
        ("fill", 5, 11, 18, 14, 1),
        ("box", 30, 30, 69, 55, 0),
        ("box", 30, 30, 69, 55, 2),
        ("box", 31, 31, 68, 54, 2),
        ("box", 70, 32, 71, 45, 2),
        ("box", 80, 33, 86, 44, 2),
        ("box", 100, 32, 120, 33, 2),
        ("hspan", 0, 64, w, 0, 0),
        ("vspan", w - 1, 0, 0, h, 2),
        ("pixel", w - 1, h - 1, 0, 0, 0),
        ("read", w - 1, h - 1, 0, 0, 0),
    ]
    for phase in range(8):
        for op in [0, 2, 1]:
            cases += [
                ("pixel", 120 + phase, 80 + op, 0, 0, op),
                ("read", 120 + phase, 80 + op, 0, 0, 0),
            ]
        cases += [
            ("hspan", 120 + phase, 90 + phase, 133 + phase, 0, 0),
            ("box", 160 + phase, 100, 171 + phase, 109, 2),
        ]
    cases += [
        ("fill", 0, 0, 0, 1, 0),
        ("fill", 0, 0, 1, 0, 0),
        ("fill", 4, 3, 2, 6, 0),
        ("fill", 2, 6, 4, 3, 0),
        ("fill", 0, 0, w + 1, 1, 0),
        ("fill", 0, 0, 1, h + 1, 0),
        ("fill", 65535, 0, 2, 2, 0),
        ("fill", 0, 65535, 2, 2, 0),
        ("pixel", w, 0, 0, 0, 0),
        ("pixel", 0, h, 0, 0, 0),
        ("pixel", 65535, 0, 0, 0, 0),
        ("hspan", 8, 3, 8, 0, 0),
        ("vspan", 2, 8, 0, 8, 0),
        ("fill", 0, 0, 8, 8, 3),
        ("box", 0, 0, w, h, 0),
    ]
    return cases


def pixel_geometry(c: dict):
    return {
        "spectrum": (352, 296, 48, 48, 1, 1, (0, 0, 0), (0, 0, 0), (194, 194, 194)),
        "acorn-bbc-micro": (
            640,
            512,
            0,
            0,
            2,
            2,
            (0, 0, 0),
            (0, 0, 0),
            (255, 255, 255),
        ),
        "dragon": (744, 312, 120, 63, 2, 1, (5, 5, 5), (0, 16, 0), (29, 170, 29)),
    }[c["machine_id"]]


def pixels(c: dict, grid: list[bytearray]) -> tuple[tuple[int, int], bytes]:
    w, h, left, top, sx, sy, border, bg, fg = pixel_geometry(c)
    data = bytearray(bytes([*border, 255]) * (w * h))
    for y, row in enumerate(grid):
        for x, p in enumerate(row):
            rgba = bytes([*(fg if p else bg), 255])
            for dy in range(sy):
                for dx in range(sx):
                    at = ((top + y * sy + dy) * w + left + x * sx + dx) * 4
                    data[at : at + 4] = rgba
    return (w, h), bytes(data)


def apply_pixel(c: dict, grid: list[bytearray], case: tuple) -> tuple[bool, int, set]:
    kind, x, y, right, bottom, op = case
    w, h = c["width"], c["height"]
    rx = x + 1 if kind in ["pixel", "read", "vspan"] else right
    by = y + 1 if kind in ["pixel", "read", "hspan"] else bottom
    accepted = op < 3 and 0 <= x < rx <= w and 0 <= y < by <= h
    value = grid[y][x] if accepted and kind == "read" else 0
    touched = set()
    if accepted and kind != "read":
        for py in range(y, by):
            for px in range(x, rx):
                if kind == "box" and py not in [y, by - 1] and px not in [x, rx - 1]:
                    continue
                grid[py][px] = 1 if op == 0 else 0 if op == 1 else grid[py][px] ^ 1
                touched.add((py, px // 8))
    return accepted, value, touched


def bitmap_run(m, c: dict, out: Path, variant: str) -> dict:
    w, h = c["width"], c["height"]
    order = "big" if c["cpu"] == "6809" else "little"
    grid = [bytearray(w) for _ in range(h)]
    grid[0][0] = 1
    require(
        read(m, c["base"], w * h // 8) == pixel_memory(c, grid), "Startup pixel differs"
    )
    guards = (
        [(0x5800, 768)] if c["machine_id"] == "spectrum" else [(c["base"] - 16, 16)]
    )
    if c["machine_id"] == "dragon":
        guards += [(0x1E00, 16)]
    original_guards = [(addr, read(m, addr, n)) for addr, n in guards]
    (out / f"{variant}-initial.dat").write_bytes(pixel_memory(c, grid))
    records = []
    faults = 0
    pixel_faults = 0
    for index, (kind, x, y, right, bottom, op) in enumerate(pixel_cases(w, h)):
        command = ["fill", "box", "pixel", "read", "hspan", "vspan"].index(kind) + 1
        args = b"".join(v.to_bytes(2, order) for v in [x, y, right, bottom]) + bytes(
            [op]
        )
        context = request(m, c, command, args)
        accepted, value, touched = apply_pixel(c, grid, (kind, x, y, right, bottom, op))
        require(context[9] == int(accepted), f"{index} {kind}: acceptance {context[9]}")
        require(context[10] == value, f"{index} {kind}: read {context[10]} != {value}")
        require(context[:9] == args, f"{index} {kind}: changed public input")
        require(
            word(context[40:42], order) == len(touched),
            f"{index} {kind}: write count {word(context[40:42], order)} != {len(touched)}",
        )
        observed = read(m, c["base"], w * h // 8)
        expected = pixel_memory(c, grid)
        for addr, data in original_guards:
            require(read(m, addr, len(data)) == data, f"{index}: damaged guard")
        if observed != expected:
            if variant == "positive":
                bad = next(
                    i for i, (a, b) in enumerate(zip(observed, expected)) if a != b
                )
                raise AssertionError(
                    f"{c['machine_id']} {index} {kind}: memory at {c['base'] + bad:04x} got {observed[bad]:02x}, expected {expected[bad]:02x}"
                )
            faults += 1
        capture = index in [0, 6, 14, len(pixel_cases(w, h)) - 1]
        if capture:
            p = out / f"{variant}-{index}.png"
            m.call("save_screenshot", path=str(p))
            actual = PNG.raster(p)
            expect = pixels(c, grid)
            if variant == "positive":
                require(
                    actual == expect,
                    f"{index} {kind}: native pixels differ {actual[0]} vs {expect[0]}",
                )
            elif actual != expect:
                pixel_faults += 1
        (out / f"{variant}-{index}.dat").write_bytes(observed)
        records.append(
            {
                "index": index,
                "kind": kind,
                "x": x,
                "y": y,
                "right": right,
                "bottom": bottom,
                "op": op,
                "accepted": accepted,
                "read": value,
                "writes": len(touched),
                "memory_sha256": hashlib.sha256(observed).hexdigest(),
            }
        )
    require(
        variant == "positive" or (faults > 0 and pixel_faults > 0),
        "Completed broken mask was not caught in memory and pixels",
    )
    return {
        "cases": records,
        "fault_mismatches": faults,
        "pixel_faults": pixel_faults,
        "guard_ranges": guards,
    }


ORIGINAL = [129, 66, 36, 24, 24, 36, 66, 129, 255, 129, 165, 129, 165, 153, 129, 255]


def glyph_spec(c: dict):
    if c["machine_id"] == "commodore-vic-20":
        return 128, 8, 0x1000, 0x1E00, 506, 22
    if c["machine_id"] == "msx":
        return 256, 8, 0, 0x1800, 768, 32
    return 256, 16, 0x8000, 0x9800, 1024, 32


def glyph_memory(m, c: dict) -> bytes:
    if c["machine_id"] == "msx":
        return read(m, 0xC000, 0x3000)
    if c["machine_id"] == "game-boy":
        return read(m, 0x8000, 0x2000)
    return read(m, 0x1000, 0x410) + read(m, 0x1DF0, 16 + 512)


def glyph_pixels(c: dict, font: bytes, names: bytes):
    ident = c["machine_id"]
    _slots, bpg, _base, _screen, _cells, cols = glyph_spec(c)
    w, h, left, top, rows = {
        "commodore-vic-20": (230, 288, 28, 52, 23),
        "msx": (280, 240, 12, 25, 24),
        "game-boy": (160, 144, 0, 0, 18),
    }[ident]
    data = bytearray(
        bytes([255, 255, 255, 255] if ident == "game-boy" else [0, 0, 0, 255]) * (w * h)
    )
    for cy in range(rows):
        for cx in range(20 if ident == "game-boy" else cols):
            slot = names[cy * cols + cx]
            for y in range(8):
                for x in range(8):
                    bit = 7 - x
                    p = (font[slot * bpg + y * (bpg // 8)] >> bit) & 1
                    if bpg == 16:
                        p |= ((font[slot * bpg + y * 2 + 1] >> bit) & 1) << 1
                    v = (
                        [255, 170, 85, 0][p]
                        if ident == "game-boy"
                        else (255 if p else 0)
                    )
                    at = ((top + cy * 8 + y) * w + left + cx * 8 + x) * 4
                    data[at : at + 4] = bytes([v, v, v, 255])
    return (w, h), bytes(data)


def glyph_run(m, c: dict, out: Path, variant: str) -> dict:
    slots, bpg, base, screen, cells, cols = glyph_spec(c)
    ident = c["machine_id"]
    src = (
        0x1500 if ident == "commodore-vic-20" else 0xF200 if ident == "msx" else 0xC800
    )
    # Force a readback without changing video memory.
    request(m, c, 5, bytes(7))
    initial = glyph_memory(m, c)
    (out / f"{variant}-initial.dat").write_bytes(initial)
    font = bytearray(slots * bpg)
    names = bytearray(cells)
    encoded = (
        bytes(ORIGINAL)
        if bpg == 8
        else bytes(
            v for i, b in enumerate(ORIGINAL) for v in [b, b if i in [8, 15] else 0]
        )
    )
    font[bpg : 3 * bpg] = encoded
    first = 2 * cols + 2
    names[first : first + 2] = bytes([1, 1])

    def expected():
        data = bytearray(initial)
        if ident == "commodore-vic-20":
            data[: len(font)] = font
            data[0x410 + 16 : 0x410 + 16 + cells] = names
        else:
            data[
                base - (0x8000 if ident == "game-boy" else 0) : base
                - (0x8000 if ident == "game-boy" else 0)
                + len(font)
            ] = font
            data[
                screen - (0x8000 if ident == "game-boy" else 0) : screen
                - (0x8000 if ident == "game-boy" else 0)
                + cells
            ] = names
        return bytes(data)

    if variant == "positive":
        require(initial == expected(), "Original glyphs or shared cell setup differs")
    records = []
    faults = 0
    pixel_faults = 0
    # Source sketches are deliberately asymmetric; a reversed row/plane is visible.
    source = bytes(((i * 37 + 11) ^ (i // 8) * 19) & 255 for i in range(bpg * 3))
    write(m, src, source)
    cases = [
        ("replace", 1, 99, 0, 0),
        ("select", 0, 0, 2, first),
        ("replace", 1, 0, 0, 0),
        ("install", 0, 1, 0, 0),
        ("install", slots - 1, 1, 0, 0),
        ("select", 0, 0, slots - 1, cells - 1),
        ("install", slots - 2, 2, 0, 0),
        ("install", slots - 1, 2, 0, 0),
        ("install", 0, 0, 0, 0),
        ("select", 0, 0, 0, cells),
        ("select", 0, 0, 0, 65535),
        ("install", slots - 1, 255, 0, 0),
        ("replace", slots - 1, 0, 0, 0),
    ]
    if slots == 128:
        cases += [("install", 128, 1, 0, 0), ("select", 0, 0, 128, 0)]
    # Long transfers exercise byte counter rollover and the last legal slot.
    bulk_count = 128 if slots == 128 else 255
    bulk_src = 0x1700 if slots == 128 else 0x8000 if ident == "msx" else 0xD000
    bulk = bytes((i * 17 + 3) & 255 for i in range(bulk_count * bpg))
    write(m, bulk_src, bulk)
    cases += [("bulk", 0, bulk_count, 0, 0)]
    if slots == 256:
        cases += [("bulk", 1, 255, 0, 0)]
    for index, (kind, start, count, code, cell) in enumerate(cases):
        data_source = bulk_src if kind == "bulk" else src
        args = (
            data_source.to_bytes(2, "little")
            + bytes([start, count, code])
            + cell.to_bytes(2, "little")
        )
        context = request(
            m, c, {"install": 2, "bulk": 2, "replace": 3, "select": 4}[kind], args
        )
        n = 1 if kind == "replace" else count
        accepted = (
            (cell < cells and code < slots)
            if kind == "select"
            else n > 0 and start + n <= slots
        )
        writes = 1 if accepted and kind == "select" else n * bpg if accepted else 0
        require(context[:7] == args, f"{index}: changed glyph inputs")
        require(context[7] == int(accepted), f"{index}: glyph acceptance differs")
        require(word(context[8:10]) == writes, f"{index}: glyph write count differs")
        if accepted:
            if kind == "select":
                names[cell] = code
            else:
                font[start * bpg : (start + n) * bpg] = (
                    bulk if kind == "bulk" else source
                )[: n * bpg]
        observed = glyph_memory(m, c)
        if observed != expected():
            if variant == "positive":
                bad = next(
                    i for i, (a, b) in enumerate(zip(observed, expected())) if a != b
                )
                raise AssertionError(
                    f"{ident} {index} {kind}: memory offset {bad:x} got {observed[bad]:02x} expected {expected()[bad]:02x}"
                )
            faults += 1
        if index in [0, 1, 2, 5, len(cases) - 1]:
            p = out / f"{variant}-{index}.png"
            m.call("save_screenshot", path=str(p))
            if variant == "positive":
                require(
                    PNG.raster(p) == glyph_pixels(c, font, names),
                    f"{ident} {index}: shared glyph native pixels differ",
                )
            elif PNG.raster(p) != glyph_pixels(c, font, names):
                pixel_faults += 1
        (out / f"{variant}-{index}.dat").write_bytes(observed)
        records.append(
            {
                "index": index,
                "kind": kind,
                "first": start,
                "count": count,
                "code": code,
                "cell": cell,
                "accepted": accepted,
                "writes": writes,
                "memory_sha256": hashlib.sha256(observed).hexdigest(),
            }
        )
    context = request(m, c, 1, bytes(7))
    require(
        context[7] == 1 and word(context[8:10]) == slots * bpg + cells,
        "Init count/status differs",
    )
    font[:] = bytes(len(font))
    names[:] = bytes(len(names))
    if variant == "positive":
        require(
            glyph_memory(m, c) == expected(),
            "Init damaged neighbours or failed to blank",
        )
    (out / f"{variant}-init.dat").write_bytes(glyph_memory(m, c))
    records.append({"kind": "init", "accepted": True, "writes": slots * bpg + cells})
    if ident == "game-boy":
        before = glyph_memory(m, c)
        context = request(m, c, 6, src.to_bytes(2, "little") + bytes([0, 1, 0, 0, 0]))
        require(
            context[7] == 0 and word(context[8:10]) == 0,
            "Live LCD upload did not reject",
        )
        require(glyph_memory(m, c) == before, "Live LCD rejection modified VRAM")
        records.append({"kind": "live-rejection", "accepted": False, "writes": 0})
    require(
        variant == "positive" or (faults > 0 and pixel_faults > 0),
        "Completed wrong-slot build was not caught in memory and pixels",
    )
    return {"cases": records, "fault_mismatches": faults, "pixel_faults": pixel_faults}


def verify(c: dict, args) -> None:
    tools = json.loads((SHARED / "toolchain.json").read_text())
    expected = {t["tool"]: t["binary_sha256"] for t in tools}
    require(
        T.sha(args.native / c["binary"]) == expected[c["binary"]],
        "Unqualified emulator executable",
    )
    require(
        T.sha(Path(args.assembler)) == expected["asm198x"],
        "Unqualified assembler executable",
    )
    folder = ROOT / c["folder"] / "patterns/assembly/rendering" / c["family"]
    out = folder / "build/verification"
    out.mkdir(parents=True, exist_ok=True)
    for old in out.iterdir():
        if old.suffix in [".json", ".dat", ".png"]:
            old.unlink()
    records = {}
    for variant in ["positive", "fault"]:
        _, image = B.build(c["machine_id"], args.assembler, variant)
        cmd = [str(args.native / c["binary"]), "--mcp", "--" + c["kind"], str(image)]
        if c["machine_id"] == "commodore-vic-20":
            cmd += [
                "--basic",
                str(image.parent / "basic.rom"),
                "--char",
                str(image.parent / "chargen.rom"),
            ]
        m = T.Machine(cmd)
        try:
            m.call("run_frames", frames=120)
            require(
                read(m, c["command"], 2) == bytes([0, 239]),
                "Original caller never reached ready",
            )
            result = (bitmap_run if c["family"] == "pixels-and-boxes" else glyph_run)(
                m, c, out, variant
            )
            result["fixture_sha256"] = T.sha(image)
            result["emulator_sha256"] = T.sha(args.native / c["binary"])
            result["assembler_sha256"] = T.sha(Path(args.assembler))
            records[variant] = result
        finally:
            m.close()
    records["sources"] = {
        str(p.relative_to(ROOT)): T.sha(p)
        for p in [
            folder / "demo.asm",
            SHARED / "build.py",
            SHARED / "systems.json",
            Path(__file__),
            ROOT / "scripts/verify-game-loops.py",
            ROOT / "scripts/verify-tilemaps.py",
            ROOT / "scripts/check-drawing-foundations.py",
            SHARED / "toolchain.json",
            (
                SHARED / (c["cpu"] + ".inc")
                if c["family"] == "pixels-and-boxes"
                else folder / "glyphs.inc"
            ),
        ]
    }
    if c["machine_id"] == "spectrum":
        helper = (
            ROOT
            / "sinclair-zx-spectrum/patterns/assembly/rendering/bitmap-addressing/bitmap-addressing.inc"
        )
        records["sources"][str(helper.relative_to(ROOT))] = T.sha(helper)
    records["artifacts"] = {
        p.name: T.sha(p) for p in out.iterdir() if p.suffix in [".dat", ".png"]
    }
    (out / "results.json").write_text(json.dumps(records, indent=2) + "\n")
    print(
        c["machine_id"],
        "PASS",
        len(records["positive"]["cases"]),
        "calls; completed fault caught",
        flush=True,
    )


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--assembler", required=True)
    p.add_argument("--system")
    a = p.parse_args()
    configs = json.loads((SHARED / "systems.json").read_text())
    selected = [c for c in configs if a.system is None or c["machine_id"] == a.system]
    require(bool(selected), "No matching system; nothing was executed")
    for c in selected:
        verify(c, a)
