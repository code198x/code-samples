"""Check retained stock-ROM state, compiled dictionary, stack and pixel proof."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import re
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "ace_flow_native", ROOT / "scripts/verify-ace-game-flow.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T, C = V.T, V.C
P = V.module("ace_flow_png", ROOT / "scripts/check-amiga-command-loops.py")
WAIT_CASES = {0, 1, 18, 20, 40, 64, 315, 320, 365}


def stack(s: dict[str, int], here: int, waiting: bool = False) -> None:
    T.require(
        s["dictionary"] == here
        and here + 14 <= s["data_top"] <= here + (16 if waiting else 14),
        "Wrong dictionary or data-stack extent",
    )
    T.require(
        s["data_top"] < s["cpu_sp"] <= 16384
        and s["separation"] == s["cpu_sp"] - s["data_top"],
        "Native stack collision or false separation",
    )


def identity(c: dict[str, Any], files: list[str], names: tuple[str, ...]) -> None:
    here, before = c["here"], c["here_before"]
    sizes = c["here_after_files"]
    T.require(
        c["ram_top"] == 16384
        and before == 15460
        and list(sizes) == files
        and sizes[files[-1]] == here,
        "Wrong stock allocation or entered file order",
    )
    T.require(sizes["routines.fth"] - before == 492, "Helper dictionary cost differs")
    entered = hashlib.sha256(
        "".join((V.F / f).read_text() for f in files).encode("ascii")
    ).hexdigest()
    T.require(c["entered_source_sha256"] == entered, "Wrong entered source identity")
    addresses = c["addresses"]
    T.require(
        set(addresses) == set(names) and len(set(addresses.values())) == len(names),
        "Missing or aliased native storage",
    )
    # These are observed two-character VARIABLE layouts in this exact stock ROM.
    expected = {n: before + 9 + 11 * i for i, n in enumerate(V.NAMES)}
    extra_start = sizes[files[0]] if files[1] == "boundaries.fth" else sizes[files[1]]
    expected.update({n: extra_start + 9 + 11 * i for i, n in enumerate(names[6:])})
    T.require(addresses == expected, "Variable addresses differ from compiled layout")
    initial = bytes.fromhex(c["dictionary_before_hex"])
    program = c["program_identity"]
    final = bytes.fromhex(program["after_hex"])
    T.require(
        program["start"] == before
        and program["bytes"] == len(initial) == len(final) == here - before > 0,
        "Incomplete compiled dictionary image",
    )
    T.require(
        hashlib.sha256(initial).hexdigest() == program["before_sha256"]
        and hashlib.sha256(final).hexdigest() == program["after_sha256"],
        "Compiled dictionary hash differs",
    )
    a, b = bytearray(initial), bytearray(final)
    for address in addresses.values():
        T.require(before <= address < here - 1, "Variable outside native program")
        a[address - before : address - before + 2] = b"\x00\x00"
        b[address - before : address - before + 2] = b"\x00\x00"
    T.require(
        a == b and hashlib.sha256(a).hexdigest() == program["immutable_sha256"],
        "Compiled code or headers changed outside owned cells",
    )
    initial_values = {n: 0 for n in names}
    if "GH" in names:
        variant = (
            "wrong"
            if "mistakes/reset-on-resume.fth" in files
            else "custom"
            if "customise.fth" in files
            else "working"
        )
        initial_values["GH"] = 5 if variant == "custom" else 3
        final_values = C.owner_rows(variant)[-1]
    else:
        final_values = dict(
            zip(V.NAMES + ("OA", "OB", "OC"), C.expected(*C.cases()[-1]), strict=True)
        )
        final_values.update(OD=366, OE=0)
    for name, address in addresses.items():
        offset = address - before
        T.require(
            int.from_bytes(initial[offset : offset + 2], "little")
            == initial_values[name]
            and int.from_bytes(final[offset : offset + 2], "little")
            == final_values[name],
            "Compiled owned-cell bytes differ from initial/final state",
        )
    T.require(
        c["server"] == {"name": "emu198x-jupiter-ace", "version": "0.44.1"},
        "Wrong native producer",
    )


def capture(
    c: dict[str, Any], filename: str, values: tuple[str, int, str, int]
) -> None:
    T.require(
        c["image"] == filename and T.sha(V.V / filename) == c["image_sha256"],
        "Changed native capture identity",
    )
    native = c["pixels"]
    raw = bytes.fromhex(native["video_hex"])
    T.require(
        len(raw) == 768 and native["pixel_match"] is True, "Incomplete native screen"
    )
    text = "".join(chr(x & 127) if 32 <= x & 127 < 127 else " " for x in raw)
    label_a, a, label_b, b = values
    T.require(
        re.match(rf"\s*{label_a}\s+{a}\s+{label_b}\s+{b}\s", text, re.IGNORECASE)
        is not None
        and "ERROR" not in text.upper(),
        "Native display differs from context",
    )
    width, height, channels, pixels = P.png(V.V / filename)
    T.require((width, height, channels) == (320, 288, 4), "Wrong native capture extent")
    glyphs = native["glyphs"]
    T.require(
        set(glyphs) == {str(x & 127) for x in raw}
        and all(len(g) == 8 and all(0 <= b <= 255 for b in g) for g in glyphs.values()),
        "Incomplete native character RAM",
    )
    for y in range(192):
        for x in range(256):
            code = raw[y // 8 * 32 + x // 8]
            bit = bool(glyphs[str(code & 127)][y % 8] & (128 >> (x % 8))) ^ bool(
                code & 128
            )
            offset = ((y + 48) * width + x + 32) * channels
            # Exact active-pixel RGBA of the locked 0.44.1 producer, checked in all nine captures.
            wanted = bytes((207, 207, 207, 255)) if bit else bytes((0, 0, 0, 255))
            T.require(
                bytes(pixels[offset : offset + 4]) == wanted,
                "Native framebuffer differs from screen and glyph RAM",
            )


def check(record: dict[str, Any] | None = None) -> None:
    r = record if record is not None else json.loads((V.V / "native.json").read_text())
    T.require(
        (r["system"], r["language"]) == ("jupiter-ace", "forth")
        and r["configuration"] == V.config(),
        "Wrong stock runtime identity",
    )
    T.require(r["sources"] == V.sources(), "Changed source or observer identity")
    T.require(
        len(C.cases()) == len(set(C.cases())) == 366,
        "Empty or incomplete independent model",
    )
    T.require(
        set(r["cases"]) == {"table", "working", "custom", "wrong", "repaired"},
        "Missing native state or owner boot",
    )
    table = r["cases"]["table"]
    identity(
        table,
        ["routines.fth", "boundaries.fth"],
        V.NAMES + ("OA", "OB", "OC", "OD", "OE"),
    )
    T.require(len(table["rows"]) == 366, "Incomplete state traversal")
    waits = set()
    for i, (inputs, row) in enumerate(zip(C.cases(), table["rows"], strict=True)):
        word = "GICASE" if inputs[2] else "GCASE"
        T.require(
            row["inputs"] == list(inputs)
            and row["command"] == f"77 {inputs[0]} {inputs[1]} {word}",
            "Swapped or different native input",
        )
        T.require(
            row["values"] == C.expected(*inputs)
            and row["completed"] == i + 1
            and row["tag"] == 77,
            "Native state/payload/completion/prefix differs",
        )
        stack(row["after_return"], table["here"])
        if "while_waiting" in row:
            waits.add(i)
            stack(row["while_waiting"], table["here"], waiting=True)
    T.require(waits == WAIT_CASES, "Missing observed running-stack cases")
    for name in ("working", "custom", "wrong", "repaired"):
        c = r["cases"][name]
        files = [
            "routines.fth",
            "mistakes/reset-on-resume.fth" if name == "wrong" else "reset.fth",
            "caller.fth",
            "customise.fth" if name == "custom" else "settings.fth",
        ]
        identity(c, files, V.NAMES + ("GP", "GV", "GH", "GL", "GR"))
        T.require(
            len(c["rows"]) == 15
            and c["outputs"] == V.owner_expected(name)
            and c["tag"] == 77,
            "Owner trace/resume/customisation differs",
        )
        for i, (expected, row) in enumerate(
            zip(C.owner_rows(name), c["rows"], strict=True)
        ):
            T.require(
                row["frame"] == i
                and row["held"] == V.TRACE[i]
                and row["state"] == expected,
                "Full owner context or history differs",
            )
            stack(row["stack"], c["here"])
    working, repaired = r["cases"]["working"], r["cases"]["repaired"]
    T.require(
        working["dictionary_before_hex"] == repaired["dictionary_before_hex"]
        and working["entered_source_sha256"] == repaired["entered_source_sha256"]
        and working["program_identity"]["immutable_sha256"]
        == r["cases"]["custom"]["program_identity"]["immutable_sha256"],
        "Repair or data-only customisation changed compiled code",
    )
    # Expensive complete pixel comparisons follow structural/identity checks.
    capture(table["capture"], "table.png", ("CASE", 366, "STATE", 0))
    for name in ("working", "custom", "wrong", "repaired"):
        c = r["cases"][name]
        capture(
            c["resumed_capture"],
            name + "-resumed.png",
            ("STATE", 1, "SCORE", 0 if name == "wrong" else 4),
        )
        capture(c["final_capture"], name + "-final.png", ("STATE", 1, "SCORE", 2))


if __name__ == "__main__":
    check()
    print(
        "Ace game flow: 366 full native cases, four owners, compiled dictionary identity, stack bounds and pixels passed"
    )
