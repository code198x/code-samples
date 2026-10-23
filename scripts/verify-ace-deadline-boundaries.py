"""Execute a second FORTH caller and a real signed-comparison fault in the ROM."""

from __future__ import annotations

import argparse
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "native", ROOT / "scripts/verify-ace-deadline.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
T = V.T
CASES = [
    (0, 0, 0),
    (100, 100, 1),
    (100, 109, 10),
    (100, 110, 10),
    (100, 125, 10),
    (65530, 5, 100),
    (0, 65535, 65535),
    (65535, 0, 65535),
    (100, 101, 0),
    (0, 65535, 1),
    (12345, 12345, 65535),
    (65535, 65535, 1),
    (0, 32768, 32769),
    (0, 32768, 32768),
    (60000, 10000, 30000),
    (65535, 32767, 40000),
]


def execute(args: argparse.Namespace, wrong: bool) -> dict:
    machine = T.Machine([str(args.emulator), "--mcp", "--rom", str(args.firmware)])
    source = (V.FOLDER / "routines.fth").read_text()
    if wrong:
        T.require(source.count(" U< ") == 1, "Ambiguous fault mutation")
        source = source.replace(" U< ", " < ")
    records = []
    try:
        machine.call("run_frames", frames=150)
        for text in [source, (V.FOLDER / "boundaries.fth").read_text()]:
            for line in text.splitlines():
                V.enter(machine, line)
        here = V.read(machine, 15415)
        for index, (previous, now, duration) in enumerate(CASES):
            V.enter(machine, f"77 {now} {previous} {duration} {index} DCASE")
            raw, text = V.screen(machine)
            match = re.match(
                r"\s*FLAG\s+(\d+)\s+LEFT\s+(\d+)\s+DELTA\s+(\d+)\s+CASE\s+(\d+)\s+STACK\s+(\d+)",
                text,
                re.IGNORECASE,
            )
            T.require(
                match is not None and int(match[4]) == index and int(match[5]) == 77,
                f"Boundary caller incomplete/stack damaged: {text}",
            )
            actual = list(map(int, match.group(1, 2, 3)))
            elapsed = (now - previous) % 65536
            expired = int(duration > 0 and elapsed >= duration)
            expected = [expired, max(0, duration - elapsed) if duration else 0, elapsed]
            top = V.read(machine, 15419)
            T.require(top == here + 12, "Boundary caller leaked stack")
            records.append(
                {
                    "previous": previous,
                    "now": now,
                    "duration": duration,
                    "actual": actual,
                    "expected": expected,
                    "index": index,
                    "tag": 77,
                    "data_top": top,
                    "screen_hex": bytes(raw).hex(),
                    "oracle_matches": actual == expected,
                }
            )
            print(
                "signed-fault" if wrong else "working",
                index,
                actual,
                expected,
                flush=True,
            )
        matches = [x["oracle_matches"] for x in records]
        T.require(
            not all(matches) if wrong else all(matches),
            "Arithmetic control did not distinguish unsigned implementation from signed mistake",
        )
        image = (
            V.FOLDER
            / "verification"
            / ("signed-comparison.png" if wrong else "boundaries.png")
        )
        machine.call("save_screenshot", path=str(image))
        return {
            "wrong_signed_compare": wrong,
            "dictionary": here,
            "cases": records,
            "image": image.name,
            "image_sha256": T.sha(image),
        }
    finally:
        machine.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--emulator", required=True, type=Path)
    p.add_argument(
        "--firmware",
        type=Path,
        default=Path.home() / ".emu198x/roms/jupiter-ace/ace.rom",
    )
    args = p.parse_args()
    records = {
        name: execute(args, wrong)
        for name, wrong in [("working", False), ("signed-fault", True)]
    }
    (V.FOLDER / "verification/boundaries.json").write_text(
        json.dumps(
            {
                "emulator_sha256": T.sha(args.emulator),
                "firmware_sha256": T.sha(args.firmware),
                "cases": records,
            },
            indent=2,
        )
        + "\n"
    )
