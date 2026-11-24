"""Rebuild and exercise the original Switchyard carts with native DMG reset."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
SCRIPTS = HERE.parents[2] / "scripts"
CHECKPOINTS = ("01-junction", "02-switch", "03-delivery")
BUILD_SOURCES = ("Makefile", "yard.inc", "joypad.inc", *(n + ".asm" for n in CHECKPOINTS))


def load(name):
    spec = importlib.util.spec_from_file_location(name, SCRIPTS / (name + ".py"))
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


T = load("verify-game-loops")
PNG = load("verify-tilemaps")
require = T.require

# Expected icon masks, independent of the cartridge's tile/map bytes. Test
# the rendered 8x8 cells, not just that the complete screen is different.
ROWS = {
    0: (0,) * 8,
    1: (0, 0, 0, 255, 255, 0, 0, 0),
    2: (0, 16, 24, 252, 252, 24, 16, 0),
    3: (0, 126, 66, 90, 90, 66, 126, 0),
    4: (0, 24, 60, 126, 126, 60, 24, 0),
    5: (0, 2, 6, 76, 120, 48, 0, 0),
    6: (0, 66, 102, 60, 60, 102, 66, 0),
    7: (0, 0, 0, 31, 31, 24, 24, 24),
    8: (24, 24, 24, 248, 248, 24, 24, 24),
    9: (24, 24, 24, 31, 31, 0, 0, 0),
}
CELLS = ((9, 8), (9, 10), (15, 8), (15, 10), (4, 9), (9, 13), (7, 8), (7, 9), (7, 10))


def tile_ids(route, result, upper_tile):
    return (
        upper_tile if route else 1, 1 if route else 2,
        4 if result == 1 else 3, 4 if result == 2 else 1,
        4 if result == 0 else 1, (0, 5, 6)[result], 7, 8, 9,
    )


def build(folder, assembler):
    subprocess.run(
        ["make", "-B", f"ASM198X={assembler}"], cwd=folder, check=True, timeout=30,
        stdout=subprocess.DEVNULL,
    )
    carts = {name: folder / "build" / (name + ".gb") for name in CHECKPOINTS}
    for path in carts.values():
        data = path.read_bytes()
        require(len(data) == 32768, f"{path.name}: not a 32 KiB cartridge")
        require(data[0x143] == 0 and data[0x147:0x14a] == b"\0\0\0",
                f"{path.name}: not DMG ROM-only without cart RAM")
        require(data[0x14d] == (-25 - sum(data[0x134:0x14d])) & 255,
                f"{path.name}: invalid header checksum")
    return carts


def run(emu, cart, out, stages, upper_tile=2, negative=False):
    m = T.Machine([emu, "--model", "dmg", "--mcp", "--rom", str(cart)])
    trace = []

    def frames(n):
        m.call("run_frames", frames=n)

    def buttons(*changes, n=3):
        m.call(
            "input",
            events=[
                {"Button": {"port": 1, "name": name, "pressed": pressed}}
                for name, pressed in changes
            ],
        )
        frames(n)

    def key(name, pressed, n=3):
        buttons((name, pressed), n=n)

    def state():
        # Static lesson 1 has no WRAM game state; lesson 2 has no result.
        if stages == 1:
            return []
        return m.call("memory_read", addr=0xc000, len=2 if stages == 2 else 3)["bytes"]

    def expect(tag, route, result, previous_a=None):
        ram = state()
        if stages >= 2:
            require(ram[0] == route, f"{tag}: route {ram[0]} != {route}")
        if stages == 2 and previous_a is not None:
            require(ram[1] == previous_a, f"{tag}: PreviousA {ram[1]} != {previous_a}")
        if stages == 3:
            require(ram[2] == result, f"{tag}: result {ram[2]} != {result}")
        expected = tile_ids(route, result, upper_tile)
        actual = tuple(m.call("memory_read", addr=0x9800 + y * 32 + x, len=1)["bytes"][0]
                       for x, y in CELLS)
        require(actual == expected, f"{tag}: map IDs {actual} != {expected}")
        path = out / (tag + ".png")
        m.call("save_screenshot", path=str(path))
        size, rgba = PNG.raster(path)
        require(size == (160, 144), f"{tag}: wrong frame geometry {size}")
        background = rgba[:4]
        masks = []
        for tx, ty in CELLS:
            mask = []
            for y in range(ty * 8, ty * 8 + 8):
                bits = 0
                for x in range(tx * 8, tx * 8 + 8):
                    offset = (y * 160 + x) * 4
                    bits = (bits << 1) | (rgba[offset:offset + 4] != background)
                mask.append(bits)
            masks.append(tuple(mask))
        require(masks == [ROWS[i] for i in expected], f"{tag}: rendered tiles differ")
        trace.append({"checkpoint": tag, "route": route, "result": result,
                      "wram": ram, "tiles": list(actual), "png_sha256": T.sha(path)})

    try:
        require(m.call("query_cpu")["registers"]["pc"] == "$0100", "not a boot-ROM-free DMG reset")
        frames(16)
        initial = int(stages == 1)
        expect("initial", initial, 0, previous_a=0)
        frames(12)
        expect("idle", initial, 0, previous_a=0)
        key("a", True, 1)
        expect("press-a", 1, 0, previous_a=1)
        key("a", True, 15)
        if negative:
            try:
                expect("held-a", 1, 0, previous_a=1)
            except AssertionError as exc:
                require(str(exc) == "held-a: route 0 != 1", str(exc))
                require(state() == [0, 1], "broken route changed without held A")
                return m.server["serverInfo"], str(exc)
            raise AssertionError("Broken held input passed the original press-edge check")
        expect("held-a", 1, 0, previous_a=1)
        key("a", False)
        expect("release-a", 1, 0, previous_a=0)
        key("a", True)
        expect("second-a", initial, 0, previous_a=1)
        key("a", False)
        if stages == 2:
            expect("release-after-second-a", 0, 0, previous_a=0)
        if stages == 3:
            key("start", True)
            expect("missed", 0, 2)
            key("start", False)
            key("a", True)
            expect("locked-after-miss", 0, 2)
            key("a", False)
            key("b", True)
            expect("restart-after-miss", 0, 0)
            key("b", False)
            key("a", True)
            key("a", False)
            key("start", True)
            expect("delivered", 1, 1)
            key("start", False)
            key("b", True)
            expect("restart-after-delivery", 0, 0)
            key("b", False)
            key("b", True)
            expect("b-while-ready", 0, 0)
            key("b", False)

            # Queue both before advancing any frames. Host event order is not
            # game rule order: the new A press changes the route before Start.
            buttons(("start", True), ("a", True), n=1)
            ram = state()
            require(ram == [1, 9, 1], f"same-frame-a-start: first sample {ram}")
            frames(2)
            expect("same-frame-a-start-delivery", 1, 1)
            buttons(("a", False), ("start", False))
            key("b", True)
            key("b", False)

            # Enter a miss, then restart with B while A also becomes pressed.
            # Keeping A held after retry must not manufacture another edge.
            key("start", True)
            expect("ready-for-a-b-retry", 0, 2)
            key("start", False)
            buttons(("a", True), ("b", True), n=1)
            ram = state()
            require(ram == [0, 3, 0], f"same-frame-a-b: first sample {ram}")
            frames(2)
            expect("same-frame-a-b-retry", 0, 0)
            key("b", False, n=5)
            expect("held-a-after-chord-retry", 0, 0)
            key("a", False)
            key("a", True)
            expect("fresh-a-after-chord-retry", 1, 0)
        return m.server["serverInfo"], trace
    finally:
        m.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--assembler", type=Path, required=True)
    parser.add_argument("--emulator", type=Path, required=True)
    parser.add_argument("--out", type=Path, required=True, help="scratch folder for captures and results")
    args = parser.parse_args()
    assembler = str(args.assembler.resolve())
    emu = str(args.emulator.resolve())
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=True)
    carts = build(HERE, assembler)
    outcome = {"configuration": "DMG reset, no boot ROM, 32 KiB ROM-only homebrew",
               "assembler_sha256": T.sha(Path(assembler)), "emulator_sha256": T.sha(Path(emu)),
               "assembler_version": subprocess.check_output([assembler, "--version"], text=True, stderr=subprocess.STDOUT).strip(),
               "source_sha256": {name: T.sha(HERE / name) for name in
                                 (*BUILD_SOURCES, "verify.py")},
               "checkpoints": {}}
    with tempfile.TemporaryDirectory(prefix="switchyard-") as tmp:
        temp = Path(tmp)
        empty = temp / "no-firmware"
        empty.mkdir()
        os.environ.pop("EMU198X_GB_DMG_BOOT_ROM", None)
        os.environ["EMU198X_GB_ROM_DIR"] = str(empty)

        def check(name, cart, stages, upper_tile=2, negative=False):
            folder = out / name
            folder.mkdir(exist_ok=True)
            server, observations = run(emu, cart, folder, stages, upper_tile, negative)
            outcome["server"] = server
            outcome["checkpoints"][name] = {"cart_sha256": T.sha(cart),
                                            "observed": observations}

        for stages, (name, cart) in enumerate(carts.items(), start=1):
            check(name, cart, stages)
        for name in BUILD_SOURCES:
            shutil.copy(HERE / name, temp)
        first = temp / "01-junction.asm"
        text = first.read_text()
        require(text.count("ROUTE_UP_TILE EQU 2") == 1, "lesson edit no longer applies")
        first.write_text(text.replace("ROUTE_UP_TILE EQU 2", "ROUTE_UP_TILE EQU 4"))
        edit = build(temp, assembler)["01-junction"]
        check("edit-01-junction", edit, 1, upper_tile=4)
        size, before = PNG.raster(out / "01-junction/initial.png")
        edited_size, after = PNG.raster(out / "edit-01-junction/initial.png")
        require(size == edited_size, "junction edit changed frame geometry")
        width, _ = size
        changed = [
            (offset // 4 % width, offset // 4 // width)
            for offset in range(0, len(before), 4)
            if before[offset:offset + 4] != after[offset:offset + 4]
        ]
        gate_x, gate_y = CELLS[0]
        require(
            bool(changed)
            and all(x // 8 == gate_x and y // 8 == gate_y for x, y in changed),
            "junction edit must change only the upper gate cell",
        )
        outcome["junction_edit"] = {
            "tile": [gate_x, gate_y], "changed_pixels": len(changed),
        }

        switch = temp / "02-switch.asm"
        text = switch.read_text()
        # Use the learner's actual one-line edit: act on the current A
        # sample (C) instead of the freshly pressed buttons (B).
        signature = "    ld a,b\n    and a\n    jr z,.redraw"
        replacement = "    ld a,c\n    and a\n    jr z,.redraw"
        require(text.count(signature) == 1, "held-press mutation no longer applies")
        switch.write_text(text.replace(signature, replacement))
        mutant = build(temp, assembler)["02-switch"]
        check("broken-held-button", mutant, 2, negative=True)
    (out / "results.json").write_text(json.dumps(outcome, indent=2) + "\n")
    print("Verified three checkpoints, the junction edit, paired inputs, and one rejected held-button mutation.")


if __name__ == "__main__":
    main()
