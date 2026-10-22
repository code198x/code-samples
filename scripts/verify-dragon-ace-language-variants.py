"""Execute the stock-language customisation, reset mistake and nonzero start."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)


def verify(args, system: str) -> None:
    dragon = system == "dragon-32"
    track = "basic" if dragon else "forth"
    suffix = "bas" if dragon else "fth"
    name = "dragon" if dragon else system
    folder = ROOT / system / "patterns" / track / "framework/command-loop"
    source = (folder / f"demo.{suffix}").read_text()
    variants = {
        "working": source,
        "step-three": source.replace("N=N+1", "N=N+3")
        if dragon
        else source.replace("IF 1+", "IF 3 +"),
        "wrong-reset": source.replace("50 GOTO 20", "50 GOTO 10")
        if dragon
        else source.replace('CLS ." TURN "', 'DROP 0 CLS ." TURN "'),
        "repaired": source,
        "nonzero": source.replace("N=0", "N=37")
        if dragon
        else source.replace(": TURNS 0 BEGIN", ": TURNS 37 BEGIN"),
    }
    (folder / f"customise.{suffix}").write_text(variants["step-three"])
    (folder / "mistakes").mkdir(exist_ok=True)
    (folder / f"mistakes/reset-each-command.{suffix}").write_text(
        variants["wrong-reset"]
    )
    result = {}
    for variant, program in variants.items():
        out = folder / "verification/current-release" / variant
        out.mkdir(parents=True, exist_ok=True)
        m = T.Machine(
            [
                str(args.native / ("emu198x-" + name)),
                "--mcp",
                "--rom",
                str(
                    args.firmware_root
                    / name
                    / ("dragon32.rom" if dragon else "ace.rom")
                ),
            ]
        )

        def enter(text: str, m=m) -> None:
            r = m.call("type_string", text=text, settle_frames=60)
            T.require(r["chars_typed"] == len(text), "Incomplete typed source")

        observations = []

        def observe(label: str, m=m, out=out, observations=observations) -> None:
            raw = []
            base = 0x400 if dragon else 0x2400
            for offset in range(0, 512 if dragon else 768, 256):
                raw += m.call("memory_read", addr=base + offset, len=256)["bytes"]
            codes = [x & 63 if dragon else x & 127 for x in raw]
            text = "".join(chr(x + 64) if dragon and x < 32 else chr(x) for x in codes)
            matches = re.findall(r"TURN\s+(\d+)", text, re.IGNORECASE)
            T.require(len(matches) == 1, "Missing rendered count")
            image = out / (label + ".png")
            m.call("save_screenshot", path=str(image))
            observations.append(
                {
                    "stage": label,
                    "count": int(matches[0]),
                    "screen": raw,
                    "capture": str(image.relative_to(ROOT)),
                    "capture_sha256": T.sha(image),
                }
            )

        try:
            m.call("run_frames", frames=150)
            for line in (program + ("RUN\n" if dragon else "")).splitlines():
                enter(line + "\n")
            observe("initial")
            m.call("run_frames", frames=120)
            observe("idle")
            enter("1\n" if dragon else "1")
            observe("first")
            enter("0\n" if dragon else "0")
            observe("ignored")
            enter("1\n" if dragon else "1")
            observe("second")
            expected = {
                "working": [0, 0, 1, 1, 2],
                "step-three": [0, 0, 3, 3, 6],
                "wrong-reset": [0] * 5,
                "repaired": [0, 0, 1, 1, 2],
                "nonzero": [37, 37, 38, 38, 39],
            }[variant]
            T.require(
                [o["count"] for o in observations] == expected,
                f"{system}/{variant}: wrong sequence",
            )
            result[variant] = {"entered_source": program, "observations": observations}
            print("PASS", system, variant, expected, flush=True)
        finally:
            m.close()
    record = {
        "status": "passed",
        "machine": system,
        "track": track,
        "emulator_sha256": T.sha(args.native / ("emu198x-" + name)),
        "firmware_sha256": T.sha(
            args.firmware_root / name / ("dragon32.rom" if dragon else "ace.rom")
        ),
        "emulator_release": "v0.44.1",
        "sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [
                folder / f"demo.{suffix}",
                folder / f"customise.{suffix}",
                folder / f"mistakes/reset-each-command.{suffix}",
            ]
        },
        "observer_sources": {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in [Path(__file__), ROOT / "scripts/verify-game-loops.py"]
        },
        "cases": result,
    }
    (folder / "verification/variants.json").write_text(
        json.dumps(record, indent=2) + "\n"
    )


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--native", type=Path, required=True)
    p.add_argument("--firmware-root", type=Path, default=Path.home() / ".emu198x/roms")
    a = p.parse_args()
    a.native = a.native.resolve()
    for system in ["dragon-32", "jupiter-ace"]:
        verify(a, system)


if __name__ == "__main__":
    main()
