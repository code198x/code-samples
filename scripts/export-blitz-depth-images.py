"""Export exact native Blitz framebuffer pixels at the existing publication aspect."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import struct
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("native_png", ROOT / "scripts/check-amiga-command-loops.py")
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native PNG decoder")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
TOPICS = ("object-pool", "game-flow")
VARIANTS = ("working", "wrong")


def project(width: int, height: int, channels: int, pixels: bytes) -> tuple[int, int, int, bytes]:
    assert width > 0 and width % 2 == 0 and height > 0, "Invalid native geometry"
    assert channels in (3, 4) and len(pixels) == width * height * channels, "Incomplete native pixels"
    result = bytearray()
    for offset in range(0, len(pixels), channels * 2):
        first, second = pixels[offset:offset + channels], pixels[offset + channels:offset + channels * 2]
        assert first == second, "A unique framebuffer column would be lost"
        result.extend(first)
    return width // 2, height, channels, bytes(result)


def png(width: int, height: int, channels: int, pixels: bytes) -> bytes:
    assert channels in (3, 4) and len(pixels) == width * height * channels

    def chunk(kind: bytes, data: bytes) -> bytes:
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data) & 0xffffffff)

    stride = width * channels
    rows = b"".join(b"\x00" + pixels[start:start + stride] for start in range(0, len(pixels), stride))
    header = struct.pack(">IIBBBBB", width, height, 8, 6 if channels == 4 else 2, 0, 0, 0)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", header) + chunk(b"IDAT", zlib.compress(rows, 9)) + chunk(b"IEND", b"")


def folder(topic: str) -> Path:
    assert topic in TOPICS, "Unknown native topic"
    return ROOT / "commodore-amiga/patterns/blitz/framework" / topic / "verification"


def observations(topic: str, write: bool = False) -> dict[str, Any]:
    base = folder(topic)
    native = json.loads((base / "results.json").read_text())
    result: dict[str, Any] = {}
    for name in VARIANTS:
        raw, published = base / ("caller-" + name + ".png"), base / ("published-" + name + ".png")
        raw_data = raw.read_bytes()
        raw_hash = hashlib.sha256(raw_data).hexdigest()
        assert native["cases"][name]["image"] == raw.name and native["cases"][name]["image_sha256"] == raw_hash, "Changed native capture identity"
        width, height, channels, pixels = C.png(raw)
        assert (width, height) == (1536, 576), "Wrong original native capture geometry"
        expected = project(width, height, channels, bytes(pixels))
        encoded = png(*expected)
        if write:
            if published.exists():
                assert published.read_bytes() == encoded, "Refusing to replace a different published capture"
            else:
                published.write_bytes(encoded)
        decoded = C.png(published)
        assert (*decoded[:3], bytes(decoded[3])) == expected, "Published pixels differ from exact native projection"
        result[name] = {"raw": raw.name, "published": published.name,
                        "raw_sha256": raw_hash, "published_sha256": hashlib.sha256(published.read_bytes()).hexdigest(),
                        "raw_size": [width, height], "published_size": list(expected[:2]),
                        "operation": "Remove only identical adjacent framebuffer columns; every source pair checked"}
    return result


def check(topic: str, record: dict[str, Any] | None = None) -> None:
    actual = record if record is not None else json.loads((folder(topic) / "published-images.json").read_text())
    assert actual == observations(topic), "Changed publication capture manifest"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    for topic in TOPICS:
        if args.write:
            target = folder(topic) / "published-images.json"
            assert not target.exists(), "Preserve earlier publication evidence"
            target.write_text(json.dumps(observations(topic, write=True), indent=2) + "\n")
        check(topic)
    print(len(TOPICS) * len(VARIANTS), "native Blitz capture exports and all original pixel pairs verified")


if __name__ == "__main__":
    main()
