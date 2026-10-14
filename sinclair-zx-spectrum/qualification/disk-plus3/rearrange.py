#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Rearrange only this diagnostic's type-0 disk; not a general disk editor."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

# Logical CODE blocks alternate low/high tracks and leave free blocks between.
FRAGMENTED = [
    3,
    43,
    5,
    41,
    7,
    39,
    9,
    37,
    11,
    35,
    13,
    33,
    15,
    31,
    17,
    29,
    19,
    27,
    21,
    25,
    23,
]
MODES = ("fragmented", "reordered", "combined", "boundary")


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def rearrange(image: bytes, mode: str) -> tuple[bytes, dict]:
    require(mode in MODES, "unknown fixture layout")
    require(len(image) == 194816, "expected standard 180 KiB DSK")
    require(
        image[:34] == b"MV - CPCEMU Disk-File\r\nDisk-Info\r\n"
        and image[48:52] == bytes([40, 1, 0, 19]),
        "unexpected container",
    )
    original = bytearray()
    for track in range(40):
        start = 256 + track * 4864
        header = image[start : start + 256]
        require(
            header[:12] == b"Track-Info\r\n"
            and header[16:18] == bytes([track, 0])
            and header[20:24] == bytes([2, 9, 82, 229]),
            "unexpected track",
        )
        require(
            all(
                header[24 + s * 8 : 32 + s * 8]
                == bytes([track, 0, s + 1, 2, 0, 0, 0, 0])
                for s in range(9)
            ),
            "unexpected sectors",
        )
        original.extend(image[start + 256 : start + 4864])
    entries = [bytes(original[4608 + i * 32 : 4640 + i * 32]) for i in range(3)]
    require(
        entries
        == [
            b"\0DISK       \0\0\0\x02\x02" + bytes(15),
            b"\0DIAG    BIN\0\0\0\x80" + bytes(range(3, 19)),
            b"\0DIAG    BIN\x01\0\0\x21" + bytes(range(19, 24)) + bytes(11),
        ],
        "expected the original contiguous two-extent diagnostic directory",
    )
    require(original[4704:6656] == b"\xe5" * 1952, "unexpected extra directory entries")
    # Never copy from the destination: source/destination block sets overlap.
    disk = bytearray(original)
    blocks = FRAGMENTED if mode != "reordered" else list(range(3, 24))
    if mode == "boundary":
        # Move a full checked-data block, not the partly used final file block.
        # Physical 174 occupies track 39 sectors 7/8; sector 9 is unallocated.
        blocks = [*range(3, 22), 174, 23]
    require(
        all(
            original[4608 + b * 1024 : 5632 + b * 1024] == b"\xe5" * 1024
            for b in blocks
            if b > 23
        ),
        "destination block is not unused",
    )
    if mode != "reordered":
        for block in range(3, 24):
            disk[4608 + block * 1024 : 5632 + block * 1024] = b"\xe5" * 1024
        for old, new in zip(range(3, 24), blocks, strict=True):
            disk[4608 + new * 1024 : 5632 + new * 1024] = original[
                4608 + old * 1024 : 5632 + old * 1024
            ]
    entries[1] = entries[1][:16] + bytes(blocks[:16])
    entries[2] = entries[2][:16] + bytes(blocks[16:]) + bytes(11)
    # Extent 1 precedes extent 0; extent 0 is beyond the first directory sector.
    slots = [2, 17, 0] if mode != "fragmented" else [0, 1, 2]
    if mode == "boundary":
        slots = [0, 1, 63]
    disk[4608:6656] = b"\xe5" * 2048
    for entry, slot in zip(entries, slots, strict=True):
        disk[4608 + slot * 32 : 4640 + slot * 32] = entry
    result = bytearray(image)
    for track in range(40):
        result[512 + track * 4864 : 512 + track * 4864 + 4608] = disk[
            track * 4608 : (track + 1) * 4608
        ]
    output = bytes(result)
    return output, {
        "schema_version": 1,
        "mode": mode,
        "input_sha256": digest(image),
        "output_sha256": digest(output),
        "code_block_moves": [
            {"from": old, "to": new}
            for old, new in zip(range(3, 24), blocks, strict=True)
        ],
        "directory_moves": [{"from": old, "to": new} for old, new in enumerate(slots)],
        "changed_bytes": sum(a != b for a, b in zip(image, output, strict=True)),
        "route": "qualification fixture rearrangement after Build198x mastering",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=MODES)
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    output, report = rearrange(args.source.read_bytes(), args.mode)
    # Exclusive creation refuses both an existing output and a source alias.
    with args.output.open("xb") as stream:
        stream.write(output)
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
