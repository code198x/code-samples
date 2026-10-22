"""Verify maintained BASIC rendering routines in released native emulators."""

import argparse
import concurrent.futures
import importlib.util
import json
import re
from pathlib import Path

s = importlib.util.spec_from_file_location(
    "runner", Path(__file__).with_name("basic_rendering_transport.py")
)
R = importlib.util.module_from_spec(s)
s.loader.exec_module(R)
G = R


def dialect(system: str, text: str) -> str:
    if system in ["sinclair-zx-spectrum", "memotech-mtx"]:
        # Input below uses the original zero-based PET map contract.
        text = G.spectrum(text)
        if system == "memotech-mtx":
            text = text.replace("GO SUB", "GOSUB").replace("GO TO", "GOTO")
    if system == "acorn-atom":
        text = (
            text.replace("M(", "MM(")
            .replace("P(", "PP(")
            .replace("CHR$", "$")
            .replace(":", ";")
        )
        text = re.sub(r";(?=$|\n)", "", text, flags=re.MULTILINE)
        text = re.sub(
            r'^(\d+ PRINT(?: "[^"]*"| E)?)$', r"\1'", text, flags=re.MULTILINE
        )
    return text


def printed(system: str, expression: str, newline: bool = True) -> str:
    return R.V.printed(system, expression, newline)


def region_program(system: str, reference: bool = False) -> tuple[str, int]:
    folder = R.ROOT / system / "patterns/basic/rendering/text-region"
    original = (
        R.ROOT / system / "patterns/basic/rendering/tile-map/demo.bas"
    ).read_text()
    prefix = [l for l in original.splitlines() if int(l.split()[0]) < 80]
    code = []
    expect = []
    count = 0
    for q, u, a, b in [
        (-1, 0, 2, 2),
        (0, -1, 2, 2),
        (0, 0, 0, 2),
        (0, 0, 2, 0),
        (7, 0, 2, 2),
        (0, 5, 2, 2),
    ] + ([] if system == "acorn-atom" else [(0.5, 0, 2, 2), (0, 0, 2.5, 1)]):
        code += [f"Q={q}:U={u}:A={a}:B={b}:GOSUB 1400", "PRINT CHR$(48+E);"]
        count += 1
    # No malformed ID may leak an earlier part of the region to the screen.
    code += [
        "PRINT",
        "Q=2:U=1:A=3:B=2",
        "M(20)=4:GOSUB 1400",
        "PRINT CHR$(48+E)",
        "M(20)=0:GOSUB 1400",
        "PRINT CHR$(48+E)",
        "Q=3:U=2:A=1:B=1:GOSUB 1400",
        "PRINT CHR$(48+E)",
    ]
    expect = [
        printed(system, '"' + "0" * count + '"'),
        printed(system, '"0"'),
        printed(system, '"000"'),
        printed(system, '"020"'),
        printed(system, '"1"'),
        printed(system, '"2"'),
        printed(system, '"1"'),
    ]
    numbered = "\n".join(f"{80 + i * 10} {c}" for i, c in enumerate(code)) + "\n"
    # Prefix is already native; only convert test statements.
    body = dialect(system, numbered)
    # Atom PRINT E needs a line end; partial CHR$ writes do not.
    if system == "acorn-atom":
        body = re.sub(r"(?m)^(\d+ PRINT \$\(48\+E\))$", r"\1'", body).replace(
            "PRINT\n", "PRINT'\n"
        )
        for i, c in enumerate(code):
            if c.endswith(";"):
                body = body.replace(
                    f"{80 + i * 10} PRINT $(48+E)'", f"{80 + i * 10} PRINT $(48+E)"
                )
    if system in ["sinclair-zx-spectrum", "memotech-mtx"]:
        # G.spectrum handles constant M(20) only for initialisation list; test index is explicit here.
        body = body.replace("M(20)", "M(21)")
    lines = prefix + (
        [f"{80 + i * 10} {p}" for i, p in enumerate(expect)]
        if reference
        else body.splitlines()
    )
    lines += [
        "850 " + printed(system, '"DONE"'),
        "900 STOP" if system in ["sinclair-zx-spectrum", "memotech-mtx"] else "900 END",
    ]
    if not reference:
        lines += (folder / "query.bas").read_text().splitlines() + (
            folder / "region.bas"
        ).read_text().splitlines()
    return "\n".join(lines) + "\n", count + 3


def qualify_region(system: str) -> None:
    folder = R.ROOT / system / "patterns/basic/rendering/text-region"
    (folder / "build/verification/results.json").unlink(missing_ok=True)
    working, n = region_program(system)
    reference, _ = region_program(system, True)
    a = R.run(system, working, "checked", folder)
    b = R.run(system, reference, "reference", folder)
    R.T.require(a == b, system + ": region differs from independent literal output")
    bad = working.replace("D=R*W+C", "D=R*(W-1)+C")
    R.T.require(bad != working, "No stride mutant")
    c = R.run(system, bad, "wrong-stride", folder)
    R.T.require(c != b, system + ": wrong stride accepted")
    print("PASS region", system, n, flush=True)
    write_record(folder, system, "text-region", n)


def qualify_map(system: str) -> None:
    folder = R.ROOT / system / "patterns/basic/rendering/tile-map"
    # Independent test generator has explicit per-call expected numbers.
    (folder / "build/verification/results.json").unlink(missing_ok=True)
    source = (folder / "demo.bas").read_text()
    pet = (
        R.ROOT / "commodore-pet/patterns/basic/rendering/tile-map/demo.bas"
    ).read_text()
    counts = {}
    for kind in ["queries", "writes", "pixels"]:
        actual, n = R.V.cases("commodore-pet", pet, kind)
        expected, _ = R.V.cases("commodore-pet", pet, kind, reference=True)
        cls = source.splitlines()[0]
        actual = re.sub(r"^5 .*", cls, actual, flags=re.MULTILINE)
        expected = re.sub(r"^5 .*", cls, expected, flags=re.MULTILINE)
        if system in ["sinclair-zx-spectrum", "memotech-mtx"]:
            actual = dialect(system, actual)
            expected = dialect(system, expected)
        if system in ("acorn-bbc-micro", "acorn-electron"):
            # BBC PRINT formats a numeric variable differently from literal
            # list items. Preserve that presentation without deriving values
            # from the routine being tested.
            rows = []
            for row in expected.splitlines():
                match = re.fullmatch(r"(\d+) PRINT ([-.0-9;]+)", row)
                if match:
                    values = match[2].split(";")
                    assignment = ":".join(f"Z{i}={v}" for i, v in enumerate(values))
                    expression = ";".join(f"Z{i}" for i in range(len(values)))
                    row = f"{match[1]} {assignment}:PRINT {expression}"
                    if len(values) == 4 and kind == "queries":
                        # The actual property loop issues four separate PRINTs.
                        # Each starts a BBC numeric field; one PRINT list does not.
                        row = (
                            f"{match[1]} {assignment}:"
                            + ":".join(f"PRINT Z{i};" for i in range(4))
                            + ":PRINT"
                        )
                rows.append(row)
            expected = "\n".join(rows) + "\n"
        R.T.require(
            R.run(system, actual, kind, folder)
            == R.run(system, expected, kind + "-reference", folder),
            system + ": " + kind + " differs",
        )
        counts[kind] = n
    wrong = source.replace("D=R*W+C", "D=R*(W-1)+C")
    R.T.require(
        R.run(system, source, "demo", folder)
        != R.run(system, wrong, "wrong-stride", folder),
        system + ": stride mutation not visible",
    )
    print("PASS map", system, counts, flush=True)
    write_record(folder, system, "tile-map", counts)


def write_record(
    folder: Path, system: str, kind: str, counts: dict[str, int] | int
) -> None:
    output = folder / "build/verification"
    exe = R.NATIVE / ("emu198x-" + R.ALIASES.get(system, system))
    rom = R.FW / R.ROMS.get(system, system)
    result = {
        "status": "passed",
        "system": system,
        "kind": kind,
        "case_counts": counts,
        "sources": {
            str(p.relative_to(R.ROOT)): R.T.sha(p)
            for p in folder.rglob("*.bas")
            if not any(x in p.parts for x in ["build", "verification", "mistakes"])
        },
        "emulator_sha256": R.T.sha(exe),
        "firmware": {p.name: R.T.sha(p) for p in rom.glob("*.rom")},
        "observer_sha256": R.T.sha(Path(__file__)),
        "generator_sha256": R.T.sha(R.ROOT / "scripts/verify-tilemaps.py"),
        "native_transport_sha256": R.T.sha(R.ROOT / "scripts/verify-game-loops.py"),
        "producer": json.loads(
            (
                R.NATIVE
                / f"emu198x-{R.ALIASES.get(system, system)}-aarch64-apple-darwin-source-lock.json"
            ).read_text()
        ),
        "transport_sha256": R.T.sha(
            Path(__file__).with_name("basic_rendering_transport.py")
        ),
        "captures": {p.name: R.T.sha(p) for p in output.glob("*.png")},
        "wrong_stride_rejected": True,
        "independent_full_raster_match": True,
        "limits": "Released emulator, stock firmware. Text-cell region output and checked logical queries; no native graphics or original hardware claim.",
    }
    (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    a = argparse.ArgumentParser()
    a.add_argument("kind", choices=["region", "map"])
    a.add_argument("systems", nargs="+")
    a.add_argument("--native", type=Path, required=True)
    a.add_argument("--firmware-root", type=Path, required=True)
    args = a.parse_args()
    R.configure(args.native, args.firmware_root)
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        futures = {
            pool.submit(qualify_region if args.kind == "region" else qualify_map, s): s
            for s in args.systems
        }
        for f in concurrent.futures.as_completed(futures):
            try:
                f.result()
            except BaseException as e:
                print("FAIL", futures[f], repr(e), flush=True)
                raise
