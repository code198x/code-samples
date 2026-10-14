#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Fill the roundtrip diagnostic's directory while retaining free data blocks."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from rearrange import digest, replace_sector_bytes, require, sector_bytes


def prepare(image: bytes, *, free_slot: bool = False) -> tuple[bytes, dict]:
    original = sector_bytes(image)
    require(
        original[4608:4672]
        == (
            b"\0DISK       \0\0\0\x03\x02"
            + bytes(15)
            + b"\0DIAG    BIN\0\0\0\x03\x03"
            + bytes(15)
        ),
        "expected the two-file roundtrip directory",
    )
    require(original[4672:6656] == b"\xe5" * 1984, "unexpected extra directory entry")
    require(
        original[8704:] == b"\xe5" * (184320 - 8704), "expected unused destination area"
    )
    header = bytearray(original[7680:7808])
    require(
        header[:11] == b"PLUS3DOS\x1a\x01\0"
        and sum(header[:127]) % 256 == header[127]
        and header[11:22] == bytes.fromhex("0801000003880000800000"),
        "expected the roundtrip CODE header",
    )
    count = 61 if free_slot else 62
    disk = bytearray(original)
    added = []
    header[11:15] = (129).to_bytes(4, "little")
    header[16:18] = (1).to_bytes(2, "little")
    header[127] = sum(header[:127]) % 256
    for i in range(count):
        slot, block = i + 2, i + 4
        name = f"FILL{i:04}BIN"
        entry = b"\0" + name.encode() + bytes(3) + bytes([2, block]) + bytes(15)
        disk[4608 + slot * 32 : 4640 + slot * 32] = entry
        file = bytes(header) + bytes([i])
        disk[4608 + block * 1024 : 4864 + block * 1024] = file + bytes(127)
        added.append(
            {
                "slot": slot,
                "name": name,
                "block": block,
                "file_bytes": 129,
                "sha256": digest(file),
            }
        )
    output = replace_sector_bytes(image, disk)
    return output, {
        "schema_version": 1,
        "mode": "save-directory-free-slot" if free_slot else "save-directory-full",
        "input_sha256": digest(image),
        "output_sha256": digest(output),
        "added_files": added,
        "directory_entries": count + 2,
        "free_directory_slots": 62 - count,
        "used_file_blocks": count + 2,
        "free_file_blocks": 173 - (count + 2),
        "changed_bytes": sum(a != b for a, b in zip(image, output, strict=True)),
        "route": "qualification fixture after Build198x mastering; no production mastering option",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--free-slot", action="store_true")
    args = parser.parse_args()
    result, report = prepare(args.source.read_bytes(), free_slot=args.free_slot)
    with args.output.open("xb") as stream:
        stream.write(result)
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
