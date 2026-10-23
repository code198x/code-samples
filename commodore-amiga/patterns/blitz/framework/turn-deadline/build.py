"""Combine maintained ASCII modules for entry into original Ted."""

from pathlib import Path

ROOT = Path(__file__).resolve().parent
VARIANTS = ("working", "custom", "wrong", "repaired", "boundaries", "wrong-boundary")


def program(variant: str) -> str:
    if variant in {"boundaries", "wrong-boundary"}:
        helper = (ROOT / "routines.bb2").read_text()
        if variant == "wrong-boundary":
            marker = "If PL_dl_left.l<=0"
            if helper.count(marker) != 1:
                raise ValueError("Ambiguous exact-expiry mutation")
            helper = helper.replace(marker, "If PL_dl_left.l<0")
        return (ROOT / "boundaries.bb2").read_text() + helper
    if variant not in VARIANTS:
        raise ValueError("Unknown variant")
    caller = "customise.bb2" if variant == "custom" else "caller.bb2"
    clock = "mistakes/reset-baseline.bb2" if variant == "wrong" else "clock.bb2"
    return "".join(
        p.read_text()
        for p in [
            ROOT / caller,
            ROOT / "routines.bb2",
            ROOT / clock,
            ROOT / "input.bb2",
            ROOT / "monitor.bb2",
            ROOT / "../command-loop/routines.bb2",
        ]
    )


if __name__ == "__main__":
    out = ROOT / "build"
    out.mkdir(exist_ok=True)
    for variant in VARIANTS:
        (out / (variant + ".asc")).write_text(program(variant))
