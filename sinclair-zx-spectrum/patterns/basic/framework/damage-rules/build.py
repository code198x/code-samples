from pathlib import Path

p = Path(__file__).parent
out = p / "build"
out.mkdir(exist_ok=True)
for name in ["demo", "custom", "wrong", "repaired"]:
    lines = (p / (name + ".bas")).read_text().splitlines() + (
        p / "routines.bas"
    ).read_text().splitlines()
    numbers = [int(line.split()[0]) for line in lines]
    if len(numbers) != len(set(numbers)):
        raise ValueError("Duplicate BASIC line numbers")
    (out / (name + ".bas")).write_text(
        "\n".join(sorted(lines, key=lambda s: int(s.split()[0]))) + "\n"
    )
