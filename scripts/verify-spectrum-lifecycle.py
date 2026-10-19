"""Fresh firmware-free Spectrum rectangle and overlap checks."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "lifecycle", ROOT / "scripts/verify-sprite-lifecycle.py"
)
assert spec and spec.loader
L = importlib.util.module_from_spec(spec)
spec.loader.exec_module(L)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--assembler", default="asm198x")
    p.add_argument("--emulator", required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    inputs = argparse.Namespace(assembler=args.assembler, spectrum=args.emulator)
    cases = L.spectrum(inputs, out / "normal")
    L.require(cases == {"rectangles": 7, "overlaps": 4}, "Incomplete Spectrum workload")
    controls = {}
    for name in ["save", "order"]:
        try:
            L.spectrum(inputs, out / name, name)
        except ValueError as error:
            L.require(
                "mismatch" in str(error),
                "Control failed before its oracle: " + str(error),
            )
            controls[name] = str(error)
        else:
            raise ValueError("Broken Spectrum " + name + " escaped its output oracle")
    result = {
        "status": "passed",
        "cases": cases,
        "rejected_controls": controls,
        "observer_sha256": L.R.sha(Path(__file__)),
        "fixture_sha256": L.R.sha(ROOT / "scripts/verify-sprite-lifecycle.py"),
        "limits": "Synthetic 48K ROM, DI and uncontended CPU fixture; no ROM boot, display deadline or original-hardware claim.",
    }
    (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
