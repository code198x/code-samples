"""Validate native gameplay packets, immutable code, pictures and repair evidence."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name, file):
    s = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


V = module("native", "verify-worldkit.py")
P = module("png", "check-amiga-command-loops.py")
T = V.T


def pixels(c, system):
    f = V.folder(system)
    w, h, ch, p = P.png(f / "verification" / c["image"])
    text = " ".join(f"{v:02X}" for v in c["preview"]) + " "
    if system == "sinclair-zx-spectrum":
        bits = zlib.decompress(bytes.fromhex(c["bitmap_zlib"]))
        T.require(
            all(str(ord(char)) in c["glyphs"] for char in set(text)),
            "Claimed text contains an uncaptured glyph",
        )
        wanted = bytearray(6144)
        for y in range(8):
            for x, char in enumerate(text):
                wanted[y * 256 + x] = c["glyphs"][str(ord(char))][y]
        T.require(
            bits == wanted and c["attributes"] == [71] * 768 and c["text"] == text,
            "Bitmap/text differs",
        )
        T.require((w, h, ch) == (352, 296, 4), "Wrong geometry")
        for y in range(192):
            for x in range(256):
                a = ((y & 192) << 5) | ((y & 7) << 8) | ((y & 56) << 2) | (x >> 3)
                on = bool(bits[a] & (128 >> (x & 7)))
                i = ((48 + y) * w + 48 + x) * ch
                T.require(
                    tuple(p[i : i + 3]) == ((255, 255, 255) if on else (0, 0, 0)),
                    "PNG differs",
                )
    elif system == "commodore-amiga":
        T.require((w, h, ch) == (768, 576, 4), "Wrong geometry")
        plane = zlib.decompress(bytes.fromhex(c["plane_zlib"]))
        wanted = bytearray(10240)
        font = V.font()
        for y in range(8):
            for col, char in enumerate(text):
                wanted[(49 + y) * 40 + 2 + col] = font[
                    (0 if char == " " else int(char, 16) + 1) * 8 + y
                ]
        T.require(plane == wanted, "Bitplane/text differs")
        for y in range(256):
            for x in range(320):
                on = bool(plane[y * 40 + x // 8] & (128 >> (x % 8)))
                for dy in (0, 1):
                    for dx in (0, 1):
                        i = ((38 + 2 * y + dy) * w + 82 + 2 * x + dx) * ch
                        T.require(
                            tuple(p[i : i + 3])
                            == ((255, 255, 255) if on else (0, 17, 34)),
                            "PNG differs",
                        )
    else:
        nes = system == "nintendo-entertainment-system"
        T.require(
            (w, h, ch) == ((256, 240, 4) if nes else (416, 312, 4)), "Wrong geometry"
        )
        font = V.font()
        ox, oy = (16, 8) if nes else (48, 51)
        if not nes:
            screen = [0] * 1000
            for i, char in enumerate(text):
                screen[i] = 0 if char == " " else int(char, 16) + 1
            T.require(c["screen"] == screen, "Names differ")
        for y in range(8):
            for x in range(len(text) * 8):
                char = text[x // 8]
                tile = 0 if char == " " else int(char, 16) + 1
                on = bool(font[tile * 8 + y] & (128 >> (x % 8)))
                i = ((oy + y) * w + ox + x) * ch
                T.require(
                    (tuple(p[i : i + 3]) != (0, 0, 0)) == on and p[i + 3] == 255,
                    "PNG differs",
                )


def check(topic, system, record=None):
    V.TOPIC = topic
    T.require(system in V.SYSTEMS, "Unknown system")
    f = V.folder(system)
    v = f / "verification"
    r = record if record is not None else json.loads((v / "results.json").read_text())
    cfg = json.loads((v / "configuration.json").read_text())
    T.require(
        r["topic"] == topic
        and r["system"] == system
        and r["language"] == "assembly"
        and r["configuration"] == cfg,
        "Changed configuration",
    )
    T.require(
        r["sources"]
        == {str(p.relative_to(ROOT)): T.sha(p) for p in V.source_paths(system)},
        "Changed source",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing completed case")
    for name, c in r["cases"].items():
        T.require(c["server"]["version"] == "0.44.2", "Wrong producer")
        T.require(
            c["packet"] == V.expected_packet(name)
            and c["ready"] == ([186, 190] if system == "commodore-amiga" else [165]),
            "Native ownership/transition packet differs",
        )
        wanted = V.expected_preview(name)
        T.require(c["preview"] == wanted, "Preview differs")
        T.require(
            c["state_bytes"] == len(V.oracle().FIELDS)
            and c["static_data_bytes"] == 0
            and c["helper_code_bytes"] > 0
            and len(c["helper_bytes"]) == c["helper_code_bytes"],
            "Costs differ",
        )
        binary = zlib.decompress(bytes.fromhex(c["program_zlib"]))
        T.require(
            len(binary) == c["program_bytes"]
            and hashlib.sha256(binary).hexdigest() == c["program_sha256"],
            "Program differs",
        )
        loaded = bytes(c["loaded_bytes"])
        T.require(
            hashlib.sha256(loaded).hexdigest() == c["loaded_sha256"],
            "Loaded image differs",
        )
        if system == "commodore-64":
            T.require(
                binary[:2] == b"\x01\x08" and loaded == binary[2:], "Stock PRG differs"
            )
        elif system == "nintendo-entertainment-system":
            T.require(
                binary[:4] == b"NES\x1a"
                and len(binary) == 40976
                and loaded == binary[16:32784],
                "NROM differs",
            )
            full = [v for i in range(17) for v in V.font()[i * 8 : i * 8 + 8] + [0] * 8]
            T.require(
                binary[32784:] == bytes(full) + bytes(8192 - len(full)), "CHR differs"
            )
            T.require(
                cfg["firmware_sha256"] == {},
                "Cartridge caller must not claim unrelated firmware",
            )
        elif system == "sinclair-zx-spectrum":
            T.require(
                0 < len(c["startup"]) <= 20 and c["startup"][-1]["reached"],
                "ROM startup incomplete",
            )
            T.require(loaded == V.blocks(binary)[3][1:-1], "ROM-loaded CODE differs")
        else:
            exe = zlib.decompress(bytes.fromhex(c["exe_zlib"]))
            body, relocs = V.H.hunk(exe)
            changed = bytearray(body)
            for i in relocs:
                changed[i : i + 4] = (
                    int.from_bytes(body[i : i + 4], "big") + c["base"]
                ).to_bytes(4, "big")
            T.require(
                c["code_end"] > 0 and loaded == changed[: c["code_end"]],
                "Relocated code differs",
            )
        off = c["helper_offset"]
        T.require(
            off >= 0
            and loaded[off : off + c["helper_code_bytes"]] == bytes(c["helper_bytes"]),
            "Native helper extent differs",
        )
        T.require(T.sha(v / c["image"]) == c["image_sha256"], "Changed capture")
        pixels(c, system)
    if system == "sinclair-zx-spectrum":
        repaired_equal = (
            r["cases"]["demo"]["loaded_bytes"] == r["cases"]["repaired"]["loaded_bytes"]
        )
    elif system == "commodore-amiga":
        repaired_equal = (
            r["cases"]["demo"]["exe_zlib"] == r["cases"]["repaired"]["exe_zlib"]
        )
    else:
        repaired_equal = (
            r["cases"]["demo"]["program_sha256"]
            == r["cases"]["repaired"]["program_sha256"]
        )
    T.require(repaired_equal, "Executable repair differs")


def targets():
    rows = json.loads((V.ROOT / "scripts/worldkit-targets.json").read_text())
    T.require(
        rows and len({tuple(x) for x in rows}) == len(rows),
        "Empty/duplicate target inventory",
    )
    for topic, system in rows:
        T.require(
            topic in V.TOPICS and system in V.SYSTEMS,
            "Unknown target",
        )
    for topic in {row[0] for row in rows}:
        T.require(
            {system for t, system in rows if t == topic} == set(V.SYSTEMS),
            "Incomplete four-core topic",
        )
    return rows


if __name__ == "__main__":
    for topic, system in targets():
        check(topic, system)
        print(topic, system, "native packets, code, pixels and failure evidence passed")
