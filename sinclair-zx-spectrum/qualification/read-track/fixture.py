# SPDX-License-Identifier: MIT
"""Authored Read Track cases; replace unused track39, preserve boot tracks."""

from __future__ import annotations


def cases() -> list[dict]:
    return [
        {"id": "n0-dtl1", "n": 0, "dtl": 1, "fields": [(1, 0, 128, 33)], "eot": 1},
        {"id": "n0-dtl127", "n": 0, "dtl": 127, "fields": [(1, 0, 128, 33)], "eot": 1},
        {"id": "n5", "n": 5, "dtl": 255, "fields": [(1, 5, 4096, 33)], "eot": 1},
        {
            "id": "command0-recorded2",
            "n": 0,
            "dtl": 255,
            "fields": [(1, 2, 512, 33)],
            "eot": 1,
        },
        {
            "id": "represented128",
            "n": 2,
            "dtl": 255,
            "fields": [(1, 2, 128, 33)],
            "eot": 1,
        },
        {
            "id": "reverse-wrap",
            "n": 2,
            "dtl": 255,
            "fields": [(2, 2, 512, 33), (1, 2, 512, 34)],
            "eot": 3,
        },
    ]


def missing_entry_case() -> dict:
    """Valid EDSK omission; decoded as an empty track, not a raw missing DAM."""
    return {
        "id": "missing-entry",
        "n": 2,
        "dtl": 255,
        "fields": [],
        "eot": 1,
        "missing_entry": True,
    }


def reverse_size_case() -> dict:
    """Command N2 independently from a recorded N0 field and128 data bytes."""
    return {
        "id": "command2-recorded0",
        "n": 2,
        "dtl": 255,
        "fields": [(1, 0, 128, 33)],
        "eot": 1,
    }


def n2_dtl_cases() -> list[dict]:
    """Same ordinary N2 field; vary only the command's DTL byte."""
    return [
        {"id": "n2-dtl255", "n": 2, "dtl": 255, "fields": [(1, 2, 512, 33)], "eot": 1},
        {"id": "n2-dtl1", "n": 2, "dtl": 1, "fields": [(1, 2, 512, 33)], "eot": 1},
    ]


def command(case: dict) -> list[int]:
    return [0x42, 0, 39, 0, 1, case["n"], case["eot"], 42, case["dtl"]]


def make(base: bytes, case: dict) -> bytes:
    if len(base) != 194816 or base[:8] != b"MV - CPC":
        raise ValueError("expected standard Build198x 180 KiB disk")
    header = bytearray(base[:256])
    header[:34] = b"EXTENDED CPC DSK File\r\nDisk-Info\r\n"
    header[50:52] = bytes(2)
    header[52:256] = bytes(204)
    tracks = []
    for i in range(39):
        boot = bytearray(base[256 + i * 4864 : 256 + (i + 1) * 4864])
        for sector in range(9):
            boot[30 + 8 * sector : 32 + 8 * sector] = bytes([0, 2])
        tracks.append(bytes(boot))
    if case.get("missing_entry"):
        for i, data in enumerate(tracks):
            header[52 + i] = len(data) // 256
        return bytes(header) + b"".join(tracks)
    track = bytearray(256)
    track[:12] = b"Track-Info\r\n"
    track[16:18] = bytes([39, 0])
    track[18:24] = bytes([0, 0, 2, len(case["fields"]), 42, 229])
    for i, (r, n, length, fill) in enumerate(case["fields"]):
        track[24 + i * 8 : 32 + i * 8] = bytes([39, 0, r, n, 0, 0]) + length.to_bytes(
            2, "little"
        )
        track.extend(bytes([fill]) * length)
    track.extend(bytes(-len(track) % 256))
    tracks.append(bytes(track))
    for i, data in enumerate(tracks):
        header[52 + i] = len(data) // 256
    return bytes(header) + b"".join(tracks)
