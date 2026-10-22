"""Retain native records/artifacts and bind the column-expansion inventory."""

from __future__ import annotations

import argparse
import hashlib
import json
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--tools", type=Path, required=True)
    args = parser.parse_args()
    path = ROOT / "docs/column-expansion.json"
    data = json.loads(path.read_text())
    data["observers"] = {
        str(p.relative_to(ROOT)): sha(p)
        for p in sorted((ROOT / "scripts").glob("verify-column-*.py"))
    }
    for name in (
        "verify-game-loops.py",
        "verify-sega-turns.py",
        "verify-command-loops.py",
        "verify-collect-and-respond.py",
        "verify-hardware-input-loops.py",
        "build-stock-probe.py",
        "build-sega-probe.py",
    ):
        data["observers"]["scripts/" + name] = sha(ROOT / "scripts" / name)
    data["producers"] = {}
    for row in data["routes"]:
        folder = ROOT / row["folder"]
        target = folder / "verification"
        target.mkdir(exist_ok=True)
        build = folder / "build/verification"
        for p in build.iterdir():
            if p.is_file() and p.suffix in (".png", ".wav") and p.name != "failure.png":
                shutil.copy2(p, target / p.name)
        if row["track"] == "forth" or row.get("sound_absent"):
            shutil.copy2(build / "results.json", target / "results.json")
        if row.get("mos"):
            shutil.copy2(build / "collect.wav", target / "sound.wav")
        if row["track"] == "assembly" and not row.get("mos"):
            row["fault_record"] = str((target / "no-edge.json").relative_to(ROOT))
        elif row["track"] == "basic" and not row.get("sound_absent"):
            row["fault_record"] = str((target / "stale-command.json").relative_to(ROOT))
        row["observer"] = (
            "scripts/verify-column-"
            + (
                "mos"
                if row.get("mos")
                else "zx"
                if row.get("sound_absent")
                else "forth"
                if row["track"] == "forth"
                else "basic"
                if row["track"] == "basic"
                else "hardware"
            )
            + ".py"
        )
        executable = "emu198x-" + {
            "bbc-micro": "acorn-bbc-micro",
            "dragon-32": "dragon",
            "nintendo-game-boy": "game-boy",
            "coleco-colecovision": "colecovision",
        }.get(row["system"], row["system"])
        producer = json.loads(
            (
                args.tools / (executable + "-aarch64-apple-darwin-source-lock.json")
            ).read_text()
        )
        if sha(args.tools / executable) != producer["executable_sha256"]:
            raise ValueError("Changed executable: " + executable)
        data["producers"][executable] = producer
        row["producer"] = executable
        row["files"] = {
            str(p.relative_to(ROOT)): sha(p)
            for p in sorted(folder.rglob("*"))
            if p.is_file()
            and "build" not in p.relative_to(folder).parts
            and p.name not in ("README.md", ".DS_Store")
        }
    data["assembler_producer"] = json.loads(
        (args.tools / "asm198x-aarch64-apple-darwin-source-lock.json").read_text()
    )
    path.write_text(json.dumps(data, indent=2) + "\n")
    print("Bound", len(data["routes"]), "native machine/language routes")


if __name__ == "__main__":
    main()
