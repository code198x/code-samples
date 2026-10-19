"""Replay the firmware-free NES OAM and camera checks with a released emulator."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "rendering", ROOT / "scripts/verify-rendering-families.py"
)
assert spec and spec.loader
R = importlib.util.module_from_spec(spec)
spec.loader.exec_module(R)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--emulator", required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    case_args = argparse.Namespace(assembler=args.assembler, nes=args.emulator)
    cases = [
        (0, 0),
        (1, 0),
        (8, 0),
        (9, 8),
        (12, 11),
        (63, 32),
        (64, 0),
        (64, 63),
        (64, 255),
        (65, 0),
        (255, 0),
    ]
    for count, first in cases:
        R.nes_fixture(case_args, out / f"{count}-{first}", count, first)
    try:
        R.nes_fixture(case_args, out / "mutant", 12, 0, True)
    except ValueError as error:
        R.require(
            "OAM mismatch" in str(error), f"Mutant did not reach its oracle: {error}"
        )
    else:
        raise ValueError("Missing OAM attribute write escaped the output guard")
    (out / "results.json").write_text(
        json.dumps(
            {
                "status": "passed",
                "cases": cases,
                "missing_attribute_mutant_rejected": True,
                "observer_sha256": R.sha(Path(__file__)),
                "fixture_sha256": R.sha(ROOT / "scripts/verify-rendering-families.py"),
                "limits": "NROM NTSC CPU/OAM-buffer and horizontal-camera-wrap checks. No screenshot, hardware sprite-evaluation, PAL or original-hardware claim.",
            },
            indent=2,
        )
        + "\n"
    )


if __name__ == "__main__":
    main()
