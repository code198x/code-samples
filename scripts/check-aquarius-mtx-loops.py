"""Decode retained loop outcomes independently of the native runner."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "png", ROOT / "scripts/verify-sega-turns.py"
)
PNG = importlib.util.module_from_spec(spec)
spec.loader.exec_module(PNG)


def _load(module: str, file: str):
    found = importlib.util.spec_from_file_location(module, ROOT / "scripts" / file)
    assert found and found.loader
    value = importlib.util.module_from_spec(found)
    found.loader.exec_module(value)
    return value


E = _load("loop_bytes", "evidence_bytes.py")
V = _load("loop_recorder", "verify-aquarius-mtx-loops.py")
BUILD = ROOT / "scripts/build-aquarius-mtx-loops.py"


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def bound(root: Path, name: str, digest: str) -> Path:
    p = (root / name).resolve()
    require(
        p.is_relative_to(root.resolve()) and p.is_file(), "Missing/outside evidence"
    )
    require(
        hashlib.sha256(p.read_bytes()).hexdigest() == digest,
        f"Changed evidence: {name}",
    )
    return p


def entered(system: str, variant: str, r: dict) -> list[str]:
    """The listing the recorder types for a BASIC case.

    The MTX listing carries its screen reader, assembled with the pinned
    Asm198x, so the reader's bytes are part of the typed text.
    """
    folder = ROOT / system / "patterns/basic/framework/command-loop"
    output = f"build/{variant}/entered.bas"
    pin = r["assembler_source_lock"]["executable_sha256"]
    mtx = system == "memotech-mtx"
    build = E.function(
        ROOT / "scripts/verify-aquarius-mtx-loops.py",
        "entered",
        (system, variant, E.ASSEMBLER if mtx else ""),
        folder,
        (output,),
    )
    return E.rebuild(build, pin if mtx else None)[output].decode().split("\n")


def require_programs(r: dict) -> None:
    """Rebuild or regenerate every case's program and compare it with the record."""
    system = r["system"]
    folder = ROOT / system / "patterns" / r["track"] / "framework/command-loop"
    # The typed program is reusable.bas; the lesson presents it as two parts.
    require(
        r["track"] == "assembly"
        or (folder / "reusable.bas").read_text()
        == (folder / "caller.bas").read_text() + (folder / "routines.bas").read_text(),
        "Reusable program differs from its caller and routines",
    )
    for variant, case in sorted(r["cases"].items()):
        if r["track"] == "assembly":
            ext = "gb" if system == "nintendo-game-boy" else "bin"
            output = f"build/{variant}/demo.{ext}"
            E.require_program(
                E.function(
                    BUILD, "build", (system, E.ASSEMBLER, variant), folder, (output,)
                ),
                output,
                r["assembler_source_lock"]["executable_sha256"],
                recorded=bytes(case["loaded_bytes"]),
            )
        else:
            E.require_typed(
                "\n".join(entered(system, variant, r)),
                hashlib.sha256(case["entered_source"].encode()).hexdigest(),
                f"{system} {variant} listing",
            )


def check_record(root: Path, r: dict) -> None:
    require(r["status"] == "passed", "Missing pass")
    asm = r["track"] == "assembly"
    aq = r["system"] == "mattel-aquarius"
    required = {
        "working",
        "step-three",
        "wrong-reset",
        "repaired",
        "wrap",
        "nonzero",
    } | ({"no-edge"} if asm else set())
    require(set(r["cases"]) == required, "Missing cases")
    for key, version in [
        ("producer_source_lock", "0.44.1"),
        ("assembler_source_lock", "0.0.71"),
    ]:
        lock = r[key]
        require(
            lock["version"] == version
            and lock["before_lock_sha256"]
            == lock["after_lock_sha256"]
            == lock["committed_lock_sha256"],
            "Unqualified tool producer",
        )
    parity_frames = {}
    for variant, case in r["cases"].items():
        obs = case["observations"]
        require(
            [o["stage"] for o in obs]
            == ["initial", "idle", "first", "held", "ignored", "second"],
            "Missing/reordered observations",
        )
        initial = 254 if variant == "wrap" else 100 if variant == "nonzero" else 0
        step = 3 if variant == "step-three" else 255 if variant == "nonzero" else 1
        expected = [
            initial,
            initial,
            (initial + step) % 256,
            (initial + step) % 256,
            (initial + step) % 256,
            (initial + 2 * step) % 256,
        ]
        if variant == "wrong-reset":
            expected = [0] * 6
        actual = []
        for o in obs:
            raw = o["memory"]
            require(
                bool(raw) and all(type(x) is int and 0 <= x <= 255 for x in raw),
                "Invalid memory dump",
            )
            if asm and not aq:
                require(len(raw) == 4, "Missing context bytes")
                count = raw[0]
                require(o["ticks"] == raw[2] + 256 * raw[3], "Bad service count")
            else:
                require(len(raw) == (1000 if aq else 960), "Missing screen cells")
                text = "".join(chr(x & 127) for x in raw)
                matches = re.findall(
                    r"TURN\s+\$([0-9A-F]{2})" if asm else r"TURN\s*(\d+)",
                    text,
                    re.IGNORECASE,
                )
                require(len(matches) == 1, "Missing visible counter")
                count = int(matches[0], 16 if asm else 10)
            require(
                count == o["count"],
                "Claimed count disagrees with actual display/context",
            )
            actual.append(count)
            image = bound(root, o["capture"], o["capture_sha256"])
            if asm and not aq and variant != "no-edge":
                key = count % 2
                frame = PNG.raster(image)
                if key in parity_frames:
                    require(
                        parity_frames[key] == frame,
                        "Backdrop disagrees with count parity",
                    )
                else:
                    parity_frames[key] = frame
        if not asm and not aq:
            reader = bytes(case["loaded_bytes"])
            require(len(reader) == 44, "Missing verification reader")
            require(
                hashlib.sha256(reader).hexdigest() == case["loaded_sha256"],
                "Changed verification reader bytes",
            )
        if variant == "no-edge":
            require(actual != [0, 0, 1, 1, 1, 2], "No-edge passed normal press guard")
        else:
            require(
                actual == expected, f"{variant}: wrong independently decoded sequence"
            )
        if asm:
            data = bytes(case["loaded_bytes"])
            require(len(data) == (152 if aq else 135), "Wrong payload size")
            require(
                hashlib.sha256(data).hexdigest() == case["loaded_sha256"],
                "Changed loaded bytes",
            )
            if aq:
                require(
                    re.search(
                        r"RETURNED\s*5",
                        "".join(chr(x & 127) for x in case["returned_screen"]),
                        re.IGNORECASE,
                    )
                    is not None,
                    "Missing firmware arithmetic after USR",
                )
            else:
                delta = (obs[1]["ticks"] - obs[0]["ticks"]) % 65536
                require(
                    118 <= delta <= 122, "Display servicing stopped while rules waited"
                )
    if asm and not aq:
        require(
            set(parity_frames) == {0, 1} and parity_frames[0] != parity_frames[1],
            "Backdrop did not actually change",
        )

    # The program decides staleness: assembly payloads are rebuilt with the
    # pinned Asm198x (rule 1), typed listings are regenerated (rule 2).
    # Source and observer digests are provenance only.
    require_programs(r)


def check(root: Path) -> int:
    inventory = json.loads((root / "docs/aquarius-mtx-loops.json").read_text())
    require(
        set(inventory["routes"])
        == {
            f"{system}/{track}"
            for system in ("mattel-aquarius", "memotech-mtx")
            for track in ("basic", "assembly")
        },
        "Missing inventory routes",
    )
    count = 0
    for system in ("mattel-aquarius", "memotech-mtx"):
        for track in ("basic", "assembly"):
            path = (
                root
                / system
                / "patterns"
                / track
                / "framework/command-loop/verification/reusable-results.json"
            )
            bound(
                root,
                str(path.relative_to(root)),
                inventory["routes"][f"{system}/{track}"]["record_sha256"],
            )
            check_record(root, json.loads(path.read_text()))
            count += 1
    return count


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    a = p.parse_args()
    print("PASS", check(a.root.resolve()), "independent machine/language routes")


if __name__ == "__main__":
    main()
