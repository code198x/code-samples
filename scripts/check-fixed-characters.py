"""Validate retained calls, rebuilt programs, images and independent destinations.

Fresh font-pixel qualification needs the locally supplied firmware; this check
checks retained hashes and destination semantics, not a fresh emulator run.

A record is stale when its program's bytes change: each variant's driver is
rebuilt through the recorder's own build() with the Asm198x release the
record pins and compared with its fixture_sha256. The ZX80 and ZX81 callers
are typed in, so caller.bas text is part of their program (rule 2). Other
source digests are provenance only.
"""

from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SHARED = ROOT / "cross-platform/patterns/rendering/fixed-characters"
spec = importlib.util.spec_from_file_location("model", SHARED / "model.py")
assert spec and spec.loader
M = importlib.util.module_from_spec(spec)
spec.loader.exec_module(M)
SPEC = importlib.util.spec_from_file_location(
    "fixed_character_bytes", Path(__file__).with_name("evidence_bytes.py")
)
assert SPEC and SPEC.loader
E = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(E)


def sha(p: Path) -> str:
    return hashlib.sha256(p.read_bytes()).hexdigest()


def validate(root: Path = ROOT) -> int:
    count = 0
    for c in json.loads((root / SHARED.relative_to(ROOT) / "systems.json").read_text()):
        p = root / c["id"] / "patterns/assembly/rendering/fixed-characters"
        out = p / "verification"
        summary = json.loads((out / "results.json").read_text())
        assert summary["status"] == "passed" and summary["machine_id"] == c["id"]
        assert len(summary["records"]) == 3
        expected, flags = M.expected(c)
        for n, variant in enumerate(["positive", "wrong-stride", "unsafe-count"]):
            r = json.loads((out / (variant + ".json")).read_text())
            assert r == summary["records"][n]
            assert (
                r["variant"] == variant
                and r["status"] == "passed"
                and r["flags"][-1] == 239
            )
            assert r["memory_sha256"] == sha(out / (variant + ".bin")) and r[
                "capture_sha256"
            ] == sha(out / (variant + ".png"))
            same = (out / (variant + ".bin")).read_bytes() == expected and r["flags"][
                : len(flags)
            ] == flags
            assert (
                same == (variant == "positive")
                and r["independent_memory_match"] == same
            )
            assert r["pixel_match"] == (variant == "positive")
            # The record is stale when its program's bytes change, not its sources' text.
            E.require_program(
                E.function(
                    root / "scripts/verify-fixed-characters.py",
                    "build",
                    (c["id"], E.ASSEMBLER, variant),
                    p,
                    ("build/demo.bin",),
                ),
                "build/demo.bin",
                r["assembler_sha256"],
                recorded_sha256=r["fixture_sha256"],
            )
            if variant == "positive":
                if c["id"].startswith("sinclair-"):
                    # Typed in, so its text is the program (rule 2).
                    typed = str((p / "caller.bas").relative_to(root))
                    assert r["sources"][typed] == sha(p / "caller.bas"), (
                        "Typed caller differs from the record: " + typed
                    )
                assert (
                    r["active_origin"] and r["firmware_sha256"] and r["emulator_sha256"]
                )
            count += len(c["cases"])
    assert count > 0
    return count


if __name__ == "__main__":
    print(
        "Retained fixed-character evidence:",
        validate(),
        "completed calls; four machines, eight completed fault controls",
    )
