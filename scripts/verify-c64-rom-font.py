"""Run stock-ROM PRGs which preserve a ROM font and patch shared characters."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
s = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
T = importlib.util.module_from_spec(s)
s.loader.exec_module(T)
F = ROOT / "commodore-64/patterns/assembly/rendering/custom-glyphs"
V = F / "verification/rom-font"
VARIANTS = ("rom-demo", "rom-custom", "rom-wrong", "rom-repaired", "rom-boundaries")
BANNER = [18, 15, 13, 32, 6, 15, 14, 20, 32, 11, 5, 16, 20]
PATTERNS = bytes(
    [129, 66, 36, 24, 24, 36, 66, 129, 255, 129, 129, 129, 129, 129, 129, 255]
)


def source_paths():
    return [
        F / n
        for n in (
            "rom-demo.asm",
            "rom-custom.asm",
            "rom-wrong.asm",
            "rom-repaired.asm",
            "rom-caller.inc",
            "rom-init.inc",
            "glyphs.inc",
            "Makefile",
            "../../input/joystick-reading/joystick.inc",
        )
    ] + [Path(__file__), ROOT / "scripts/verify-game-loops.py"]


def digest(raw):
    return hashlib.sha256(bytes(raw)).hexdigest()


def fixture():
    text = """*=$0801
!byte $0b,$08,$0a,$00,$9e
!text "2064"
!byte 0,0,0
*=$0810
G=$70
ROM_WRONG=0
start:
    sei
    cld
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #<safe_interrupt
    sta $fffa
    sta $fffe
    lda #>safe_interrupt
    sta $fffb
    sta $ffff
"""
    for i, (half, ddr, port, shadow) in enumerate(
        (
            (2, 47, 53, 53),
            (0, 46, 53, 53),
            (0, 47, 53, 52),
            (0, 47, 55, 55),
            (0, 47, 52, 52),
            (1, 47, 53, 53),
        )
    ):
        text += f"""    lda #{ddr}
    sta $00
    lda #{port}
    sta $01
    lda #$a5
    ldx #0
fill_{i}:
    sta $2000,x
    sta $2100,x
    sta $2200,x
    sta $2300,x
    sta $2400,x
    sta $2500,x
    sta $2600,x
    sta $2700,x
    inx
    bne fill_{i}
    lda #{half}
    ldx #{shadow}
    sed
    sec
    jsr glyph_init_rom
    php
    pla
    sta $c000+{i * 8 + 4}
    cld
    lda G+7
    sta $c000+{i * 8}
    lda G+8
    sta $c001+{i * 8}
    lda G+9
    sta $c002+{i * 8}
    lda $01
    sta $c003+{i * 8}
    lda $00
    sta $c005+{i * 8}
    lda #$a5
    sta $c006+{i * 8}
    lda #239
    sta $c007+{i * 8}
    lda #53
    sta $01
hold_{i}:
    jsr joy_poll
    lda joy2
    and #16
    beq hold_{i}
release_{i}:
    jsr joy_poll
    lda joy2
    and #16
    bne release_{i}
"""
    # joy_init before branches; no IRQ timers or driven keyboard columns.
    text = text.replace("    lda $dd0d\n", "    lda $dd0d\n    jsr joy_init\n", 1)
    return (
        text
        + """hold: jmp hold
safe_interrupt: rti
!source "glyphs.inc"
!source "rom-init.inc"
!source "../../input/joystick-reading/joystick.inc"
program_end:
"""
    )


def run(args, name):
    out = F / "build/rom-verification" / name
    out.mkdir(parents=True, exist_ok=True)
    src = fixture() if name == "rom-boundaries" else (F / (name + ".asm")).read_text()
    (out / "demo.asm").write_text(src)
    subprocess.run(
        [
            str(args.assembler),
            "--dialect",
            "acme",
            "--prg",
            "-I",
            str(F),
            "--sym",
            str(out / "demo.asm"),
            "-o",
            str(out / "demo.prg"),
        ],
        check=True,
        capture_output=True,
        timeout=30,
    )
    sym = T.symbols(out / "demo.sym")
    prg = (out / "demo.prg").read_bytes()
    script = out / "import.json"
    snapshot = out / "import.vsf"
    script.write_text(json.dumps([{"action": "save_snapshot", "path": str(snapshot)}]))
    subprocess.run(
        [
            str(args.emulator),
            "--model",
            "pal",
            "--rom-dir",
            str(args.firmware),
            "--load",
            str(out / "demo.prg"),
            "--script",
            str(script),
        ],
        check=True,
        capture_output=True,
        timeout=60,
    )
    m = T.Machine(
        [str(args.emulator), "--mcp", "--model", "pal", "--rom-dir", str(args.firmware)]
    )
    rom = (args.firmware / "chargen.rom").read_bytes()

    def read(a, n):
        return [
            v
            for i in range(0, n, 128)
            for v in m.call("memory_read", addr=a + i, len=min(128, n - i))["bytes"]
        ]

    def fire(on):
        m.call("input", events=[{"Button": {"port": 2, "name": "fire", "pressed": on}}])
        m.call("run_frames", frames=3)

    def wait(label):
        stop = m.call("run_until_pc", addr=sym[label], max_steps=150000)
        T.require(stop["reached"], "Guest did not reach " + label)
        return stop

    def glyphs():
        return read(8192, 2048)

    try:
        m.call("load_snapshot", path=str(snapshot))
        loaded = read(2049, len(prg) - 2)
        T.require(bytes(loaded) == prg[2:], "Loaded PRG differs")
        m.call("type_string", text="RUN\n", hold_frames=3, settle_frames=8)
        if name == "rom-boundaries":
            cases = []
            for i in range(6):
                stop = wait("hold_" + str(i))
                row = read(0xC000 + i * 8, 8)
                font = glyphs()
                expected = (
                    bytes([165]) * 2048
                    if i < 4
                    else rom[2048:4096]
                    if i == 5
                    else rom[:2048]
                )
                T.require(bytes(font) == expected, "Native boundary font differs")
                T.require(
                    row[:3] == ([0, 0, 0] if i < 4 else [1, 0, 8])
                    and row[4] & 13 == 13
                    and row[6:] == [165, 239],
                    "Status/count/P boundary differs",
                )
                cases.append({"row": row, "font_sha256": digest(font), "stop": stop})
                fire(True)
                fire(False)
            result = {"boundaries": cases}
        else:
            stop = wait("init_done")
            half = int(name == "rom-custom")
            expected = rom[half * 2048 : (half + 1) * 2048]
            initial = glyphs()
            T.require(
                (bytes(initial) == expected) == (name != "rom-wrong"),
                "ROM copy error not distinguished",
            )
            initial_screen = read(1024, 1024)
            T.require(
                initial_screen == BANNER + [32] * (1024 - len(BANNER)),
                "Initializer changed screen",
            )
            init = {
                "status": read(sym["init_status"], 1)[0],
                "writes": read(sym["init_writes"], 2),
                "port": read(sym["restored_port"], 1)[0],
                "font_sha256": digest(initial),
                "screen_sha256": digest(initial_screen),
                "stop": stop,
            }
            T.require(
                init["status"] == 1
                and init["writes"] == [0, 8]
                and init["port"] & 15 == 5,
                "Initialization contract differs",
            )
            fire(True)
            fire(False)
            wait("main_loop")
            font = glyphs()
            screen = read(1024, 1024)
            want = bytearray(initial)
            want[8:16] = PATTERNS[:8]
            T.require(
                bytes(font) == want
                and screen[:82] == initial_screen[:82]
                and screen[82:84] == [1, 1]
                and screen[84:] == initial_screen[84:],
                "Shared install/select differs",
            )
            installed = digest(font)
            fire(True)
            fire(True)
            wait("main_loop")
            changes = read(sym["changes"], 1)[0]
            fire(False)
            wait("main_loop")
            patched = glyphs()
            want[8:16] = PATTERNS[8:]
            T.require(
                bytes(patched) == want
                and changes == 1
                and read(sym["changes"], 1) == [1]
                and read(1024, 1024) == screen,
                "Replacement/held input differs",
            )
            T.require(
                read(0x1FF0, 16) == read(0x2800, 16) == [165] * 16,
                "Font guard overwritten",
            )
            m.call("run_frames", frames=3)
            image = V / (name + ".png")
            m.call("save_screenshot", path=str(image))
            # Only the few glyphs actually displayed are retained; no complete ROM font.
            visible = {str(c): patched[c * 8 : c * 8 + 8] for c in set(screen[:1000])}
            result = {
                "initial": init,
                "installed_sha256": installed,
                "patched_sha256": digest(patched),
                "expected_initial_sha256": digest(expected),
                "expected_installed_sha256": digest(
                    expected[:8] + PATTERNS[:8] + expected[16:]
                ),
                "expected_patched_sha256": digest(
                    expected[:8] + PATTERNS[8:] + expected[16:]
                ),
                "screen": screen,
                "visible_glyphs": visible,
                "changes": changes,
                "guards": [read(0x1FF0, 16), read(0x2800, 16)],
                "inputs": read(0x70, 7),
                "image": image.name,
                "image_sha256": T.sha(image),
                "wrapper_code_bytes": sym["rom_init_end"] - sym["glyph_init_rom"],
            }
        return result | {
            "prg_bytes": list(prg),
            "loaded_bytes": loaded,
            "program_sha256": digest(prg),
            "source_sha256": digest(src.encode()),
            "server": m.server["serverInfo"],
        }
    finally:
        m.close()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    for n in ("assembler", "emulator", "firmware"):
        p.add_argument("--" + n, type=Path, required=True)
    p.add_argument("--variants", default=",".join(VARIANTS))
    a = p.parse_args()
    V.mkdir(parents=True, exist_ok=True)
    cfg = {n + "_sha256": T.sha(getattr(a, n)) for n in ("assembler", "emulator")}
    cfg["roms"] = {
        n: T.sha(a.firmware / n) for n in ("basic.rom", "kernal.rom", "chargen.rom")
    }
    cfg["rom_halves"] = [
        digest((a.firmware / "chargen.rom").read_bytes()[i : i + 2048])
        for i in (0, 2048)
    ]
    (V / "configuration.json").write_text(json.dumps(cfg, indent=2) + "\n")
    target = V / "results.json"
    r = (
        json.loads(target.read_text())
        if target.exists()
        else {"system": "commodore-64", "language": "assembly", "cases": {}}
    )
    r.update(
        configuration=cfg,
        sources={str(p.relative_to(ROOT)): T.sha(p) for p in source_paths()},
    )
    for name in a.variants.split(","):
        T.require(name in VARIANTS, "Unknown variant")
        r["cases"][name] = run(a, name)
        target.write_text(json.dumps(r, indent=2) + "\n")
        print(name, "passed", flush=True)


if __name__ == "__main__":
    main()
