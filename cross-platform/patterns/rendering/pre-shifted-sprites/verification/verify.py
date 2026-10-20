"""Reconstruct prepared masks as three-state pixels; reject corrupted payloads."""

from __future__ import annotations

import argparse
import copy
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("prepare", ROOT / "prepare.py")
assert spec and spec.loader
P = importlib.util.module_from_spec(spec)
spec.loader.exec_module(P)


def check(rows: list[str], system: str, prepared: list[tuple[bytes, bytes]]) -> int:
    width = 32 if system == "amiga" else 24
    phases = 16 if system == "amiga" else 8
    if len(prepared) != phases:
        raise ValueError("Phase count mismatch")
    count = 0
    for phase, (mask, image) in enumerate(prepared):
        if len(mask) != width * 2 or len(image) != width * 2:
            raise ValueError("Phase length mismatch")
        for y, row in enumerate(rows):
            expected = "." * phase + row + "." * (width - phase - 16)
            actual = ""
            for x in range(width):
                n = y * (width // 8) + x // 8
                bit = 128 >> (x % 8)
                transparent = (
                    not (mask[n] & bit) if system == "amiga" else bool(mask[n] & bit)
                )
                if transparent and image[n] & bit:
                    raise ValueError("Transparent image-bit mismatch")
                actual += "." if transparent else ("1" if image[n] & bit else "0")
                count += 1
            if actual != expected:
                raise ValueError("Prepared pixel mismatch")
    return count


def verify() -> dict:
    rows = P.validate(json.loads((ROOT / "sprite.json").read_text()))
    counts = {}
    controls = {}
    for system in ["spectrum", "bbc", "amiga"]:
        prepared = P.phases(rows, system)
        counts[system] = check(rows, system, prepared)
        for kind in ["mask", "image"]:
            broken = copy.deepcopy(prepared)
            mask, image = map(bytearray, broken[0])
            target = mask if kind == "mask" else image
            target[0] ^= 128
            broken[0] = (bytes(mask), bytes(image))
            try:
                check(rows, system, broken)
            except ValueError as error:
                controls[system + "-" + kind] = str(error)
            else:
                raise ValueError("Corrupted " + kind + " escaped pixel oracle")
        for prefix in ["sprite", "other_sprite"]:
            text = P.assembly(rows, system, prefix)
            assert prefix + "_phase_table:" in text and prefix + "_assets_end:" in text
    invalid = [[], ["x" * 16] * 16, ["." * 15] * 16, ["." * 16] * 15]
    for value in invalid:
        try:
            P.validate(value)
        except ValueError:
            pass
        else:
            raise ValueError("Invalid artwork accepted")
    try:
        P.assembly(rows, "spectrum", "bad-prefix")
    except ValueError:
        pass
    else:
        raise ValueError("Invalid assembly prefix accepted")
    return {
        "status": "passed",
        "pixel_samples": counts,
        "rejected_payload_controls": controls,
        "invalid_inputs_rejected": 5,
    }


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", type=Path, required=True)
    a = p.parse_args()
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.unlink(missing_ok=True)
    a.output.write_text(json.dumps(verify(), indent=2) + "\n")
    print("All prepared pixels, payload controls and invalid inputs verified")
