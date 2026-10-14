#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Fill the roundtrip diagnostic's data blocks while retaining directory space."""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from fill_save_directory import roundtrip_disk
from rearrange import digest, replace_sector_bytes


def prepare(image: bytes, *, free_space: bool = False) -> tuple[bytes, dict]:
    original = roundtrip_disk(image)
    disk = bytearray(original)
    end = 173 if free_space else 175
    added = []
    for index, first in enumerate(range(4, end, 16)):
        blocks = list(range(first, min(first + 16, end)))
        length = len(blocks) * 1024
        header = bytearray(original[7680:7808])
        header[11:15] = length.to_bytes(4, "little")
        header[16:18] = (length - 128).to_bytes(2, "little")
        header[127] = sum(header[:127]) % 256
        contents = bytes(header) + bytes([index]) * (length - 128)
        name = f"FILL{index:04}BIN"
        slot = index + 2
        disk[4608 + slot * 32 : 4640 + slot * 32] = (
            b"\0"
            + name.encode()
            + bytes(3)
            + bytes([len(blocks) * 8])
            + bytes(blocks)
            + bytes(16 - len(blocks))
        )
        disk[4608 + first * 1024 : 4608 + (blocks[-1] + 1) * 1024] = contents
        added.append(
            {
                "slot": slot,
                "name": name,
                "blocks": blocks,
                "file_bytes": length,
                "sha256": digest(contents),
            }
        )
    output = replace_sector_bytes(image, disk)
    return output, {
        "schema_version": 1,
        "mode": "save-disk-free-space" if free_space else "save-disk-full",
        "input_sha256": digest(image),
        "output_sha256": digest(output),
        "added_files": added,
        "directory_entries": 13,
        "free_directory_slots": 51,
        "used_file_blocks": end - 2,
        "free_file_blocks": 175 - end,
        "changed_bytes": sum(a != b for a, b in zip(image, output, strict=True)),
        "route": "qualification fixture after Build198x mastering; no production mastering option",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--free-space", action="store_true")
    args = parser.parse_args()
    result, report = prepare(args.source.read_bytes(), free_space=args.free_space)
    with args.output.open("xb") as stream:
        stream.write(result)
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
