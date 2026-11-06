"""Independently decode retained Dragon/Ace state and reject changed evidence.

Assembly routes rebuild each case's caller with the pinned Asm198x release and
compare it with the bytes the record says were loaded. Typed routes regenerate
the text the recorder typed and compare it with the record. Edits to recorder
scripts do not invalidate the evidence; only a change to the program does.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import wave
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def _load(module: str, file: str):
    found = importlib.util.spec_from_file_location(module, ROOT / "scripts" / file)
    assert found and found.loader
    value = importlib.util.module_from_spec(found)
    found.loader.exec_module(value)
    return value


E = _load("dragon_ace_bytes", "evidence_bytes.py")
VARIANTS = _load("dragon_ace_variants", "verify-dragon-ace-language-variants.py")
BUILD = ROOT / "scripts/build-dragon-ace-loops.py"


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def decode(raw: list[int], dragon: bool) -> str:
    require(
        len(raw) >= 160 and all(type(x) is int and 0 <= x <= 255 for x in raw),
        "Invalid video RAM",
    )
    codes = [x & 63 if dragon else x & 127 for x in raw]
    return "".join(chr(x + 64) if dragon and x < 32 else chr(x) for x in codes)


def bound(root: Path, name: str, digest: str) -> None:
    path = (root / name).resolve()
    require(
        path.is_relative_to(root.resolve()) and path.is_file(),
        "Missing/outside evidence",
    )
    require(sha(path) == digest, f"Changed evidence: {name}")


def require_programs(record: dict, dragon: bool, assembly: bool) -> None:
    """Rebuild or regenerate every case's program and compare it with the record."""
    system = "dragon-32" if dragon else "jupiter-ace"
    if assembly:
        folder = ROOT / system / "patterns/assembly/framework/command-loop"
        for variant, case in sorted(record["cases"].items()):
            output = f"build/{variant}/demo.bin"
            E.require_program(
                E.function(
                    BUILD, "build", (system, E.ASSEMBLER, variant), folder, (output,)
                ),
                output,
                record["assembler_source_lock"]["executable_sha256"],
                recorded=bytes(case["loaded_bytes"]),
            )
        return
    programs = VARIANTS.variants(system)
    for variant, case in sorted(record["cases"].items()):
        E.require_typed(
            programs[variant],
            hashlib.sha256(case["entered_source"].encode()).hexdigest(),
            f"{system} {variant} listing",
        )
    suffix = "bas" if dragon else "fth"
    folder = ROOT / system / "patterns" / record["track"] / "framework/command-loop"
    # The lesson's customisation and mistake files are the recorder's own output.
    for variant, name in [
        ("step-three", f"customise.{suffix}"),
        ("wrong-reset", f"mistakes/reset-each-command.{suffix}"),
    ]:
        require(
            (folder / name).read_text() == programs[variant],
            f"{name} differs from its generated variant",
        )


def check_record(root: Path, record: dict, dragon: bool, assembly: bool) -> None:
    require(record.get("status") == "passed", "Missing pass")
    cases = record["cases"]
    required = {"working", "step-three", "wrong-reset", "repaired", "nonzero"}
    if assembly:
        required |= {"wrap", "no-drawing", "no-sound"}
    require(set(cases) == required, "Missing/extra cases")
    for variant, case in cases.items():
        initial = (
            254
            if variant == "wrap"
            else 100
            if assembly and variant == "nonzero"
            else 37
            if variant == "nonzero"
            else 0
        )
        step = (
            3
            if variant == "step-three"
            else 255
            if assembly and variant == "nonzero"
            else 1
        )
        stages = (
            ["initial", "idle", "first", "held", "ignored", "second"]
            if assembly
            else ["initial", "idle", "first", "ignored", "second"]
        )
        expected = (
            [
                initial,
                initial,
                (initial + step) % 256,
                (initial + step) % 256,
                (initial + step) % 256,
                (initial + 2 * step) % 256,
            ]
            if assembly
            else [initial, initial, initial + step, initial + step, initial + 2 * step]
        )
        if variant == "wrong-reset":
            expected = [0] * len(stages)
        observations = case["observations"]
        require(
            [o["stage"] for o in observations] == stages,
            "Missing/reordered observations",
        )
        for o, count in zip(observations, expected, strict=True):
            text = decode(o["screen"], dragon)
            match = (
                re.match(r"TURN \$([0-9A-F]{2})", text)
                if assembly
                else re.search(r"TURN\s+(\d+)", text, re.IGNORECASE)
            )
            require(match is not None, "Missing visible count")
            actual = int(match[1], 16 if assembly else 10)
            require(
                actual == count == o["count"],
                f"{variant}/{o['stage']}: wrong independently decoded count",
            )
            bound(root, o["capture"], o["capture_sha256"])
        if assembly:
            text = decode(case["returned_screen"], dragon)
            require(
                case["returned_to_interpreter"] is True
                and re.search(r"RETURNED\s*5", text, re.IGNORECASE) is not None,
                "No firmware arithmetic after quit",
            )
            loaded = bytes(case["loaded_bytes"])
            require(len(loaded) == (234 if dragon else 212), "Wrong payload size")
            require(
                hashlib.sha256(loaded).hexdigest() == case["loaded_sha256"],
                "Changed loaded payload",
            )
            box = [
                observations[0]["screen"][i] & (63 if dragon else 127)
                for i in (64, 65, 66, 96, 97, 98, 128, 129, 130)
            ]
            expected_box = (
                [24, 24, 24, 24, 32, 24, 24, 24, 24]
                if dragon
                else [88, 88, 88, 88, 32, 88, 88, 88, 88]
            )
            require(
                (box == expected_box) == (variant != "no-drawing"),
                "Drawing negative did not reject same box guard",
            )
    if assembly:
        for key in ("producer_source_lock", "assembler_source_lock"):
            lock = record[key]
            require(
                lock["before_lock_sha256"]
                == lock["after_lock_sha256"]
                == lock["committed_lock_sha256"],
                "Changed producer lock",
            )
        require(
            record["producer_source_lock"]["version"] == "0.44.1",
            "Wrong emulator release",
        )
        powers = []
        for variant in ("working", "no-sound"):
            folder = (
                root
                / record["machine"]
                / "patterns/assembly/framework/command-loop/verification"
            )
            audio = folder / (variant + "-sound.wav")
            bound(root, str(audio.relative_to(root)), cases[variant]["audio_sha256"])
            with wave.open(str(audio)) as stream:
                require(stream.getsampwidth() == 2, "Unexpected PCM format")
                samples = array("h", stream.readframes(stream.getnframes()))
            require(bool(samples), "Empty audio")
            mean = sum(samples) / len(samples)
            powers.append(
                (
                    max(samples) - min(samples),
                    sum((x - mean) ** 2 for x in samples) / len(samples),
                )
            )
        require(
            powers[0][0] > 200 and powers[0][1] > max(1000, 4 * powers[1][1]),
            "Sound negative did not reject same PCM guard",
        )
    require_programs(record, dragon, assembly)


def check(root: Path) -> int:
    manifest = json.loads((root / "docs/dragon-ace-probes.json").read_text())
    rows = manifest["routes"]
    require(
        len(rows) == 4
        and {(r["system"], r["track"]) for r in rows}
        == {
            ("dragon-32", "basic"),
            ("dragon-32", "assembly"),
            ("jupiter-ace", "forth"),
            ("jupiter-ace", "assembly"),
        },
        "Missing or duplicate language route",
    )
    for row in rows:
        for kind in ("loop", "capability", "variants"):
            if kind + "_record" in row:
                bound(root, row[kind + "_record"], row[kind + "_record_sha256"])
    for system, track in [("dragon-32", "basic"), ("jupiter-ace", "forth")]:
        for language, filename in [
            (track, "variants.json"),
            ("assembly", "results.json"),
        ]:
            path = (
                root
                / system
                / "patterns"
                / language
                / "framework/command-loop/verification"
                / filename
            )
            check_record(
                root,
                json.loads(path.read_text()),
                system == "dragon-32",
                language == "assembly",
            )
        for category in ("framework/command-loop", "capabilities/input-drawing-sound"):
            record = json.loads(
                (
                    root
                    / system
                    / "patterns"
                    / track
                    / category
                    / "verification/results.json"
                ).read_text()
            )
            require(
                record["emulator_release"] == "v0.44.1"
                and record["producer_source_lock"]["version"] == "0.44.1",
                "Stale language probe",
            )
            require(bool(record["captures"]), "Missing refresh captures")
            for name, digest in record["captures"].items():
                bound(root, name, digest)
            # The typed program is the lesson's demo file; script digests are provenance.
            demo = f"{system}/patterns/{track}/{category}/demo.{'bas' if track == 'basic' else 'fth'}"
            require(demo in record["sources"], f"Missing typed program: {demo}")
            E.require_typed((root / demo).read_text(), record["sources"][demo], demo)
    return 4


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    a = p.parse_args()
    print(
        f"PASS: {check(a.root.resolve())} independently checked machine/language routes"
    )


if __name__ == "__main__":
    main()
