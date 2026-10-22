"""Verify maintained BASIC rendering routines in released native emulators."""

import argparse
import concurrent.futures
import importlib.util
import json
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "runner", Path(__file__).with_name("basic_rendering_transport.py")
)
R = importlib.util.module_from_spec(s)
s.loader.exec_module(R)


def reference(system: str) -> list[str]:
    if system in ["acorn-bbc-micro", "acorn-electron"]:
        return (
            ["GCOL 0,1:PLOT 69,16,12"]
            + [f"MOVE 32,{y}:DRAW 52,{y}" for y in [20, 24, 28, 32]]
            + [
                "MOVE 72,20:DRAW 96,20:DRAW 96,40:DRAW 72,40:DRAW 72,20",
                "GCOL 0,0:PLOT 69,40,24",
            ]
        )
    if system == "amstrad-cpc":
        return (
            ["PLOT 8,6,1"]
            + [f"MOVE 16,{y}:DRAW 26,{y},1" for y in [10, 12, 14, 16]]
            + [
                "MOVE 36,10:DRAW 48,10,1:DRAW 48,20,1:DRAW 36,20,1:DRAW 36,10,1",
                "PLOT 20,12,0",
            ]
        )
    return (
        ["PLOT 4,3"]
        + [f"PLOT 8,{y}:DRAW 5,0" for y in [5, 6, 7, 8]]
        + [
            "PLOT 18,5:DRAW 6,0:DRAW 0,5:DRAW -6,0:DRAW 0,-5",
            "INVERSE 1:PLOT 10,6:INVERSE 0",
        ]
    )


def verify(system: str) -> None:
    folder = R.ROOT / system / "patterns/basic/rendering/pixel-box"
    (folder / "build/verification/results.json").unlink(missing_ok=True)
    source = (folder / "demo.bas").read_text()
    routine = (folder / "routines.bas").read_text()
    prefix = (folder / "caller.bas").read_text().splitlines()[0]
    sine = system == "sinclair-zx-spectrum"
    gosub = "GO SUB" if sine else "GOSUB"
    let = "LET " if sine else ""
    # Read the real raster, compare every pixel with direct ROM line drawing.
    rows = (
        [prefix]
        + [f"{20 + 10 * i} {x}" for i, x in enumerate(reference(system))]
        + ['800 PRINT "DONE"', "900 STOP" if sine else "900 END"]
    )
    expected = R.run(system, "\n".join(rows) + "\n", "reference", folder)
    actual = R.run(system, source, "demo", folder)
    R.T.require(
        actual == expected,
        system + ": full raster differs from direct line-drawing reference",
    )
    # Both wrong units and omitted pixels must fail the same complete-raster guard.
    needle = {
        "acorn-bbc-micro": "PLOT 69,X*4,Y*4",
        "acorn-electron": "PLOT 69,X*4,Y*4",
        "amstrad-cpc": "PLOT X*2,Y*2,V",
        "sinclair-zx-spectrum": "PLOT X,Y",
    }[system]
    R.T.require(source.count(needle) == 1, "Ambiguous plot primitive")
    omitted = source.replace(needle, "REM DRAW OMITTED")
    R.T.require(
        R.run(system, omitted, "omitted-draw", folder) != expected,
        system + ": omitted plotting passed",
    )
    if sine:
        wrong = source.replace(needle, "PLOT X+1,Y")
    else:
        wrong = source.replace(
            needle,
            needle.replace("X*4", "X*2").replace("Y*4", "Y*2")
            if "69" in needle
            else "PLOT X,Y,V",
        )
    R.T.require(
        R.run(system, wrong, "wrong-units", folder) != expected,
        system + ": wrong units passed",
    )
    # Rejected calls must not write pixels; flags are printed as explicit characters.
    w, h = {
        "acorn-bbc-micro": (320, 256),
        "acorn-electron": (320, 256),
        "amstrad-cpc": (320, 200),
        "sinclair-zx-spectrum": (256, 176),
    }[system]
    commands = [f"{let}W={w}:{let}H={h}"]
    cases = [
        (2000, {"X": -1, "Y": 0, "V": 1}),
        (2000, {"X": w, "Y": 0, "V": 1}),
        (2000, {"X": 0, "Y": h, "V": 1}),
        (2000, {"X": 0.5, "Y": 0, "V": 1}),
        (2000, {"X": 0, "Y": 0, "V": 2}),
        (2100, {"Q": -1, "U": 0, "A": 3, "B": 3, "V": 1}),
        (2100, {"Q": w - 1, "U": 0, "A": 2, "B": 1, "V": 1}),
        (2200, {"Q": 0, "U": h - 1, "A": 1, "B": 2, "V": 1}),
        (2200, {"Q": 0, "U": 0, "A": 0, "B": 3, "V": 1}),
        (2200, {"Q": 0, "U": 0, "A": 1.5, "B": 3, "V": 1}),
    ]
    for call, values in cases:
        commands += [
            ":".join(let + k + "=" + str(v) for k, v in values.items())
            + f":{gosub} {call}",
            "PRINT CHR$ (48+E);",
        ]
    commands += ["PRINT", 'PRINT "DONE"']
    lines = (
        [prefix]
        + [f"{20 + 10 * i} {c}" for i, c in enumerate(commands)]
        + ["900 STOP" if sine else "900 END"]
    )
    working = "\n".join(lines) + "\n" + routine
    baseline = (
        "\n".join(
            [
                prefix,
                '20 PRINT "' + "0" * len(cases) + '"',
                '30 PRINT "DONE"',
                "900 STOP" if sine else "900 END",
            ]
        )
        + "\n"
    )
    R.T.require(
        R.run(system, working, "bounds", folder)
        == R.run(system, baseline, "bounds-reference", folder),
        system + ": bad request changed flags or pixels",
    )
    # Boundary coordinates and one-cell-thick boxes must draw the full perimeter.
    c = [
        let + f"W={w}:" + let + f"H={h}:" + let + "V=1",
        let + f"X={w - 1}:" + let + f"Y={h - 1}:" + gosub + " 2000",
        let + "Q=30:" + let + "U=20:" + let + "A=1:" + let + "B=3:" + gosub + " 2200",
        let + "Q=35:" + let + "U=20:" + let + "A=3:" + let + "B=1:" + gosub + " 2200",
        'PRINT "DONE"',
    ]
    prog = (
        "\n".join(
            [prefix]
            + [f"{20 + 10 * i} {x}" for i, x in enumerate(c)]
            + ["900 STOP" if sine else "900 END"]
        )
        + "\n"
        + routine
    )
    if sine:
        ref = [f"PLOT {w - 1},{h - 1}", "PLOT 30,20:DRAW 0,2", "PLOT 35,20:DRAW 2,0"]
    elif "acorn" in system:
        ref = [
            f"GCOL 0,1:PLOT 69,{(w - 1) * 4},{(h - 1) * 4}",
            "MOVE 120,80:DRAW 120,88",
            "MOVE 140,80:DRAW 148,80",
        ]
    else:
        ref = [
            f"PLOT {(w - 1) * 2},{(h - 1) * 2},1",
            "MOVE 60,40:DRAW 60,44,1",
            "MOVE 70,40:DRAW 74,40,1",
        ]
    refprog = (
        "\n".join(
            [prefix]
            + [f"{20 + 10 * i} {x}" for i, x in enumerate(ref)]
            + ['800 PRINT "DONE"', "900 STOP" if sine else "900 END"]
        )
        + "\n"
    )
    R.T.require(
        R.run(system, prog, "edges", folder)
        == R.run(system, refprog, "edges-reference", folder),
        system + ": edge pixels/degenerate boxes failed",
    )
    result = {
        "system": system,
        "kind": "pixel-box",
        "status": "passed",
        "bounds_cases": len(cases),
        "wrong_units_rejected": True,
        "omitted_draw_rejected": True,
        "edge_and_one_cell_boxes": True,
        "sources": {
            str(p.relative_to(R.ROOT)): R.T.sha(p) for p in folder.glob("*.bas")
        },
        "observer_sha256": R.T.sha(Path(__file__)),
        "native_transport_sha256": R.T.sha(R.ROOT / "scripts/verify-game-loops.py"),
        "firmware": {
            p.name: R.T.sha(p)
            for p in (R.FW / R.ROMS.get(system, system)).glob("*.rom")
        },
        "producer": json.loads(
            (
                R.NATIVE
                / f"emu198x-{R.ALIASES.get(system, system)}-aarch64-apple-darwin-source-lock.json"
            ).read_text()
        ),
        "independent_full_raster_match": True,
        "transport_sha256": R.T.sha(
            Path(__file__).with_name("basic_rendering_transport.py")
        ),
        "captures": {
            p.name: R.T.sha(p) for p in (folder / "build/verification").glob("*.png")
        },
        "emulator_sha256": R.T.sha(
            R.NATIVE / ("emu198x-" + R.ALIASES.get(system, system))
        ),
        "limits": "Stock-ROM APIs in released Emu198x. Whole decoded raster compared with independent direct line-drawing caller. No speed/original-hardware claim.",
    }
    (folder / "build/verification/results.json").write_text(
        json.dumps(result, indent=2) + "\n"
    )
    print("PASS pixels", system, flush=True)


if __name__ == "__main__":
    a = argparse.ArgumentParser()
    a.add_argument("systems", nargs="+")
    a.add_argument("--native", type=Path, required=True)
    a.add_argument("--firmware-root", type=Path, required=True)
    args = a.parse_args()
    R.configure(args.native, args.firmware_root)
    with concurrent.futures.ThreadPoolExecutor(max_workers=2) as p:
        list(p.map(verify, args.systems))
