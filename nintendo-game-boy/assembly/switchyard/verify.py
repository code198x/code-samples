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

    def key(name, pressed, n=3):
        m.call("input", events=[{"Button": {"port": 1, "name": name, "pressed": pressed}}])
        frames(n)

    def expect(tag, route, result):
        ram = m.call("memory_read", addr=0xc000, len=3)["bytes"]
        require((ram[0], ram[2]) == (route, result), f"{tag}: route/result {ram}")
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
        trace.append({"checkpoint": tag, "route": ram[0], "result": ram[2],
                      "tiles": list(actual), "png_sha256": T.sha(path)})

    try:
        require(m.call("query_cpu")["registers"]["pc"] == "$0100", "not a boot-ROM-free DMG reset")
        frames(16)
        initial = int(stages == 1)
        expect("initial", initial, 0)
        frames(12)
        expect("idle", initial, 0)
        key("a", True, 1)
        expect("press-a", 1, 0)
        key("a", True, 15)
        if negative:
            try:
                expect("held-a", 1, 0)
            except AssertionError as exc:
                require(str(exc) == "held-a: route/result [0, 1, 0]", str(exc))
                return m.server["serverInfo"], str(exc)
            raise AssertionError("Broken held input passed the original press-edge check")
        expect("held-a", 1, 0)
        key("a", False)
        expect("release-a", 1, 0)
        key("a", True)
        expect("second-a", initial, 0)
        key("a", False)
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
                                 ("Makefile", "yard.inc", "verify.py", *(n + ".asm" for n in CHECKPOINTS))},
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
        for file in (HERE / "Makefile", HERE / "yard.inc", *(HERE / (n + ".asm") for n in CHECKPOINTS)):
            shutil.copy(file, temp)
        first = temp / "01-junction.asm"
        text = first.read_text()
        require(text.count("ROUTE_UP_TILE EQU 2") == 1, "lesson edit no longer applies")
        first.write_text(text.replace("ROUTE_UP_TILE EQU 2", "ROUTE_UP_TILE EQU 4"))
        edit = build(temp, assembler)["01-junction"]
        check("edit-01-junction", edit, 1, upper_tile=4)

        yard = temp / "yard.inc"
        text = yard.read_text()
        signature = "    cpl\n    and c\n    ld b,a"
        require(text.count(signature) == 1, "held-press mutation no longer applies")
        yard.write_text(text.replace(signature, "    ld a,c\n    ld b,a"))
        mutant = build(temp, assembler)["02-switch"]
        check("broken-held-button", mutant, 2, negative=True)
    (out / "results.json").write_text(json.dumps(outcome, indent=2) + "\n")
    print("Verified three checkpoints, the junction edit, and one rejected held-button mutation.")


if __name__ == "__main__":
    main()
