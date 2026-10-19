"""Prepare deterministic AMOS inputs; this does not execute or validate AMOS."""

import argparse
import hashlib
import json
from pathlib import Path

CASES = {
    "die-faces": {
        "rolls": [1, 2, 3, 4, 5, 6],
        "actions": "SPACE R R R R SPACE R R SPACE",
        "expected": (
            "Faces 1, 2, 3, 4 give totals 1, 3, 6, 10 and bank 10. "
            "Next round faces 5, 6 give totals 5, 11 and bust; secured 10 stays. "
            "SPACE starts round 3 with last roll 0 and an empty outline."
        ),
    },
    "perfect-success": {
        "rolls": [4, 6, 4, 6, 4, 6],
        "actions": "SPACE R R SPACE R R SPACE R R",
        "expected": "Perfect 10 each round; target reached in round 3; secured 30.",
    },
    "preserve-and-recover": {
        "rolls": [4, 6, 5, 6, 4, 6, 4, 6],
        "actions": "SPACE B X R B SPACE R R SPACE R B SPACE R R SPACE R R",
        "expected": (
            "B and X at zero leave state unchanged. Round contributions "
            "4, 0 (bust 11), 6, 10, 10; secured 4, 4, 10, 20, 30. "
            "Success on round 5; no sixth round."
        ),
    },
    "range-and-limit": {
        "rolls": [1, 6, 2, 1],
        "actions": "SPACE R R R R Q",
        "expected": (
            "Current totals 1, 7, 9, 10. Exact 10 banks automatically; "
            "round 1 secured 10. Q quits at the between-round prompt."
        ),
    },
    "unreachable": {
        "rolls": [6, 6, 6, 6, 6, 6],
        "actions": "SPACE R R SPACE R R SPACE R R",
        "expected": (
            "Three bust totals of 12 secure zero. Two rounds could score only "
            "20, so the target is out of reach after round 3."
        ),
    },
}


def prepare(destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    if any(destination.iterdir()):
        raise ValueError("Use an empty output directory; existing files are preserved")
    source = Path(__file__).with_name("bank-or-risk.amos").read_text()
    if source.count("BR_FACE=Rnd(5)+1") != 1 or source.count("   BR_BANKED=0\n") != 1:
        raise ValueError("Source changed; review the probe transformation")
    manifest = {
        "status": "Prepared native test inputs, not execution results",
        "source_sha256": hashlib.sha256(source.encode()).hexdigest(),
        "method": (
            "Replace random supplier with READ, restore DATA at each challenge, "
            "append prescribed values. Retain all game logic and input. "
            "Actions mean separate press/release cycles; do not type the whole "
            "sequence at once. Stop at the named result; further rolls exhaust DATA."
        ),
        "cases": {},
    }
    for name, case in CASES.items():
        values = case["rolls"]
        if not values or any(not 1 <= value <= 6 for value in values):
            raise ValueError(f"Invalid prescribed die values: {name}")
        probe = source.replace("BR_FACE=Rnd(5)+1", "Read BR_FACE").replace(
            "   BR_BANKED=0\n", "   BR_BANKED=0\n   Restore\n"
        )
        probe += "\nData " + ",".join(map(str, values)) + "\n"
        path = destination / f"{name}.asc"
        path.write_text(probe)
        manifest["cases"][name] = {
            **case,
            "file": path.name,
            "sha256": hashlib.sha256(probe.encode()).hexdigest(),
        }
    (destination / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    print(f"Prepared {len(CASES)} native fixtures. No AMOS execution claimed.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("destination", type=Path)
    prepare(parser.parse_args().destination)
