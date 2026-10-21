#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Seed three unallocated +3 sectors; never overwrite the source or output."""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "disk-plus3"))
from rearrange import replace_sector_bytes, sector_bytes


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def pattern(sector: int) -> bytes:
    return bytes(((i * 37) ^ (i >> 1) ^ (sector * 33)) & 255 for i in range(512))


def seed(image: bytes) -> tuple[bytes, dict]:
    raw = bytearray(sector_bytes(image))
    used = {0, 1}  # The CP/M directory occupies its first two allocation blocks.
    for offset in range(4608, 4608 + 2048, 32):
        row = raw[offset : offset + 32]
        if row[0] != 0xE5:
            if row[0] > 15:
                raise ValueError("unexpected active directory user")
            used.update(block for block in row[16:32] if block)
    patches = []
    for number in (1, 2, 3):
        logical = (9 * 9 + number - 1) * 512
        blocks = {(logical - 4608) // 1024, (logical + 511 - 4608) // 1024}
        if used & blocks:
            raise ValueError("probe sectors are allocated to a file")
        before = bytes(raw[logical : logical + 512])
        if before != b"\xe5" * 512:
            raise ValueError("expected pristine unallocated probe sectors")
        after = pattern(number)
        raw[logical : logical + 512] = after
        patches.append(
            {
                "track": 9,
                "head": 0,
                "sector": number,
                "container_offset": 512 + 9 * 4864 + (number - 1) * 512,
                "bytes": 512,
                "allocation_blocks": sorted(blocks),
                "before_sha256": digest(before),
                "after_sha256": digest(after),
            }
        )
    output = replace_sector_bytes(image, bytes(raw))
    return output, {
        "schema_version": 1,
        "fixture": "read-data-track9-v1",
        "source_sha256": digest(image),
        "output_sha256": digest(output),
        "used_blocks": sorted(used),
        "patches": patches,
        "recipe_sha256": digest(Path(__file__).read_bytes()),
        "geometry_helper_sha256": digest(
            (Path(__file__).parent.parent / "disk-plus3/rearrange.py").read_bytes()
        ),
        "pattern": "((i*37) XOR (i>>1) XOR (sector*33)) AND255, i=0..511",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("manifest", type=Path)
    args = parser.parse_args()
    output, record = seed(args.source.read_bytes())
    with args.output.open("xb") as file:
        file.write(output)
    with args.manifest.open("x") as file:
        file.write(json.dumps(record, indent=2) + "\n")


if __name__ == "__main__":
    main()
