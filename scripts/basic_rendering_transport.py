"""Stock-ROM BASIC loading and whole-raster comparisons for rendering patterns."""

import importlib.util
import json
import re
import subprocess
import time
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
NATIVE = Path()
FW = Path()


def configure(native: Path, firmware: Path) -> None:
    global NATIVE, FW
    NATIVE = native.resolve()
    FW = firmware.resolve()


def module(name: str, file: str) -> Any:
    s = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


T = module("transport", "verify-game-loops.py")
V = module("tilemaps", "verify-tilemaps.py")
ALIASES = {
    "commodore-64": "c64",
    "sinclair-zx-spectrum": "spectrum",
    "dragon-32": "dragon",
}
ROMS = {
    "commodore-64": "commodore-c64",
    "msx": "microsoft-msx",
    "oric-atmos": "oric",
    "dragon-32": "dragon",
    "sinclair-zx-spectrum": "sinclair-zx-spectrum-48k",
}

CONFIGURATION = {
    "sinclair-zx-spectrum": "48K stock ROM, real tape load; harness CLEAR 59999 reserves the completion byte at 60000",
    "mattel-aquarius": "16 KB RAM expansion; stock Aquarius BASIC; keyboard-loaded harness",
}


def published(system: str, folder: Path, labels: list[str]) -> dict[str, Any]:
    """The record fields that name each caller the machine was given.

    Typed callers are pinned by their text, published under
    verification/callers/. The Spectrum's callers are tokenised on the host,
    so its record also names the build198x release and each tape's digest.
    """
    output = folder / "build/verification"
    fields: dict[str, Any] = {
        "callers": {
            str((folder / "verification/callers" / (n + ".bas")).relative_to(ROOT)): (
                T.sha(output / (n + ".bas"))
            )
            for n in labels
        },
        "configuration": CONFIGURATION.get(
            system, "Stock firmware, keyboard-loaded BASIC harness"
        ),
        "basic_builder": None,
    }
    if system == "sinclair-zx-spectrum":
        lock = json.loads(
            (NATIVE / "build198x-aarch64-apple-darwin-source-lock.json").read_text()
        )
        T.require(
            T.sha(NATIVE / "build198x") == lock["executable_sha256"],
            "build198x is not the locked release",
        )
        fields["basic_builder"] = "Build198x " + lock["version"]
        fields["builder_producer"] = lock
        fields["tap_sha256"] = {n: T.sha(output / (n + ".tap")) for n in labels}
    return fields


def prepare(system: str, source: str) -> str:
    """The caller text a generator's program becomes before the machine gets it.

    END and STOP become a self-loop (the Spectrum's also sets the completion
    byte), and the Spectrum caller reserves that byte with CLEAR.
    """
    held = []
    for line in source.splitlines():
        if re.search(r"\b(END|STOP)$", line):
            n = int(line.split()[0])
            line = (
                f"{n} "
                + ("POKE 60000,202:" if system == "sinclair-zx-spectrum" else "")
                + ("GO TO" if system == "sinclair-zx-spectrum" else "GOTO")
                + f" {n}"
            )
        held.append(line)
    source = "\n".join(held) + "\n"
    if system == "sinclair-zx-spectrum":
        source = "1 CLEAR 59999\n" + source
    return source


def build(
    system: str, source: str, label: str, folder: Path, build198x: Path | str
) -> Path | None:
    """Write a prepared caller to build/verification/<label>.bas.

    Typed routes stop there: that text is what the machine is given. The
    Spectrum caller is linted with --fix and tokenised to <label>.tap by
    build198x, and that tape is what the machine loads.
    """
    output = folder / "build/verification"
    output.mkdir(parents=True, exist_ok=True)
    (output / (label + ".bas")).write_text(source)
    if system != "sinclair-zx-spectrum":
        return None
    tap = output / (label + ".tap")
    subprocess.run(
        [
            str(build198x),
            "basic",
            "lint",
            str(output / (label + ".bas")),
            "--machine",
            system,
            "--fix",
        ],
        check=True,
        capture_output=True,
        timeout=40,
    )
    subprocess.run(
        [
            str(build198x),
            "basic",
            str(output / (label + ".bas")),
            "--machine",
            system,
            "-o",
            str(tap),
        ],
        check=True,
        capture_output=True,
        timeout=40,
    )
    return tap


def run(
    system: str, source: str, label: str, folder: Path
) -> tuple[tuple[int, int], bytes]:
    name = ALIASES.get(system, system)
    exe = NATIVE / ("emu198x-" + name)
    lock = json.loads(
        (NATIVE / f"emu198x-{name}-aarch64-apple-darwin-source-lock.json").read_text()
    )
    T.require(
        lock["version"] == "0.44.1" and T.sha(exe) == lock["executable_sha256"],
        "Unexpected emulator producer",
    )
    T.require(
        lock["before_lock_sha256"]
        == lock["after_lock_sha256"]
        == lock["committed_lock_sha256"],
        "Changed emulator producer lock",
    )
    rom = FW / ROMS.get(system, system)
    cmd = [str(exe), "--mcp", "--rom-dir", str(rom)]
    if system == "acorn-bbc-micro":
        cmd += ["--rom", "acorn-bbc-basic=" + str(rom / "basic.rom")]
    if system == "memotech-mtx":
        cmd = [str(exe), "--mcp", "--rom", str(rom / "mtx.rom")]
    if system == "msx":
        cmd = [str(exe), "--mcp", "--bios", str(rom / "msx.rom")]
    if system == "sinclair-zx-spectrum":
        cmd = [str(exe), "--mcp", "--rom", str(rom / "48.rom")]
    if system == "mattel-aquarius":
        cmd += ["--expansion-kb", "16"]
    output = folder / "build/verification"
    source = prepare(system, source)
    tap = build(system, source, label, folder, NATIVE / "build198x")
    started = time.monotonic()
    m = T.Machine(cmd)
    try:
        m.call(
            "run_frames",
            frames=900 if system in ("atari-800xl", "spectravideo-svi-328") else 150,
        )
        if system == "mattel-aquarius":
            m.call("type_string", text="\n", settle_frames=60)

        def type_line(line: str) -> None:
            T.require(
                time.monotonic() - started < 600, "BASIC execution exceeded ten minutes"
            )
            if system != "memotech-mtx":
                r = m.call(
                    "type_string",
                    text=line + "\n",
                    settle_frames=60 if system == "dragon-32" else 4,
                    **({"hold_frames": 3} if system == "oric-atmos" else {}),
                )
                T.require(r["chars_typed"] == len(line) + 1, "Entry truncated")
                return
            legends = {
                "=": "-",
                '"': "2",
                "#": "3",
                "(": "8",
                ")": "9",
                "+": ";",
                "<": ",",
                ">": ".",
                "*": "8",
                ":": ":",
            }
            # '*' is shift-8? See machine keyboard; use type_string for stars until observed.
            legends.pop("*")
            legends.pop(":")
            for ch in line + "\n":
                if ch in ":;,-./*":
                    keys = (
                        ["shift", "colon"]
                        if ch == "*"
                        else [
                            {
                                ":": "colon",
                                ";": "semicolon",
                                ",": "comma",
                                "-": "minus",
                                ".": "period",
                                "/": "slash",
                            }[ch]
                        ]
                    )
                    for down in (True, False):
                        for key in keys if down else reversed(keys):
                            m.call(
                                "input",
                                events=[{"Key": {"name": key, "pressed": down}}],
                            )
                            m.call("run_frames", frames=5)
                elif ch in legends:
                    for key, down in [
                        ("shift", True),
                        (legends[ch], True),
                        (legends[ch], False),
                        ("shift", False),
                    ]:
                        m.call(
                            "input", events=[{"Key": {"name": key, "pressed": down}}]
                        )
                        m.call("run_frames", frames=5)
                else:
                    m.call("type_string", text=ch, hold_frames=3, settle_frames=6)
            m.call("run_frames", frames=60)

        if system == "sinclair-zx-spectrum":
            m.call("load_media", slot="tape-1", kind="tape", path=str(tap))
            m.call("autoload_tape", slot="tape-1", max_boot_frames=150)
        else:
            for line in source.splitlines():
                type_line(line)
            if system == "oric-atmos":
                entry = module("oric_entry", "tilemap_oric_entry.py")
                entry.ensure(m, source, rom / "oric.rom", type_line)
            type_line("RUN")
        if system == "sinclair-zx-spectrum":
            for _ in range(100):
                m.call("run_frames", frames=250)
                if m.call("memory_read", addr=60000, len=1)["bytes"] == [202]:
                    break
            T.require(
                m.call("memory_read", addr=60000, len=1)["bytes"] == [202],
                "Spectrum caller did not complete",
            )
        else:
            m.call("run_frames", frames=1200)
        image = output / (label + ".png")
        m.call("save_screenshot", path=str(image))
        return V.raster(image)
    finally:
        m.close()


def spectrum(text: str) -> str:
    # Sinclair BASIC requires explicit LET, one-based arrays and spaced GO SUB/TO.
    text = text.replace("M(D)", "M(D+1)").replace("P(T)", "P(T+1)")
    text = re.sub(r"\bM\((I\*8\+7|I\*8|40\+I|19|28|I)\)", r"M(\1+1)", text)
    text = re.sub(r"\bP\(([0-3])\)", lambda m: f"P({int(m[1]) + 1})", text)
    text = text.replace("DIM M(W*H-1),P(L)", "DIM M(W*H):DIM P(L+1)")
    text = text.replace("GOSUB", "GO SUB").replace("GOTO", "GO TO")
    text = re.sub(
        r"(^\d+ |:|THEN )([A-Z][A-Z0-9]*(?:\([^:]*?\))?=)",
        r"\1LET \2",
        text,
        flags=re.MULTILINE,
    )
    text = text.replace("150 END", "150 STOP")
    return text
