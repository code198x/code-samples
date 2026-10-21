"""Check retained evidence bindings; this is not a fresh native execution."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "observer", Path(__file__).with_name("verify-tia-maria.py")
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
ROOT = Path(__file__).resolve().parents[1]
SHARED = Path("cross-platform/patterns/rendering/tia-maria/verification")


def validate(root: Path = ROOT) -> int:
    shared = root / SHARED
    bindings = json.loads((shared / "bindings.json").read_text())
    for relative, digest in bindings.items():
        V.require(V.T.T.sha(root / relative) == digest, f"Stale evidence: {relative}")
    bounds = json.loads((shared / "bounds.json").read_text())
    V.require(
        [
            (r["system"], r["rejected_calls"], r["whole_allocation_unchanged"])
            for r in bounds
        ]
        == [("atari-2600", 6, True), ("atari-7800", 7, True)],
        "Bounds coverage",
    )
    count = 0
    for system, (name, _) in V.CONFIG.items():
        folder = root / system / "patterns/assembly/rendering" / name
        records = json.loads((folder / "verification/results.json").read_text())
        variants = (
            ["native", "reflection", "wrong-bit", "wrong-period", "late-registers"]
            if system == "atari-2600"
            else ["native", "wrong-width", "wrong-position"]
        )
        V.require(len(records) == len(variants), "Missing execution variants")
        for record, variant in zip(records, variants, strict=True):
            out = folder / "verification"
            V.require(
                record == json.loads((out / f"{variant}.json").read_text()),
                "Record copy disagrees",
            )
            V.require(
                record["completed"] is True and record["system"] == system,
                "Incomplete/wrong machine",
            )
            frame = out / f"{variant}.png"
            V.require(
                V.T.T.sha(frame) == record["frame_sha256"], "Stale native capture"
            )
            size, pixels = V.T.raster(frame)
            _, want_size, want_pixels = V.expected(system, variant == "reflection")
            V.require(size == want_size, "Capture geometry")
            good = variant in ["native", "reflection"]
            memory_ok = record["memory"] == record["expected_memory"]
            if system == "atari-2600":
                want_memory = V.expected(system)[0]
                V.require(
                    record["expected_memory"] == want_memory,
                    "Independent picture binding",
                )
            else:
                m = record["memory"]
                g = m[0] + m[2] * 256
                V.require(
                    record["expected_memory"]
                    == [g & 255, 30, g >> 8, 32, g & 255, 30, g >> 8, 152, 0, 0],
                    "Independent list binding",
                )
            period_ok = record["period_colour_clocks"] in (None, 59736)
            V.require(
                (memory_ok and pixels == want_pixels and period_ok) == good,
                "Good/faulty control classification",
            )
            if good and variant == "native":
                for filename, digest in record["staged_source_sha256"].items():
                    V.require(
                        V.T.T.sha(folder / filename) == digest, "Native source binding"
                    )
            count += 1
    V.require(count == 8, "No/partial records checked")
    return count


if __name__ == "__main__":
    print(
        f"Validated {validate()} retained native drawing observations; no fresh execution claimed"
    )
