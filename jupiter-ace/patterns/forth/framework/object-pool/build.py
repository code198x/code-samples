"""Combine bounded Ace source imports; execution is through the original ROM."""

from pathlib import Path

F = Path(__file__).resolve().parent
VARIANTS = ("working", "custom", "single", "wrong", "repaired")


def program(name: str) -> str:
    if name not in VARIANTS:
        raise ValueError(name)
    setting = (
        "customise.fth"
        if name == "custom"
        else "single.fth"
        if name == "single"
        else "settings.fth"
    )
    text = "".join(
        (F / path).read_text()
        for path in ("routines.fth", "storage.fth", "caller.fth", setting)
    )
    demo = (F / "demo.fth").read_text()
    if demo.count("0 PREL DROP") != 1:
        raise ValueError("Release fault must identify one owner decision")
    if name == "wrong":
        demo = demo.replace(
            "0 PREL DROP", (F / "mistakes/omit-release.fth").read_text().strip()
        )
    return text + demo


if __name__ == "__main__":
    out = F / "build"
    out.mkdir(exist_ok=True)
    for name in VARIANTS:
        (out / (name + ".fth")).write_text(program(name), encoding="ascii")
    (out / "demo.fth").write_text(program("working"), encoding="ascii")
