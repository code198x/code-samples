"""Validate retained calls, source bindings, images and independent destinations.

Fresh font-pixel qualification needs the locally supplied firmware; this check
checks retained hashes and destination semantics, not a fresh emulator run.
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
            if variant == "positive":
                required = [
                    p / "demo.asm",
                    p / "characters.inc",
                    root / "scripts/verify-fixed-characters.py",
                    root / SHARED.relative_to(ROOT) / "systems.json",
                ]
                if c["id"].startswith("sinclair-"):
                    required.append(p / "caller.bas")
                assert set(r["sources"]) == {str(f.relative_to(root)) for f in required}
                assert all(
                    sha(root / path) == digest for path, digest in r["sources"].items()
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
