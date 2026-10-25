"""Check complete stock-loader observations and independently rendered indicators."""

from __future__ import annotations

import copy
import hashlib
import importlib.util
import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(str(path))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


V = module("additional_native", ROOT / "scripts/verify-additional-object-pools.py")
P = module("pool_png", ROOT / "scripts/check-amiga-command-loops.py")


def require(condition: bool, message: str) -> None:
    if not condition:
        raise AssertionError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def search(rows: list[bytes], pattern: list[bytes]) -> list[tuple[int, int]]:
    hits = []
    width = len(pattern[0])
    height = len(pattern)
    for y in range(len(rows) - height + 1):
        x = rows[y].find(pattern[0])
        while x >= 0:
            if x + width <= len(rows[y]) and all(
                rows[y + j][x : x + width] == line for j, line in enumerate(pattern)
            ):
                hits.append((x, y))
            x = rows[y].find(pattern[0], x + 1)
    return hits


def pixels(system: str, r: dict, image_root: Path | None = None) -> None:
    w, h, c, p = P.png((image_root or V.folder(system) / "verification") / r["image"])
    checks = V.O.checks(r["variant"])
    require(c == 4, "Expected opaque RGBA capture")
    if system == "bbc-micro":
        require((w, h) == (640, 512), "BBC geometry")
        require(
            bytes(r["capture"]["display_prefix"][:6])
            == b"POOL" + "".join(map(str, checks)).encode(),
            "BBC display prefix",
        )
        for col, result in enumerate(checks, 4):
            masks = (
                [0, 4, 12, 4, 4, 4, 4, 14, 0, 0]
                if result
                else [0, 4, 10, 17, 17, 17, 10, 4, 0, 0]
            )

            def wide(line: int, glyph: tuple[int, ...] = tuple(masks)) -> int:
                return (
                    sum(
                        3 << (dot * 2)
                        for dot in range(6)
                        if glyph[line // 2] & (1 << dot)
                    )
                    if 0 <= line < 20
                    else 0
                )

            for y in range(20):
                a, b = wide(y), wide(y + 1 if y % 2 else y - 1)
                dots = (
                    a | ((a >> 1) & b & ~(b >> 1)) | ((a << 1) & b & ~(b << 1))
                ) & 4095
                for x in range(16):
                    coverage = sum(
                        bool(dots & (1 << (11 - ((3 * x + part) // 4))))
                        for part in range(3)
                    )
                    level = [0, 156, 213, 255][coverage]
                    at = (y * w + col * 16 + x) * c
                    require(
                        tuple(p[at : at + 3]) == (level, level, level),
                        "BBC result digit pixels",
                    )
    elif system == "atari-800xl":
        require((w, h) == (376, 240), "Atari geometry")
        cap = r["capture"]
        text = "POOL" + "".join(map(str, checks)) + "  "
        codes = [ord(ch) - 32 for ch in text]
        offset = cap["offset"]
        require(
            cap["text"] == text and cap["codes"] == codes and cap["font_base"] == 57344,
            "Atari text/font binding",
        )
        require(
            0 <= offset < 960
            and offset % 40 <= 32
            and cap["screen_bytes"][offset : offset + 8] == codes,
            "Atari actual screen position",
        )
        x0 = 28 + offset % 40 * 8
        y0 = 24 + offset // 40 * 8
        at = ((y0) * w + x0 + 6 * 8) * c
        paper = tuple(p[at : at + 3])
        require(
            set(cap["glyphs"]) == {str(code) for code in codes}, "Atari glyph inventory"
        )
        for y in range(8):
            for x in range(64):
                bits = cap["glyphs"][str(codes[x // 8])]
                require(len(bits) == 8, "Atari glyph extent")
                wanted = bool(bits[y] & (128 >> (x % 8)))
                at = ((y0 + y) * w + x0 + x) * c
                require(
                    (tuple(p[at : at + 3]) != paper) == wanted and p[at + 3] == 255,
                    "Atari ROM glyph pixels",
                )
    else:
        if system == "amstrad-cpc":
            require((w, h) == (832, 288), "CPC geometry")
            glyphs = [
                [60, 66, 70, 74, 82, 98, 66, 60],
                [24, 56, 24, 24, 24, 24, 24, 126],
            ]
            pattern = [
                bytes(
                    int(bool(glyphs[result][y] & (128 >> x)))
                    for result in checks
                    for x in range(8)
                    for _ in range(2)
                )
                for y in range(8)
            ]
            rows = [
                bytes(
                    int(
                        p[(y * w + x) * c] > 220
                        and p[(y * w + x) * c + 1] > 220
                        and p[(y * w + x) * c + 2] > 220
                    )
                    for x in range(w)
                )
                for y in range(h)
            ]
        else:
            require((w, h) == (744, 312), "Dragon diagnostic geometry")
            pattern = []
            for y in range(4):
                bits = (
                    [int((x + y) % 2 == checks[0]) for x in range(4)]
                    + [0] * 4
                    + [int((x + y) % 2 == checks[1]) for x in range(4)]
                )
                line = bytes(bit for bit in bits for _ in range(8))
                pattern += [line] * 6
            rows = [
                bytes(
                    int(
                        p[(y * w + x) * c + 1] > 70
                        and p[(y * w + x) * c + 1] > p[(y * w + x) * c] + 40
                        and p[(y * w + x) * c + 1] > p[(y * w + x) * c + 2] + 40
                    )
                    for x in range(w)
                )
                for y in range(h)
            ]
        require(
            len(search(rows, pattern)) == 1,
            system + " caller-owned indicator pixels do not uniquely match",
        )


def check(system: str, r: dict, cfg: dict) -> None:
    variant = r["variant"]
    c = V.CONFIG[system]
    f = V.folder(system)
    require(
        r["capacity"]
        == (
            1
            if variant == "boundary-one"
            else 255
            if variant == "boundary-max"
            else 4
            if variant == "custom"
            else 8
        ),
        "Wrong capacity",
    )
    require(
        r["machine"] == system
        and r["language"] == "assembly"
        and variant in V.B.VARIANTS,
        "Wrong machine/language/variant",
    )
    require(
        r["sources"] == {str(p.relative_to(ROOT)): sha(p) for p in V.sources(system)},
        "Stale source/observer",
    )
    require(
        all(
            r[k] == cfg[k]
            for k in ["emulator_sha256", "assembler_sha256", "firmware_sha256"]
        ),
        "Changed native producer",
    )
    require(r["server"]["version"] == "0.44.2", "Wrong actual emulator version")
    require(
        r["program_sha256"] == r["loaded_sha256"] == cfg["programs"][variant]
        and hashlib.sha256(bytes(r["loaded_program"])).hexdigest()
        == r["loaded_sha256"],
        "Loaded image differs",
    )
    require(
        r["origin"] == c["origin"]
        and 0 < len(r["loaded_program"]) < c["limit"] - c["origin"],
        "Image does not fit allocation",
    )
    expected = V.O.packet(variant)
    require(
        c["output"] + len(expected) <= c["packet_limit"], "Packet allocation overflow"
    )
    require(
        r["packet"] == expected
        and len(expected) > 0
        and expected[0] == 165
        and expected[-1] == 239,
        "Wrong full native state packet",
    )
    require(
        int.from_bytes(
            bytes(r["end_pointer"]), "big" if c["cpu"] == "6809" else "little"
        )
        == c["output"] + len(expected),
        "Wrong emitted count",
    )
    require(
        r["ready"] == [239]
        and r["checks"] == V.O.checks(variant)
        and r["frames_after_positive_completion"] == 2
        and r["observer_frames"] > 0,
        "Missing completion/checks/scan",
    )
    require(
        r["arithmetic"] == ([42, 0] if system == "atari-800xl" else [42]),
        "Broken BASIC return",
    )
    require(
        len(r["transcript"]) > 10
        and all(t["chars_typed"] == len(t["text"]) + 1 for t in r["transcript"]),
        "Incomplete input transcript",
    )
    require(
        sha(f / "verification" / r["image"]) == r["image_sha256"], "Changed capture"
    )
    pixels(system, r)


def qualify(system: str) -> None:
    f = V.folder(system) / "verification"
    cfg = json.loads((f / "configuration.json").read_text())
    records = {v: json.loads((f / (v + ".json")).read_text()) for v in V.B.VARIANTS}
    for r in records.values():
        check(system, r, cfg)
    require(
        records["demo"]["program_sha256"] == records["repaired"]["program_sha256"],
        "Repair is not exact",
    )
    require(
        (V.folder(system) / "demo.asm").read_bytes()
        == (V.folder(system) / "repaired.asm").read_bytes(),
        "Repair source differs",
    )
    rejected = 0
    for variant, record in records.items():
        mutations = [
            ("packet", []),
            ("ready", [0]),
            ("end_pointer", [0, 0]),
            ("checks", [9, 9]),
            ("arithmetic", [0]),
            ("frames_after_positive_completion", 0),
            ("loaded_program", []),
            ("loaded_sha256", "0" * 64),
            ("program_sha256", "0" * 64),
            ("emulator_sha256", "0" * 64),
            ("assembler_sha256", "0" * 64),
            ("firmware_sha256", {}),
            ("sources", {}),
            ("transcript", []),
            ("observer_frames", 0),
            ("machine", "other"),
        ]
        altered = list(record["packet"])
        altered[len(altered) // 2] ^= 1
        mutations.append(("packet", altered))
        for key, value in mutations:
            bad = copy.deepcopy(record)
            bad[key] = value
            try:
                check(system, bad, cfg)
            except (AssertionError, KeyError, ValueError, IndexError):
                rejected += 1
            else:
                raise AssertionError("Accepted altered " + variant + "/" + key)
        if variant != "wrong":
            bad = copy.deepcopy(record)
            bad["image"] = records["wrong"]["image"]
            bad["image_sha256"] = records["wrong"]["image_sha256"]
            try:
                check(system, bad, cfg)
            except (AssertionError, KeyError, ValueError, IndexError):
                rejected += 1
            else:
                raise AssertionError("Accepted coupled wrong capture")
    require(rejected == 107, "Negative controls did not all execute")
    print(system, "6 native cases and", rejected, "altered-evidence controls passed")


if __name__ == "__main__":
    import sys

    qualify(sys.argv[1])
