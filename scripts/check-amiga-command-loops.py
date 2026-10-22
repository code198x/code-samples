"""Read native framebuffer digits and independently check command-loop arithmetic.

This rechecks retained execution, not fresh emulation. Font shapes were inspected
in the native captures; recognition uses fixed glyphs, never recorded counter
values. Unexpected glyphs, blank screens and a requester cannot pass.
"""

from __future__ import annotations

import hashlib
import json
import struct
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DIGITS = {
    "0": (120, 204, 220, 252, 236, 204, 120, 0),
    "1": (48, 112, 240, 48, 48, 48, 48, 0),
    "2": (120, 204, 12, 24, 48, 96, 252, 0),
    "3": (120, 204, 12, 56, 12, 204, 120, 0),
    "4": (28, 60, 108, 204, 254, 12, 12, 0),
    "5": (252, 192, 248, 12, 12, 204, 120, 0),
    "6": (56, 96, 192, 248, 204, 204, 120, 0),
    "8": (120, 204, 204, 120, 204, 204, 120, 0),
    "9": (120, 204, 204, 124, 12, 24, 112, 0),
}
VARIANTS = {"working", "custom", "wrong", "fixed", "wrap", "nonzero"}


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def png(path: Path) -> tuple[int, int, int, bytearray]:
    data = path.read_bytes()
    require(data[:8] == b"\x89PNG\r\n\x1a\n", "Not PNG")
    at = 8
    packed = bytearray()
    width = height = channels = 0
    while at < len(data):
        size = int.from_bytes(data[at : at + 4], "big")
        tag, payload = data[at + 4 : at + 8], data[at + 8 : at + 8 + size]
        require(
            zlib.crc32(tag + payload) & 0xFFFFFFFF
            == int.from_bytes(data[at + 8 + size : at + 12 + size], "big"),
            "PNG CRC",
        )
        if tag == b"IHDR":
            width, height, bits, colour, compression, filtering, interlace = (
                struct.unpack(">IIBBBBB", payload)
            )
            require(
                bits == 8
                and colour in [2, 6]
                and compression == filtering == interlace == 0,
                "Unsupported PNG encoding",
            )
            channels = 3 if colour == 2 else 4
            require(width * height <= 2_000_000, "Unexpected image size")
        if tag == b"IDAT":
            packed.extend(payload)
        at += size + 12
        if tag == b"IEND":
            break
    require(width > 0 and height > 0 and channels > 0, "Missing PNG header")
    raw = zlib.decompress(packed)
    stride = width * channels
    require(len(raw) == height * (stride + 1), "Truncated PNG pixels")
    output = bytearray(height * stride)
    for y in range(height):
        filtering = raw[y * (stride + 1)]
        require(filtering in range(5), "Unknown PNG filter")
        row = bytearray(raw[y * (stride + 1) + 1 : (y + 1) * (stride + 1)])
        for x in range(stride) if filtering else []:
            left = row[x - channels] if x >= channels else 0
            above = output[(y - 1) * stride + x] if y else 0
            corner = (
                output[(y - 1) * stride + x - channels] if y and x >= channels else 0
            )
            if filtering == 1:
                predictor = left
            elif filtering == 2:
                predictor = above
            elif filtering == 3:
                predictor = (left + above) // 2
            else:
                p = left + above - corner
                dl, da, dc = abs(p - left), abs(p - above), abs(p - corner)
                predictor = (
                    left if dl <= da and dl <= dc else above if da <= dc else corner
                )
            row[x] = (row[x] + predictor) & 255
        output[y * stride : (y + 1) * stride] = row
    return width, height, channels, output


def display_png(path: Path) -> bytes:
    """Remove only proven duplicate columns; preserve every unique colour sample."""
    width, height, channels, pixels = png(path)
    require(width % 2 == 0, "Odd capture width")
    rows = bytearray()
    for y in range(height):
        rows.append(0)
        for x in range(0, width, 2):
            at = (y * width + x) * channels
            a = pixels[at : at + channels]
            require(
                a == pixels[at + channels : at + 2 * channels],
                "Capture columns are not duplicates",
            )
            rows.extend(a)

    def chunk(tag: bytes, payload: bytes) -> bytes:
        return (
            len(payload).to_bytes(4, "big")
            + tag
            + payload
            + (zlib.crc32(tag + payload) & 0xFFFFFFFF).to_bytes(4, "big")
        )

    header = struct.pack(
        ">IIBBBBB", width // 2, height, 8, 6 if channels == 4 else 2, 0, 0, 0
    )
    return (
        b"\x89PNG\r\n\x1a\n"
        + chunk(b"IHDR", header)
        + chunk(b"IDAT", zlib.compress(rows, 9))
        + chunk(b"IEND", b"")
    )


def counter(path: Path, language: str, line: int) -> int:
    width, height, channels, pixels = png(path)
    require((width, height) == (1536, 576), "Different native capture geometry")
    start, y, sx, sy, pitch = (
        (420, 66, 4, 2, 32) if language == "amos" else (288, 40 + 32 * line, 2, 2, 16)
    )
    found = ""
    for column in range(3):
        rows = []
        for j in range(8):
            row = 0
            for i in range(8):
                at = ((y + j * sy) * width + start + column * pitch + i * sx) * channels
                if min(pixels[at : at + 3]) > 180:
                    row |= 1 << (7 - i)
            rows.append(row)
        mask = 0
        for row in rows:
            mask |= row
        if not mask:
            break
        shift = 8 - mask.bit_length()
        glyph = tuple((row << shift) & 255 for row in rows)
        matches = [digit for digit, shape in DIGITS.items() if glyph == shape]
        require(
            len(matches) == 1, f"Unrecognised native counter in {path.name}: {glyph}"
        )
        found += matches[0]
    require(bool(found), f"No native counter in {path.name}")
    return int(found)


def expected(variant: str) -> list[int]:
    score = 254 if variant == "wrap" else 100 if variant == "nonzero" else 0
    step = 3 if variant == "custom" else 255 if variant == "nonzero" else 1
    values = [score]
    for command in ["A", "X", "A"]:
        if variant == "wrong":
            score = 0
        if command == "A":
            score = (score + step) % 256
        values.append(score)
    return values


def check(
    language: str, root: Path = ROOT, record: dict[str, Any] | None = None
) -> None:
    folder = root / f"commodore-amiga/patterns/{language}/framework/command-loop"
    out = folder / "verification"
    if record is None:
        record = json.loads((out / "results.json").read_text())
    require(
        record["language"] == language
        and record["machine_id"] == "commodore-amiga"
        and record["status"] == "framebuffer-checked",
        "Wrong evidence identity",
    )
    require(
        record["configuration"] == "PAL A1200, 2 MiB chip, no fast RAM",
        "Wrong native configuration",
    )
    require(
        record["firmware_sha256"]
        == "6d43840d4099a74170ea0f0425b6257c3891ebcaa39c4d1840075a9ab22b5707",
        "Wrong Kickstart",
    )
    require(
        record["emulator_sha256"]
        == "5c6b7b7775275f0343cdb3f031450787ab718f5049964ab660099422c6268765",
        "Wrong released emulator",
    )
    require(record["release"] == "v0.44.1", "Wrong release")
    runtimes = {
        "amos": (
            "AMOS Professional 2.00",
            {
                "system": "507828d923c0af5e485a03048e396c29c9c5dec7769e8b40b1c933d980ffba3b"
            },
        ),
        "blitz": (
            "Blitz BASIC 2.10 / Ted 1.1",
            {
                "system": "43d12a5bf4401ffc505c77d7d6d329a39403ca00da978cc583ef9fe2bf8cd721",
                "libs": "01f2d948ac14ac88575c04747fc7d4c282c0db84effa6dc2e02796f74e44955f",
            },
        ),
    }
    require(
        (record["runtime"], record["runtime_media_sha256"]) == runtimes[language],
        "Different native language runtime",
    )
    required = {
        str(p.relative_to(root))
        for p in folder.rglob("*")
        if p.is_file() and "verification" not in p.parts and p.name != "README.md"
    }
    required |= {
        "scripts/replay-amiga-command-loops.py",
        "scripts/verify-game-loops.py",
    }
    required |= {str(p.relative_to(root)) for p in (out / "phases").glob("*.json")}
    require(set(record["sources"]) == required, "Incomplete source/phase bindings")
    for name, digest in record["sources"].items():
        require(sha(root / name) == digest, "Changed source: " + name)
    require(set(record["variants"]) == VARIANTS, "Missing native case")
    artifacts = {"toolchain.json"}
    toolchain = json.loads((out / "toolchain.json").read_text())
    for tool in ["emu198x", "build198x-adf"]:
        lock = toolchain[tool]
        require(
            lock["before_lock_sha256"]
            == lock["after_lock_sha256"]
            == lock["committed_lock_sha256"],
            "Changed producer dependency lock",
        )
    require(
        toolchain["emu198x"]["executable_sha256"] == record["emulator_sha256"],
        "Producer binary mismatch",
    )
    require(
        toolchain["source_fixture_sha256"]
        == "7ee707641dc632a001863918ef36ffc1e1b383cd4a215463a138e4e269048f61",
        "Different source fixture",
    )
    for variant, details in record["variants"].items():
        require(
            set(details) == {"captures", "observed", "transport"}, "Incomplete case"
        )
        require(
            len(details["captures"]) == 4 and len(set(details["captures"])) == 4,
            "Missing initial/action captures",
        )
        observed = [
            counter(out / name, language, index)
            for index, name in enumerate(details["captures"])
        ]
        require(
            observed == expected(variant),
            f"Native {language}/{variant}: {observed}, expected {expected(variant)}",
        )
        require(details["observed"] == observed, "Recorded values disagree with pixels")
        artifacts |= set(details["captures"]) | {details["transport"]}
        transport = json.loads((out / details["transport"]).read_text())
        require(len(transport) > 30, "Missing native transport")
        for entry in transport:
            if entry["action"] == "type_string":
                require(
                    entry["result"]["chars_typed"] == len(entry["arguments"]["text"]),
                    "Incomplete input",
                )
            if entry["action"] == "run_frames":
                require(
                    entry["result"]["stop_reason"] == "ReachedTarget"
                    and entry["result"]["frames"] == entry["arguments"]["frames"],
                    "Incomplete execution",
                )
    require(
        set(record["published"]) == {"working", "step-three", "reset-mistake"},
        "Missing publication images",
    )
    prefix = "blitz-" if language == "blitz" else ""
    for name, variant in [
        ("working", "working"),
        ("step-three", "custom"),
        ("reset-mistake", "wrong"),
    ]:
        item = record["published"][name]
        original = prefix + variant + "-2.png"
        require(
            item["capture"] == original
            and item["file"] == "published-" + name + ".png",
            "Wrong publication binding",
        )
        require(
            (out / item["file"]).read_bytes() == display_png(out / original),
            "Published capture loses unique pixels",
        )
        artifacts.add(item["file"])
    require(set(record["artifacts"]) == artifacts, "Incomplete artifact bindings")
    for name, digest in record["artifacts"].items():
        require(
            Path(name).name == name and sha(out / name) == digest,
            "Changed artifact: " + name,
        )


if __name__ == "__main__":
    for language in ["amos", "blitz"]:
        check(language)
        print(language, "native framebuffer evidence PASS")
