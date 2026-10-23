"""Check stock-memory Ace deadlines, completed loader steps and their regression."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load(name: str, file: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / "scripts" / file)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value


C = load("generic", "check-dragon-assembly-deadlines.py")
V = C.load("jupiter-ace")
T = V.T


def check(record: dict | None = None, regression: dict | None = None) -> None:
    folder = V.F / "verification"
    r = (
        record
        if record is not None
        else json.loads((folder / "results.json").read_text())
    )
    C.check("jupiter-ace", r)
    for variant, case in r["cases"].items():
        T.require(case["ram_top"] == 16384, "Stock RAM not qualified")
        length = len(case["loaded_bytes"])
        steps = case["loader_steps"]
        expected = [0] + list(range(8, length, 8)) + [length]
        T.require(
            [s["compiled_bytes"] for s in steps] == expected,
            "Missing loader completion step",
        )
        for step in steps:
            T.require(
                step["here"] == 15616 + step["compiled_bytes"]
                and step["spare"] == step["here"] + 12
                and 0 <= step["waited_frames"] <= 200,
                "Loader dictionary/stack not ready",
            )
        if "boundar" in variant:
            continue
        for sample in case["samples"]:
            w = sample["workspace"]
            here = int.from_bytes(bytes(w[:2]), "little")
            spare = int.from_bytes(bytes(w[4:6]), "little")
            sp = int(sample["cpu"]["sp"].lstrip("$"), 16)
            T.require(
                here == 15616 + length and spare == here + 12 and spare < sp < 16384,
                "Dictionary or return-stack collision",
            )
        cap = case["capture"]
        video = bytes.fromhex(cap["video_hex"])
        T.require(
            len(video) == 768
            and video[:8]
            == ("01 00 01" if variant == "wrong" else "03 01 01").encode(),
            "Wrong visible status",
        )
        P = load("png", "check-amiga-command-loops.py")
        width, height, channels, pixels = P.png(folder / case["image"])
        T.require((width, height, channels) == (320, 288, 4), "Wrong native geometry")
        for y in range(192):
            for x in range(256):
                code = video[y // 8 * 32 + x // 8]
                bits = cap["glyphs"][str(code & 127)][y % 8]
                expected = bool(bits & (128 >> (x % 8))) ^ bool(code & 128)
                pos = ((y + 48) * width + x + 32) * channels
                actual = min(pixels[pos : pos + 3]) > 180 and pixels[pos + 3] == 255
                T.require(
                    actual == expected, "Native pixels differ from retained screen/font"
                )
        w = case["exit_workspace"]
        T.require(
            int.from_bytes(bytes(w[4:6]), "little")
            == int.from_bytes(bytes(w[:2]), "little") + 12,
            "Exit leaked data stack",
        )
    g = (
        regression
        if regression is not None
        else json.loads((folder / "loader-regression.json").read_text())
    )
    T.require(
        g["sources"]
        == {
            str(p.relative_to(ROOT)): T.sha(p)
            for p in (
                ROOT / "scripts/verify-ace-loader.py",
                ROOT / "scripts/verify-game-loops.py",
            )
        },
        "Regression source changed",
    )
    expected = [245, 197, 213, 229, 175, 50, 81, 62]
    T.require(
        g["early"] != expected
        and g["completed"] == expected
        and g["injection"]["chars_typed"] == 53
        and 0 < g["waited_frames"] <= 200,
        "Early-read control did not fail and recover",
    )
    w = g["completed_pointers"]
    T.require(
        int.from_bytes(bytes(w[:2]), "little") == 15624
        and int.from_bytes(bytes(w[4:6]), "little") == 15636,
        "Regression did not finish dictionary/stack work",
    )
    T.require(
        g["executable_sha256"] == r["emulator_sha256"]
        and g["firmware_sha256"] == r["firmware_sha256"]["ace.rom"]
        and g["server"]["version"] == "0.44.2",
        "Regression tool/firmware differs",
    )


if __name__ == "__main__":
    check()
    print(
        "Ace deadlines, stock memory, line completion and early-read regression passed"
    )
