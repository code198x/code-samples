"""Recompute retained Sinclair program, heap and stack measurements."""

from __future__ import annotations

import argparse
import importlib.util
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "compact", ROOT / "scripts/verify-zx-compact-map.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
M = C.M


def require(value: object, message: str) -> None:
    if not value:
        raise AssertionError(message)


def same_number(actual: float, expected: float) -> bool:
    # Integer arguments must agree exactly. Decimal INPUT uses the ROM's
    # five-byte float conversion, so allow its last-bit error for fractions.
    return (
        actual == expected
        if expected == int(expected)
        else math.isclose(actual, expected, rel_tol=2**-30, abs_tol=2**-31)
    )


def stored(raw_hex: str, system: str) -> list:
    raw = bytes.fromhex(raw_hex)
    require(raw, "Empty program")
    lines = []
    pos = 0
    while pos < len(raw):
        n = int.from_bytes(raw[pos : pos + 2], "big")
        size = (
            raw.index(118, pos + 2) - pos + 1
            if system.endswith("80")
            else 4 + int.from_bytes(raw[pos + 2 : pos + 4], "little")
        )
        require(size > 2 and pos + size <= len(raw), "Program boundary")
        lines.append({"number": n, "bytes": size})
        pos += size
    require(
        [x["number"] for x in lines] == sorted({x["number"] for x in lines}),
        "Line order",
    )
    return lines


def snapshot(s: dict, system: str, ram: int) -> None:
    raw = list(bytes.fromhex(s["system_hex"]))
    require(len(raw) == (40 if system.endswith("80") else 125), "System area length")
    offsets = (
        {"vars": 8, "e_line": 10, "d_file": 12, "df_ea": 14, "df_end": 16}
        if system.endswith("80")
        else {
            "ramtop": 4,
            "d_file": 12,
            "vars": 16,
            "e_line": 20,
            "stkbot": 26,
            "stkend": 28,
        }
    )
    pointers = {n: M.word(raw, i) for n, i in offsets.items()}
    require(pointers == s["pointers"], "Pointer decode")
    frontier = pointers["df_end" if system.endswith("80") else "stkend"]
    sp = int(s["cpu"]["sp"].lstrip("$"), 16)
    require(
        s["ram_bytes"] == ram and 16384 <= frontier <= sp <= 16384 + ram,
        "RAM/stack bounds",
    )
    require(
        (frontier, sp, sp - frontier) == (s["frontier"], s["sp"], s["observed_gap"]),
        "Gap accounting",
    )


def screen(s: dict, system: str) -> str:
    chars = {
        0: " ",
        26: ",",
        27: ".",
        118: "\n",
        **{28 + i: str(i) for i in range(10)},
        **{38 + i: chr(65 + i) for i in range(26)},
    }
    chars[18 if system.endswith("80") else 22] = "-"
    chars[21 if system.endswith("80") else 24] = "/"
    text = "".join(chars.get(b, "?") for b in bytes.fromhex(s["hex"]))
    require(text == s["text"] and text.strip(), "Screen decode")
    return text


def heap(h: dict) -> dict:
    v = C.variables(list(bytes.fromhex(h["hex"])), CURRENT_SYSTEM)
    require(v == h["values"], "Heap decode")
    return v


def allocation(s: dict, h: dict, display: dict, system: str) -> None:
    pointers = s["pointers"]
    require(
        h["address"] == pointers["vars"]
        and len(bytes.fromhex(h["hex"])) == pointers["e_line"] - pointers["vars"],
        "Variable extent disagrees with system pointers",
    )
    display_end = pointers["df_end"] if system.endswith("80") else pointers["vars"]
    require(
        display["address"] == pointers["d_file"]
        and len(bytes.fromhex(display["hex"])) == display_end - pointers["d_file"],
        "Display extent disagrees with system pointers",
    )


def readable(d: dict, system: str, ram: int, passed: bool) -> None:
    require(d["machine"] == system and d["ram_bytes"] == ram, "Readable configuration")
    expected_identity = {
        "sinclair-zx80": {
            "emulator_sha256": "7239551de49dfc8ecdfb857c5df475cf5e3ab864c5e70a89e3e4d112b1823069",
            "firmware_sha256": "9374711cb6a5fd53c1c98d1d20ecb444d01d621a322f3d066ef216d515ac5161",
        },
        "sinclair-zx81": {
            "emulator_sha256": "b631cecd690ccbf431fd498319708aaf6bfecfa251ebf9b1e55a7e8ff063ac74",
            "firmware_sha256": "14ad84f4243efcd41587ff46ab932d11087043e8d455a1ed2a227b9657828dfa",
        },
    }
    require(d["identity"] == expected_identity[system], "Unqualified executable/ROM")
    p = C.V.folder(system)
    require(
        d["sources"]
        == {n: C.T.sha(p / n) for n in ("routines.bas", "room.bas", "demo.bas")},
        "Readable source binding",
    )
    for s in d["snapshots"]:
        snapshot(s, system, ram)
    if not passed:
        require(
            d["status"] == "entry-rejected"
            and bytes.fromhex(d["snapshots"][-1]["system_hex"])[0] == 3,
            "Missing actual memory rejection",
        )
        require(
            d["rejected_line"] in (p / "demo.bas").read_text().splitlines(),
            "Rejected line",
        )
        screen(d["screen"], system)
        return
    require(
        d["status"] == "passed" and d["sample_frames"] > 0, "Incomplete readable run"
    )
    lines = stored(d["program_hex"], system)
    require(lines == d["lines"], "Stored line sizes")
    expected = (
        {"routines": 331, "initialiser": 475, "caller": 175}
        if system.endswith("80")
        else {"routines": 659, "initialiser": 1086, "caller": 285}
    )
    actual = {
        name: sum(
            l["bytes"]
            for l in lines
            if (
                l["number"] < 1000
                if name == "caller"
                else 1000 <= l["number"] < 2000
                if name == "routines"
                else l["number"] >= 2000
            )
        )
        for name in expected
    }
    require(actual == expected == d["component_bytes"], "Component accounting")
    for key, field in [
        ("sampled_min_gap", "observed_gap"),
        ("sampled_min_sp", "sp"),
        ("sampled_max_frontier", "frontier"),
    ]:
        snapshot(d["extrema"][key], system, ram)
        require(d[key] == d["extrema"][key][field], "Sampled extremum")
    text = screen(d["screen"], system)
    require(
        all(
            t in text for t in ("TILE 3", "FLAGS 4", "CHANGED 3", "WORLD 6,4", "TILE 2")
        ),
        "Incomplete caller display",
    )


def compact(d: dict, system: str) -> None:
    require(
        d["status"] == "passed" and d["ram_bytes"] == 1024 and d["machine"] == system,
        "Stock qualification",
    )
    require(d["sources"] == C.sources(system), "Compact source binding")
    lines = stored(d["program_hex"], system)
    require(lines == d["lines"], "Compact stored program")
    require(
        sum(l["bytes"] for l in lines) == (672 if system.endswith("80") else 683),
        "Compact byte cost",
    )
    require(
        stored(d["dispatcher_program_hex"], system) == d["dispatcher_lines"],
        "Dispatcher program",
    )
    for key in ("loaded_snapshot", "caller_snapshot"):
        snapshot(d[key], system, 1024)
    allocation(d["caller_snapshot"], d["caller_heap"], d["caller_screen"], system)
    pointers = d["caller_snapshot"]["pointers"]
    program_start = 16424 if system.endswith("80") else 16509
    program_end = pointers["vars"] if system.endswith("80") else pointers["d_file"]
    require(
        program_end - program_start == len(bytes.fromhex(d["program_hex"])),
        "Stored program extent",
    )
    system_bytes = program_start - 16384
    variable_bytes = len(bytes.fromhex(d["caller_heap"]["hex"]))
    display_bytes = len(bytes.fromhex(d["caller_screen"]["hex"]))
    workspace_bytes = (
        0 if system.endswith("80") else pointers["stkend"] - pointers["e_line"]
    )
    stack_top_bytes = 17408 - d["caller_snapshot"]["sp"]
    require(
        (variable_bytes, display_bytes, d["caller_snapshot"]["observed_gap"])
        == ((131, 67, 110) if system.endswith("80") else (69, 32, 101)),
        "Published stopped stock accounting changed",
    )
    require(
        system_bytes
        + program_end
        - program_start
        + variable_bytes
        + display_bytes
        + workspace_bytes
        + stack_top_bytes
        + d["caller_snapshot"]["observed_gap"]
        == 1024,
        "Whole-machine accounting",
    )
    text = screen(d["caller_screen"], system)
    heap(d["caller_heap"])
    require(
        bytes.fromhex(d["caller_snapshot"]["system_hex"])[0] == 8,
        "Public caller did not STOP",
    )
    require(
        all(
            t in text for t in ("TILE 3", "FLAGS 4", "CHANGED 3", "WORLD 6,4", "TILE 2")
        )
        if system.endswith("80")
        else [x.strip() for x in text.splitlines() if x.strip()]
        == ["3", "2", "2", "9/95"],
        "Stock caller output",
    )

    def map_values(v: dict) -> list:
        return v["M"] if system.endswith("80") else [x - 28 for x in v["M$"]]

    initial = heap(d["dispatcher_start"])
    model = map_values(initial).copy()
    require(len(model) == (36 if system.endswith("80") else 35), "Map capacity")
    expected_map = [i % 4 for i in range(35)]
    if system.endswith("80"):
        expected_map[29], expected_map[31], expected_map[33] = 3, 1, 3
        expected_map.append(9)
    require(model == expected_map, "Initial room differs from maintained data")
    expected_cases = C.calls(system)
    require(len(d["cases"]) == len(expected_cases) > 60, "Case inventory")
    for expected, case in zip(expected_cases, d["cases"], strict=True):
        require(
            all(case[k] == expected[k] for k in ("label", "op", "args")),
            "Case identity",
        )
        v = heap(case["heap"])
        snapshot(case["snapshot"], system, 1024)
        allocation(case["snapshot"], case["heap"], case["screen"], system)
        text = screen(case["screen"], system)
        raw_lines = [
            line
            for line in bytes.fromhex(case["screen"]["hex"]).split(bytes([118]))
            if line
        ]
        # The ROM displays inverse L/S (ZX80) or L (ZX81) at the next INPUT.
        # Retain and validate that cursor; it is not a third printed result.
        require(
            len(raw_lines) == 3
            and raw_lines[-1]
            == (bytes([177, 184]) if system.endswith("80") else bytes([177])),
            "Missing INPUT cursor or unexpected diagnostic output",
        )
        numeric_lines = [line.strip() for line in text.splitlines() if line.strip()][
            :-1
        ]
        require(len(numeric_lines) == 2, "Missing fresh diagnostic display")
        require(
            [float(x) for x in numeric_lines] == [v["T"], v["F"]],
            "Display/heap disagreement",
        )
        require(
            bytes.fromhex(case["snapshot"]["system_hex"])[0] == 255,
            "BASIC report error",
        )
        op = case["op"]
        a = case["args"]
        c, r, value = (
            (a[0], a[1], a[2] if op == "write" else 77)
            if op in ("read", "write")
            else (0, 0, a[0])
            if op == "property"
            else (a[0], a[1], 0)
        )
        target = (
            {"read": 1000, "write": 1100, "property": 1200, "world": 1300}
            if system.endswith("80")
            else {"read": 100, "write": 200, "property": 300, "world": 400}
        )[op]
        require(
            case["submitted"] == [c, r, value, target], "Wrong native call arguments"
        )
        require(
            all(
                same_number(actual, expected)
                for actual, expected in zip(
                    (v["V"], v["A"], v["X"], v["Y"]), (value, target, c, r), strict=True
                )
            ),
            "Native arguments are stale or incomplete",
        )
        if op == "world":
            expected_cell = (
                (-1, -1)
                if system.endswith("80") and min(c, r) < 0
                else (c, r)
                if min(c, r) < 0
                else (int(c // 8), int(r // 8))
            )
        else:
            expected_cell = (c, r)
        require(
            all(
                same_number(actual, expected)
                for actual, expected in zip(
                    (v["C"], v["R"]), expected_cell, strict=True
                )
            ),
            "Incorrect native coordinate conversion",
        )
        t = None
        f = None
        if op in ("read", "write"):
            c, r = a[:2]
            valid = c == int(c) and r == int(r) and 0 <= c < 7 and 0 <= r < 5
            if op == "read":
                t = model[int(r * 7 + c)] if valid else -1
            else:
                tile = a[2]
                valid_id = tile == int(tile) and 0 <= tile <= 3
                if valid and valid_id:
                    model[int(r * 7 + c)] = tile
                    t = tile
                else:
                    t = tile if system.endswith("80") and not valid_id else -1
        elif op == "property":
            tile = a[0]
            f = [0, 1, 2, 4][int(tile)] if tile == int(tile) and 0 <= tile <= 3 else -1
        else:
            x, y = a
            valid = 0 <= x < 56 and 0 <= y < 40
            t = model[int(y // 8 * 7 + x // 8)] if valid else -1
        if system.endswith("80"):
            if op == "property":
                expected_e = int(f is not None and f >= 0)
            elif op == "write":
                expected_e = int(valid and valid_id)
            else:
                expected_e = int(valid)
            require(v["E"] == expected_e, "Incorrect success flag")
        if t is not None:
            require(v["T"] == t, f"Wrong result {case['label']}")
        if f is not None:
            require(v["F"] == f, f"Wrong property {case['label']}")
        require(map_values(v) == model, f"Map altered unexpectedly {case['label']}")
    for name in ("stride_variant", "write_variant", "repair_variant"):
        variant = d[name]
        require(
            stored(variant["program_hex"], system) == variant["lines"],
            "Variant program decode",
        )
        heap(variant["initial_heap"])
        if system.endswith("81"):
            clears = variant["entry_clears"]
            require(
                {c["line"] for c in clears}
                == {line["number"] for line in variant["lines"]},
                "Missing line-entry workspace observations",
            )
            freed = []
            for clear in clears:
                for label in ("before", "after"):
                    snapshot(clear[label], system, 1024)
                before = clear["before"]["pointers"]
                after = clear["after"]["pointers"]
                require(
                    before["d_file"] == after["d_file"],
                    "CLS altered the stored program",
                )
                freed.append(before["vars"] - after["vars"])
            require(max(freed) == 407, "Published listing-space measurement changed")
        require(len(variant["cases"]) == 2, "Incomplete fresh variant")
    require(
        d["repair_variant"]["program_hex"] == d["dispatcher_program_hex"],
        "Repair did not restore the standard listing",
    )
    require(
        d["stride_variant"]["program_hex"] != d["dispatcher_program_hex"],
        "Stride fault not installed",
    )
    require(
        d["write_variant"]["program_hex"] != d["dispatcher_program_hex"],
        "Write fault not installed",
    )
    for key in (
        "custom_start",
        "stride_start",
        "stride_repair_start",
        "write_start",
        "write_repair_start",
    ):
        heap(d[key])
    for key in (
        "customisation",
        "wrong_stride",
        "stride_repair",
        "seed_offset",
        "bad_write",
        "write_repair",
    ):
        case = d[key]
        heap(case["heap"])
        snapshot(case["snapshot"], system, 1024)
        allocation(case["snapshot"], case["heap"], case["screen"], system)
        screen(case["screen"], system)
    require(d["customisation"]["heap"]["values"]["F"] == 5, "Customisation absent")
    require(
        d["wrong_stride"]["heap"]["values"]["T"] == 0
        and d["stride_repair"]["heap"]["values"]["T"] == 2,
        "Stride fault/repair",
    )
    require(map_values(d["bad_write"]["heap"]["values"])[0] == 1, "Missing write fault")
    require(
        map_values(d["write_repair"]["heap"]["values"])[0] == 0, "Missing write repair"
    )


def manifest(folder: Path, system: str, ram: int) -> None:
    data = json.loads((folder / "manifest.json").read_text())
    expected = {
        "compact.json",
        "compact-caller.png",
        "compact-bad-write.png",
        "emulator-source-lock.json",
        f"readable-{ram}.json",
        f"readable-{ram}.png",
        f"readable-{ram // 2}.json",
        f"readable-{ram // 2}.png",
    }
    require(
        data["machine"] == system and set(data["files"]) == expected,
        "Evidence manifest inventory",
    )
    for name, digest in data["files"].items():
        path = folder / name
        require(C.T.sha(path) == digest, "Changed evidence/capture: " + name)
        if name.endswith(".png"):
            raw = path.read_bytes()
            require(
                raw[:8] == b"\x89PNG\r\n\x1a\n"
                and int.from_bytes(raw[16:20], "big") == 384
                and int.from_bytes(raw[20:24], "big") == 288,
                "Native capture dimensions",
            )
    lock = json.loads((folder / "emulator-source-lock.json").read_text())
    require(
        lock["version"] == "0.44.1"
        and lock["source_commit"] == "9e1220f8713e3eaa6842da55bcc95bdcd15fc81f"
        and lock["target"] == "aarch64-apple-darwin",
        "Release provenance",
    )
    positive = json.loads((folder / f"readable-{ram}.json").read_text())
    require(
        lock["executable_sha256"] == positive["identity"]["emulator_sha256"],
        "Release executable mismatch",
    )


CURRENT_SYSTEM = ""


def check(*, refresh_manifests: bool = False) -> None:
    global CURRENT_SYSTEM
    validated = []
    for system, ram in [("sinclair-zx80", 2048), ("sinclair-zx81", 4096)]:
        CURRENT_SYSTEM = system
        p = C.V.folder(system) / "verification/memory"
        if not refresh_manifests:
            manifest(p, system, ram)
        positive = json.loads((p / f"readable-{ram}.json").read_text())
        readable(positive, system, ram, True)
        readable(
            json.loads((p / f"readable-{ram // 2}.json").read_text()),
            system,
            ram // 2,
            False,
        )
        d = json.loads((p / "compact.json").read_text())
        compact(d, system)
        require(d["identity"] == positive["identity"], "Tool/ROM mismatch")
        validated.append((system, ram, p))
        print(system, positive["component_bytes"], "stock four-operation checks passed")
    if refresh_manifests:
        # Validate every route before changing any capture binding.
        generated = []
        for system, ram, folder in validated:
            names = [
                "compact.json",
                "compact-caller.png",
                "compact-bad-write.png",
                "emulator-source-lock.json",
                f"readable-{ram}.json",
                f"readable-{ram}.png",
                f"readable-{ram // 2}.json",
                f"readable-{ram // 2}.png",
            ]
            for name in names:
                if name.endswith(".png"):
                    raw = (folder / name).read_bytes()
                    require(
                        raw[:8] == b"\x89PNG\r\n\x1a\n"
                        and int.from_bytes(raw[16:20], "big") == 384
                        and int.from_bytes(raw[20:24], "big") == 288,
                        "Native capture dimensions",
                    )
            data = {
                "machine": system,
                "files": {name: C.T.sha(folder / name) for name in names},
            }
            generated.append((folder, data))
        for folder, data in generated:
            temporary = folder / "manifest.json.tmp"
            temporary.write_text(json.dumps(data, indent=2) + "\n")
            temporary.replace(folder / "manifest.json")
        for system, ram, folder in validated:
            manifest(folder, system, ram)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--refresh-manifests",
        action="store_true",
        help="After fresh native runs and visual capture review, rebind files only if all semantic checks pass",
    )
    args = parser.parse_args()
    check(refresh_manifests=args.refresh_manifests)
