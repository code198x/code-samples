"""Check retained evidence bindings; this is not a fresh native execution."""

from __future__ import annotations

import importlib.util
import json
import tempfile
from pathlib import Path

SPEC = importlib.util.spec_from_file_location(
    "observer", Path(__file__).with_name("verify-tia-maria.py")
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
CUSTOM_SPEC = importlib.util.spec_from_file_location(
    "custom", Path(__file__).with_name("verify-tia-maria-customise.py")
)
assert CUSTOM_SPEC and CUSTOM_SPEC.loader
C = importlib.util.module_from_spec(CUSTOM_SPEC)
CUSTOM_SPEC.loader.exec_module(C)
BYTES_SPEC = importlib.util.spec_from_file_location(
    "tia_maria_bytes", Path(__file__).with_name("evidence_bytes.py")
)
assert BYTES_SPEC and BYTES_SPEC.loader
E = importlib.util.module_from_spec(BYTES_SPEC)
BYTES_SPEC.loader.exec_module(E)
ROOT = Path(__file__).resolve().parents[1]
SHARED = Path("cross-platform/patterns/rendering/tia-maria/verification")


def is_record(relative: str) -> bool:
    """A retained record file, as opposed to a source or script it was made from."""
    return "verification" in Path(relative).parts


def assembler_pin(shared: Path) -> str:
    """The Asm198x binary the records were built with, from the bound tools.json."""
    tools = json.loads((shared / "tools.json").read_text())
    return next(t["binary_sha256"] for t in tools if t["tool"] == "asm198x")


def validate(root: Path = ROOT) -> int:
    with tempfile.TemporaryDirectory(prefix="tia-maria-bytes-") as temporary:
        return _validate(root, Path(temporary))


def _validate(root: Path, staging: Path) -> int:
    shared = root / SHARED
    bindings = json.loads((shared / "bindings.json").read_text())
    # Record files stay bound. Sources and scripts are provenance: the
    # rebuilt cartridges below decide whether a record is stale.
    for relative, digest in bindings.items():
        if is_record(relative):
            V.require(
                V.T.T.sha(root / relative) == digest, f"Stale evidence: {relative}"
            )
    pin = assembler_pin(shared)
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
    for system, (name, ext) in V.CONFIG.items():
        folder = root / system / "patterns/assembly/rendering" / name
        records = json.loads((folder / "verification/results.json").read_text())
        variants = (
            ["native", "reflection", "wrong-bit", "wrong-period", "late-registers"]
            if system == "atari-2600"
            else [
                "native",
                "wrong-width",
                "wrong-position",
                "short-width",
                "bad-terminator",
            ]
        )
        variants += [
            c["variant"] + "-fixed" for c in V.MISTAKES if c["system"] == system
        ]
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
            V.require(
                record["variant"] == ("normal" if variant == "native" else variant),
                "Variant identity",
            )
            good = variant in ["native", "reflection"] or variant.endswith("-fixed")
            _, _, symptom_pixels = V.expected(
                system, variant == "reflection", "" if good else variant
            )
            V.require(
                record["predicted_symptom_match"] and pixels == symptom_pixels,
                "Predicted diagnostic symptom",
            )
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
            # The record is stale when its cartridge's bytes change, not its
            # sources' text. Rebuild from the same staged copy the recorder ran.
            staged = staging / system / variant
            staged.mkdir(parents=True)
            V.stage(system, "" if variant == "native" else variant, staged, root)
            try:
                E.require_program(
                    E.make(staged, (f"build/demo.{ext}",)),
                    f"build/demo.{ext}",
                    pin,
                    recorded_sha256=record["cart_sha256"],
                )
            except AssertionError as error:
                # The staged copy is outside the tree, so name what was staged.
                raise AssertionError(f"{error} ({system} {variant})") from None
            count += 1
    for case, (machine, name, ext) in C.CASES.items():
        folder = root / machine / "patterns/assembly/rendering" / name / "customise"
        record = json.loads((folder / "verification" / (case + ".json")).read_text())
        V.require(
            record["completed"]
            and record["case"] == case
            and record["system"] == machine,
            "Custom caller identity/completion",
        )
        E.require_program(
            E.make(folder, (f"build/{case}.{ext}",)),
            f"build/{case}.{ext}",
            pin,
            recorded_sha256=record["cart_sha256"],
        )
        frame = folder / "verification" / (case + ".png")
        V.require(V.T.T.sha(frame) == record["frame_sha256"], "Custom image binding")
        memory, size, pixels = C.expected(case)
        V.require(
            V.T.raster(frame) == (size, pixels), "Custom independent pixels/palette"
        )
        if case == "ships":
            m = record["memory"]
            g = m[0] + 256 * m[2]
            memory = [g & 255, 29, g >> 8, 24, g & 255, 61, g >> 8, 100, 0, 0]
        V.require(record["memory"] == memory, "Custom independent buffer/header")
        V.require(
            record["period_colour_clocks"] == (None if case == "ships" else 59736),
            "Custom field timing",
        )
        count += 1
    V.require(count == 19, "No/partial records checked")
    return count


if __name__ == "__main__":
    print(
        f"Validated {validate()} retained native drawing observations; no fresh execution claimed"
    )
