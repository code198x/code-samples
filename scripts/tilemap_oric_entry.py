"""Check the exact BASIC text accepted by stock Oric ROM keyboard entry.

Read the ROM's own keyword table to detokenise linked program lines. Retry
incorrectly typed lines through the keyboard; never patch guest program RAM.
"""

from __future__ import annotations

from collections.abc import Callable
from pathlib import Path
from typing import Any


def normal(text: str) -> str:
    quoted = False
    out = []
    for ch in text:
        if ch == '"':
            quoted = not quoted
        if quoted or not ch.isspace():
            out.append(ch.upper())
    return "".join(out)


def keywords(rom: Path) -> list[str]:
    data = rom.read_bytes()
    start = data.find(b"EN\xc4EDI\xd4")
    if start < 0:
        raise ValueError("Oric ROM keyword table not recognised")
    words = []
    word = ""
    for byte in data[start:]:
        if byte == 0:
            break
        word += chr(byte & 127)
        if byte & 128:
            words.append(word)
            word = ""
    for index, value in [
        (0, "END"),
        (13, "FOR"),
        (16, "NEXT"),
        (19, "DIM"),
        (27, "GOSUB"),
        (58, "PRINT"),
        (84, "="),
    ]:
        if words[index] != value:
            raise ValueError("Unexpected Oric keyword table")
    return words


def accepted(machine: Any, words: list[str]) -> dict[int, str]:
    raw = []
    for offset in range(0, 4096, 256):
        raw += machine.call("memory_read", addr=0x501 + offset, len=256)["bytes"]
    result = {}
    address = 0x501
    for _ in range(300):
        offset = address - 0x501
        if not 0 <= offset < len(raw) - 4:
            raise ValueError("Oric program link outside readback window")
        following = raw[offset] + 256 * raw[offset + 1]
        if following == 0:
            return result
        if not address + 5 <= following <= 0x501 + 4096:
            raise ValueError("Invalid Oric line link")
        number = raw[offset + 2] + 256 * raw[offset + 3]
        body = raw[offset + 4 : following - 0x501 - 1]
        if raw[following - 0x501 - 1] != 0:
            raise ValueError("Oric line is not terminated")
        quoted = False
        text = ""
        for byte in body:
            if byte == 34:
                quoted = not quoted
            if byte >= 128 and not quoted:
                if byte - 128 >= len(words):
                    raise ValueError("Unknown Oric token")
                text += words[byte - 128]
            else:
                text += chr(byte)
        if number in result:
            raise ValueError("Duplicate Oric line")
        result[number] = normal(text)
        address = following
    raise ValueError("Oric line chain exceeds bounded readback")


def ensure(
    machine: Any, source: str, rom: Path, type_line: Callable[[str], None]
) -> int:
    # Verification-only caller setup: stop the ROM cursor blinking in otherwise
    # identical screenshots. CHR$(17) is the cursor toggle documented in the
    # Oric Atmos manual (Control Characters); reset starts with cursor enabled.
    # https://thespider.oric.org/manuals/Oric-Atmos_Manual.pdf
    source = "4 PRINT CHR$(17);\n" + source
    expected = {
        int(line.split(maxsplit=1)[0]): normal(line.split(maxsplit=1)[1])
        for line in source.splitlines()
    }
    original = {int(line.split(maxsplit=1)[0]): line for line in source.splitlines()}
    words = keywords(rom)
    repairs = 0
    for attempt in range(7):
        # Inserting/replacing a line relocates the linked program and rebuilds
        # its pointers. Do not read it, or send the next line, while ROM edits.
        machine.call("run_frames", frames=120)
        actual = accepted(machine, words)
        missing = [n for n, text in expected.items() if actual.get(n) != text]
        extra = sorted(set(actual) - set(expected))
        if not missing and not extra:
            return repairs
        if attempt == 6:
            raise ValueError(
                f"Oric keyboard source still differs: {[(n, expected[n], actual.get(n)) for n in missing][:4]}; extra={extra}"
            )
        for n in extra:
            type_line(str(n))
            machine.call("run_frames", frames=120)
            repairs += 1
        for n in missing:
            type_line(original[n])
            machine.call("run_frames", frames=120)
            repairs += 1
    raise AssertionError("Unreachable")
