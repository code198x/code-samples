"""Combine maintained ASCII modules; these are not tokenised AMOS saves."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parent


def program(variant: str) -> str:
    if variant in {"boundaries", "wrong-boundary"}:
        routines = (ROOT / "routines.amos").read_text()
        if variant == "wrong-boundary":
            marker = "If PL_DL_LEFT<=0"
            if routines.count(marker) != 1:
                raise ValueError("Ambiguous exact-boundary mutation")
            routines = routines.replace(marker, "If PL_DL_LEFT<0")
        return (ROOT / "boundaries.amos").read_text() + routines
    if variant not in {"working", "custom", "wrong", "repaired"}:
        raise ValueError("Unknown caller variant")
    caller = "customise.amos" if variant == "custom" else "caller.amos"
    clock = "mistakes/reset-baseline.amos" if variant == "wrong" else "clock.amos"
    return "".join(
        p.read_text()
        for p in [
            ROOT / caller,
            ROOT / "routines.amos",
            ROOT / clock,
            ROOT / "input.amos",
            ROOT / "monitor.amos",
            ROOT / "../command-loop/routines.amos",
        ]
    )


if __name__ == "__main__":
    out = ROOT / "build"
    out.mkdir(exist_ok=True)
    for variant in [
        "working",
        "custom",
        "wrong",
        "repaired",
        "boundaries",
        "wrong-boundary",
    ]:
        (out / f"{variant}.asc").write_text(program(variant))
