"""Publish original Ace PNG bytes without resampling or changing pixels."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "ace_pool_check", ROOT / "scripts/check-ace-object-pool.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native image tools")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
TOPICS = ("object-pool", "game-flow")
VARIANTS = ("working", "wrong")


def folder(topic: str) -> Path:
    C.T.require(topic in TOPICS, "Unknown Ace publication topic")
    return ROOT / "jupiter-ace/patterns/forth/framework" / topic / "verification"


def observations(topic: str, write: bool = False) -> dict[str, Any]:
    base = folder(topic)
    result = {}
    for name in VARIANTS:
        if topic == "object-pool":
            proof = json.loads((base / ("callers-" + name + ".json")).read_text())
            C.T.require(proof["complete"] is True, "Incomplete native caller")
            capture = proof["capture"]
            source = base / ("callers-" + name + ".png")
            sha = capture["sha256"]
        else:
            proof = json.loads((base / "native.json").read_text())
            capture = proof["cases"][name]["resumed_capture"]
            source = base / (name + "-resumed.png")
            sha = capture["image_sha256"]
        target = base / ("published-" + name + ".png")
        C.T.require(
            capture["image"] == source.name and C.T.sha(source) == sha,
            "Changed native figure identity",
        )
        decoded = C.P.png(source)
        C.T.require(decoded[:3] == (320, 288, 4), "Wrong original Ace figure geometry")
        if write:
            if target.exists():
                C.T.require(
                    target.read_bytes() == source.read_bytes(),
                    "Preserve different published image",
                )
            else:
                target.write_bytes(source.read_bytes())
        C.T.require(
            target.read_bytes() == source.read_bytes(),
            "Published PNG bytes differ from native source",
        )
        published = C.P.png(target)
        C.T.require(
            published[:3] == decoded[:3] and bytes(published[3]) == bytes(decoded[3]),
            "Published pixels differ",
        )
        result[name] = {
            "raw": source.name,
            "published": target.name,
            "raw_sha256": sha,
            "published_sha256": C.T.sha(target),
            "raw_size": [320, 288],
            "published_size": [320, 288],
            "operation": "Copy original PNG bytes unchanged",
        }
    return result


def check(topic: str, record: dict[str, Any] | None = None) -> None:
    record = (
        record
        if record is not None
        else json.loads((folder(topic) / "published-images.json").read_text())
    )
    C.T.require(record == observations(topic), "Changed native publication manifest")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    for topic in TOPICS:
        if args.write:
            target = folder(topic) / "published-images.json"
            C.T.require(not target.exists(), "Preserve earlier publication evidence")
            target.write_text(
                json.dumps(observations(topic, write=True), indent=2) + "\n"
            )
        check(topic)
    print("Four unchanged original-ROM Ace PNG exports passed")


if __name__ == "__main__":
    main()
