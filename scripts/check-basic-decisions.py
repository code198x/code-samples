"""Check retained interpreter observations; no firmware is executed in public CI."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
import zlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


TOPIC = ""
CATEGORIES = {
    "bitset-slot-allocation": "framework",
    "hexadecimal-byte-codec": "framework",
    "input-debounce": "input",
    "grid-turn-buffer": "framework",
}
M = None


def select(topic: str) -> None:
    global TOPIC, M
    require(
        topic
        in (
            "bitset-slot-allocation",
            "hexadecimal-byte-codec",
            "input-debounce",
            "grid-turn-buffer",
        ),
        "Unknown component",
    )
    TOPIC = topic
    M = module(
        "oracle",
        ROOT / f"cross-platform/patterns/{CATEGORIES[topic]}/{topic}/basic_oracle.py",
    )


P = module("png", ROOT / "scripts/check-amiga-command-loops.py")
SYSTEMS = ("commodore-64", "sinclair-zx-spectrum", "bbc-micro")
VARIANTS = ("demo", "custom", "wrong", "repaired")


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require(ok: bool, message: str) -> None:
    if not ok:
        raise AssertionError(message)


def folder(system: str) -> Path:
    return ROOT / system / f"patterns/basic/{CATEGORIES[TOPIC]}/{TOPIC}"


def pixels(record: dict, system: str) -> None:
    w, h, c, p = P.png(folder(system) / "verification" / record["image"])
    result = 0 if record["variant"] == "wrong" else 1
    if system == "bbc-micro":
        require((w, h, c) == (640, 512, 4), "BBC picture geometry")
        require(
            bytes(record["display_prefix"][: len(M.LABEL) + 2])
            == M.LABEL.encode() + str(result).encode() * 2,
            "BBC visible results",
        )
        # Two tiny observed SAA5050 digit masks, not a redistributed firmware image.
        rows = (
            [0, 4, 12, 4, 4, 4, 4, 14, 0, 0]
            if result
            else [0, 4, 10, 17, 17, 17, 10, 4, 0, 0]
        )
        for y in range(20):

            def wide(line: int) -> int:
                return (
                    sum(
                        3 << (dot * 2)
                        for dot in range(6)
                        if rows[line // 2] & (1 << dot)
                    )
                    if 0 <= line < 20
                    else 0
                )

            a = wide(y)
            b = wide(y + 1 if y % 2 else y - 1)
            dots = (a | ((a >> 1) & b & ~(b >> 1)) | ((a << 1) & b & ~(b << 1))) & 4095
            # Integrate each destination pixel over three equal subpixel spans.
            for x in range(16):
                coverage = sum(
                    bool(dots & (1 << (11 - ((3 * x + part) // 4))))
                    for part in range(3)
                )
                level = [0, 156, 213, 255][coverage]
                for column in [len(M.LABEL), len(M.LABEL) + 1]:
                    at = (y * w + column * 16 + x) * c
                    require(
                        tuple(p[at : at + 3]) == (level, level, level),
                        "BBC digit pixels differ",
                    )
    elif system == "commodore-64":
        require((w, h, c) == (416, 312, 4), "C64 picture geometry")
        visible = "".join(
            chr(v + 64) if 1 <= v <= 26 else chr(v)
            for v in record["display_prefix"][40:80]
        )
        require(
            visible.startswith(f"{M.LABEL} {result}  {result}"),
            "C64 visible results",
        )
        background = tuple(p[(59 * w + 48 + 4 * 8) * c : (59 * w + 48 + 4 * 8) * c + 3])
        for y in range(8):
            for x in range(320):
                code = record["display_prefix"][40 + x // 8]
                bits = record["glyphs"][str(code)][y]
                on = bool(bits & (128 >> (x % 8)))
                at = ((59 + y) * w + 48 + x) * c
                require(
                    (tuple(p[at : at + 3]) != background) == on,
                    "C64 glyph pixels differ",
                )
    else:
        require((w, h, c) == (352, 296, 4), "Spectrum picture geometry")
        bitmap = zlib.decompress(bytes.fromhex(record["bitmap_zlib"]))
        require(len(bitmap) == 6144, "Bitmap extent")
        text = M.LABEL + str(result) * 2
        for y in range(8):
            for column, char in enumerate(text):
                require(
                    bitmap[y * 256 + column] == record["glyphs"][str(ord(char))][y],
                    "Spectrum text bitmap",
                )
            for x in range(len(text) * 8):
                on = bool(bitmap[y * 256 + x // 8] & (128 >> (x % 8)))
                at = ((48 + y) * w + 48 + x) * c
                require((max(p[at : at + 3]) > 0) == on, "Spectrum glyph pixels differ")


def check(system: str, variant: str, record: dict | None = None) -> None:
    require(system in SYSTEMS and variant in VARIANTS, "Unknown target")
    f = folder(system)
    r = (
        record
        if record is not None
        else json.loads((f / "verification" / (variant + ".json")).read_text())
    )
    cfg = json.loads((f / "verification/configuration.json").read_text())
    require(
        r["status"] == "passed" and r["system"] == system and r["variant"] == variant,
        "Wrong record identity",
    )
    for key in ["emulator_sha256", "builder_sha256", "firmware_sha256"]:
        require(r[key] == cfg[key], "Changed configuration")
    expected_sources = {
        str(path.relative_to(ROOT))
        for path in [
            *f.glob("*.bas"),
            f / "build.py",
            f / "Makefile",
            ROOT
            / f"cross-platform/patterns/{CATEGORIES[TOPIC]}/{TOPIC}/basic_oracle.py",
            ROOT / "scripts/verify-basic-decisions.py",
            ROOT / "cross-platform/patterns/framework/basic-decision-models/cases.py",
            ROOT / "scripts/verify-basic-deadlines.py",
            ROOT / "scripts/verify-game-loops.py",
        ]
    }
    require(set(r["sources"]) == expected_sources, "Incomplete source inventory")
    require(
        bool(r["sources"])
        and all(sha(ROOT / path) == value for path, value in r["sources"].items()),
        "Changed source",
    )
    require(
        r["source_sha256"] == sha(f / "build" / (variant + ".bas"))
        if (f / "build" / (variant + ".bas")).exists()
        else r["source_sha256"]
        == hashlib.sha256(combined(f, variant).encode()).hexdigest(),
        "Combined source differs",
    )
    require(r["packet"] == M.packet(variant), "State packet differs")
    require(
        r["count"] == len(M.packet(variant))
        and r["guards"] == [165, 239, 90]
        and r["frames_after_start"] > 0,
        "Completion/count/guards differ",
    )
    require(
        r["image"] == variant + ".png"
        and sha(f / "verification" / r["image"]) == r["image_sha256"],
        "Picture hash differs",
    )
    program = r["memory"]["program_bytes"]
    require(bool(program), "Empty loaded program")
    if system == "commodore-64":
        require(
            hashlib.sha256(bytes([1, 8] + program)).hexdigest() == r["program_sha256"],
            "Loaded PRG differs",
        )
    elif system == "bbc-micro":
        require(
            hashlib.sha256(bytes(program)).hexdigest() == r["program_sha256"],
            "Loaded BBC program differs",
        )
        lines = [int(line.split()[0]) for line in combined(f, variant).splitlines()]
        require(
            [line["number"] for line in r["memory"]["lines"]] == lines
            and len(r["source_entry_receipts"]) == len(lines),
            "BBC entered lines differ",
        )
    else:
        # The native observer compares every loaded program byte with the TAP before recording it.
        require(
            r.get("loaded_program_sha256")
            == hashlib.sha256(bytes(program)).hexdigest(),
            "Loaded Spectrum program differs",
        )
    pixels(r, system)


def combined(f: Path, variant: str) -> str:
    lines = (f / (variant + ".bas")).read_text().splitlines() + (
        f / "routines.bas"
    ).read_text().splitlines()
    require(len({int(l.split()[0]) for l in lines}) == len(lines), "Duplicate lines")
    return "\n".join(sorted(lines, key=lambda s: int(s.split()[0]))) + "\n"


def qualify() -> None:
    require(
        len(set(SYSTEMS)) == 3 and len(set(VARIANTS)) == 4, "Target inventory changed"
    )
    rejected = 0
    for system in SYSTEMS:
        f = folder(system)
        for variant in VARIANTS:
            original = json.loads(
                (f / "verification" / (variant + ".json")).read_text()
            )
            check(system, variant)
            for fault in [
                "identity",
                "source",
                "configuration",
                "packet",
                "completion",
                "count",
                "program",
                "image",
                "pixels",
            ]:
                r = copy.deepcopy(original)
                if fault == "identity":
                    r["system"] = "unknown"
                elif fault == "source":
                    r["sources"][next(iter(r["sources"]))] = "0" * 64
                elif fault == "configuration":
                    r["builder_sha256"] = "0" * 64
                elif fault == "packet":
                    r["packet"][22] ^= 1
                elif fault == "completion":
                    r["guards"][1] = 0
                elif fault == "count":
                    r["count"] = 0
                elif fault == "program":
                    r["memory"]["program_bytes"][8] ^= 1
                elif fault == "image":
                    r["image_sha256"] = "0" * 64
                else:
                    if system == "sinclair-zx-spectrum":
                        bitmap = bytearray(
                            zlib.decompress(bytes.fromhex(r["bitmap_zlib"]))
                        )
                        bitmap[0] ^= 1
                        r["bitmap_zlib"] = zlib.compress(bitmap).hex()
                    else:
                        r["display_prefix"] = [0] * 128
                try:
                    check(system, variant, r)
                except (AssertionError, KeyError, ValueError):
                    rejected += 1
                else:
                    raise AssertionError(f"Accepted {system}/{variant}/{fault}")
        demo = json.loads((f / "verification/demo.json").read_text())
        repair = json.loads((f / "verification/repaired.json").read_text())
        require(
            demo["memory"]["program_bytes"] == repair["memory"]["program_bytes"]
            and combined(f, "demo") == combined(f, "repaired"),
            "Repair differs",
        )
        wrong = json.loads((f / "verification/wrong.json").read_text())
        coupled = copy.deepcopy(demo)
        coupled["image"] = wrong["image"]
        coupled["image_sha256"] = wrong["image_sha256"]
        # Use the normal filename with wrong bytes in the pixel observer, so filename checks cannot be the only rejection.
        try:
            pixels(coupled, system)
        except (AssertionError, KeyError, ValueError):
            rejected += 1
        else:
            raise AssertionError("Accepted coupled wrong capture")
    require(rejected == 111, "Negative controls did not all run")
    print(f"{TOPIC}: 12 interpreter variants and 111 altered-evidence controls passed.")


if __name__ == "__main__":
    import sys

    select(sys.argv[1])
    qualify()
