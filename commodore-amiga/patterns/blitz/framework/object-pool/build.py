"""Combine typed Blitz sources for insertion into original Ted."""

import importlib.util
from pathlib import Path

F = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("pool_oracle", F / "oracle.py")
if spec is None or spec.loader is None:
    raise RuntimeError("Missing pool oracle")
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)
boundary_spec = importlib.util.spec_from_file_location(
    "pool_boundary", F / "boundary_oracle.py"
)
age_spec = importlib.util.spec_from_file_location("pool_age", F / "age_oracle.py")
if (
    boundary_spec is None
    or boundary_spec.loader is None
    or age_spec is None
    or age_spec.loader is None
):
    raise RuntimeError("Missing domain or lifetime oracle")
D = importlib.util.module_from_spec(boundary_spec)
boundary_spec.loader.exec_module(D)
L = importlib.util.module_from_spec(age_spec)
age_spec.loader.exec_module(L)
VARIANTS = (
    "small",
    "working",
    "custom",
    "single",
    "wrong",
    "repaired",
    "cases",
    "wrong-cases",
    "repaired-cases",
    "boundaries",
    "extremes",
    "age",
)


def program(name: str) -> str:
    if name not in VARIANTS:
        raise ValueError("Unknown variant: " + name)
    if name == "age":
        return (F / "age.bb2").read_text() + (F / "routines.bb2").read_text()
    if name in {"boundaries", "extremes"}:
        extreme = name == "extremes"
        caller = (F / "boundaries.bb2").read_text()
        size = len(D.packet(extreme))
        for anchor, value in {
            "__BANK_SIZE__": str(size),
            "__PAYLOAD_BYTES__": str(size - 8),
            "__DONE_OFFSET__": str(size - 4),
            "__LAST_CASE__": str(len(D.cases(extreme)) - 1),
            "__CASE_COUNT__": str(len(D.cases(extreme))),
            "__DATA__": D.data(extreme).rstrip("\n"),
        }.items():
            if caller.count(anchor) != 1:
                raise ValueError("Missing or duplicate domain anchor: " + anchor)
            caller = caller.replace(anchor, value)
        return caller + (F / "routines.bb2").read_text()
    if name in {"cases", "wrong-cases", "repaired-cases"}:
        caller = (F / "observer.bb2").read_text()
        for anchor, value in {
            "__BANK_SIZE__": str(len(C.packet())),
            "__PAYLOAD_BYTES__": str(len(C.packet()) - 8),
            "__DONE_OFFSET__": str(len(C.packet()) - 4),
            "__RELEASE_CALL__": "; Deliberate owner fault: no release"
            if name == "wrong-cases"
            else "Gosub PL_OP_RELEASE",
        }.items():
            if caller.count(anchor) != 1:
                raise ValueError("Missing or duplicate observer anchor: " + anchor)
            caller = caller.replace(anchor, value)
        return caller + (F / "routines.bb2").read_text()
    settings = (F / ("custom.bb2" if name == "custom" else "settings.bb2")).read_text()
    if name == "single":
        settings = "PL_OP_CAP.l=1\n"
    caller = (F / "caller.bb2").read_text()
    if name in {"wrong", "repaired"}:
        anchor = "Gosub PL_OP_RELEASE\nGosub PL_OP_ACQUIRE"
        if caller.count(anchor) != 1:
            raise ValueError("Release fault must identify one owner decision")
        caller = caller.replace(anchor, (F / (name + ".bb2")).read_text().rstrip("\n"))
    return settings + caller + (F / "routines.bb2").read_text()


if __name__ == "__main__":
    out = F / "build"
    out.mkdir(exist_ok=True)
    for name in VARIANTS:
        (out / (name + ".asc")).write_text(program(name), encoding="ascii")
    (out / "demo.asc").write_text(program("small"), encoding="ascii")
