"""Combine typed game-flow sources for original Ted insertion."""

import importlib.util
from pathlib import Path

F = Path(__file__).resolve().parent
VARIANTS = ("small", "working", "custom", "wrong", "repaired", "cases-0", "cases-1", "cases-2", "cases-3", "cases-4", "cases-5")


def program(name: str) -> str:
    if name not in VARIANTS:
        raise ValueError("Unknown variant: " + name)
    if name.startswith("cases-"):
        spec = importlib.util.spec_from_file_location("blitz_flow_oracle", F / "oracle.py")
        if spec is None or spec.loader is None:
            raise RuntimeError("Missing maintained game-flow oracle")
        oracle = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(oracle)
        chunk = int(name.split("-")[1])
        rows = oracle.chunks()[chunk]
        observer = (F / "observer.bb2").read_text()
        replacements = {"__BANK_SIZE__": len(oracle.packet(chunk)), "__LAST_CASE__": len(rows) - 1,
                        "__PAYLOAD_BYTES__": len(rows) * oracle.RECORD_BYTES,
                        "__DONE_OFFSET__": len(rows) * oracle.RECORD_BYTES + len(oracle.MARKER),
                        "__CASE_COUNT__": len(rows)}
        for token, value in replacements.items():
            if observer.count(token) != 1:
                raise ValueError("Missing observer anchor: " + token)
            observer = observer.replace(token, str(value))
        data = "".join("Data.l " + ",".join(map(str, row)) + "\n" for row in rows)
        return observer + data + (F / "routines.bb2").read_text()
    settings = (F / ("custom.bb2" if name == "custom" else "settings.bb2")).read_text()
    caller = (F / "caller.bb2").read_text()
    if name in {"wrong", "repaired"}:
        anchor = "   If PL_GF_FRESH.l<>0\n"
        if caller.count(anchor) != 1:
            raise ValueError("Session-reset fault must identify one owner decision")
        caller = caller.replace(anchor, "   " + (F / (name + ".bb2")).read_text())
    return settings + caller + (F / "routines.bb2").read_text()


if __name__ == "__main__":
    out = F / "build"
    out.mkdir(exist_ok=True)
    for name in VARIANTS:
        (out / (name + ".asc")).write_text(program(name), encoding="ascii")
    (out / "demo.asc").write_text(program("small"), encoding="ascii")
