"""Forge a consistent claim of other program bytes in a native gameplay case.

Used by the tests of the checkers that share the C64, NES, Spectrum and Amiga
case layout (gamekit, worldkit, pools-and-states and their siblings). The
forged case changes one byte of code outside the component's own extents and
keeps the program digest, compressed program, loaded image and loaded digest
consistent with it, so only rebuilding the program can reject the record.
"""

from __future__ import annotations

import hashlib
import zlib
from collections.abc import Callable
from typing import Any

Hunk = Callable[[bytes], tuple[bytes, list[int]]]
# Offset of the loaded image inside the program file.
LOAD_OFFSET = {"commodore-64": 2, "nintendo-entertainment-system": 16}
# The Amiga hunk executable's code starts after a fixed 32-byte header.
HUNK_BODY = 32
# An OFS data block carries 488 bytes of file data.
OFS_DATA = 488


def _owned(case: dict[str, Any]) -> set[int]:
    owned: set[int] = set()
    for prefix in ("helper", "age"):
        if prefix + "_offset" in case:
            start = case[prefix + "_offset"]
            owned |= set(range(start, start + case[prefix + "_code_bytes"]))
    return owned


def _tape_code_offset(tape: bytes) -> int:
    """Offset in a TAP file of the first CODE byte (after block 3's flag)."""
    at = 0
    for _ in range(3):
        at += 2 + int.from_bytes(tape[at : at + 2], "little")
    return at + 3


def forge(case: dict[str, Any], system: str, hunk: Hunk) -> None:
    """Change one byte of the case's program and every field that follows it."""
    owned = _owned(case)
    loaded = case["loaded_bytes"]
    binary = bytearray(zlib.decompress(bytes.fromhex(case["program_zlib"])))
    if system == "commodore-amiga":
        exe = bytearray(zlib.decompress(bytes.fromhex(case["exe_zlib"])))
        _, relocs = hunk(bytes(exe))
        moved = {i + k for i in relocs for k in range(4)}
        i = next(
            i for i in range(case["code_end"]) if i not in owned and i not in moved
        )
        at = HUNK_BODY + i
        chunk = bytes(exe[at - at % OFS_DATA : at - at % OFS_DATA + OFS_DATA])
        on_disk = binary.find(chunk)
        if on_disk < 0:
            raise AssertionError("Executable block not found on the disk image")
        exe[at] ^= 1
        binary[on_disk + at % OFS_DATA] ^= 1
        case["exe_zlib"] = zlib.compress(bytes(exe)).hex()
    else:
        i = next(i for i in range(len(loaded)) if i not in owned)
        if system == "sinclair-zx-spectrum":
            code = _tape_code_offset(bytes(binary))
            length = int.from_bytes(binary[code - 3 : code - 1], "little")
            binary[code + i] ^= 1
            binary[code - 1 + length - 1] ^= 1  # keep the block checksum valid
        else:
            binary[LOAD_OFFSET[system] + i] ^= 1
    loaded[i] ^= 1
    case["program_zlib"] = zlib.compress(bytes(binary)).hex()
    case["program_sha256"] = hashlib.sha256(binary).hexdigest()
    case["loaded_sha256"] = hashlib.sha256(bytes(loaded)).hexdigest()
