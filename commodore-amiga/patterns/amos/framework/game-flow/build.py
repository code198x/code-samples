"""Combine ASCII game-flow source for original AMOS Professional import."""
import importlib.util
from pathlib import Path

F = Path(__file__).resolve().parent
VARIANTS = ("small", "working", "custom", "wrong", "repaired", "cases", "extremes")
def program(name: str) -> str:
    if name not in VARIANTS:
        raise ValueError(name)
    if name == "extremes":
        # DATA never contains positive2147483648 or the ambiguous minimum literal.
        data = "Data -2147483647,15,0\n" + "".join("Data " + str(state) + ",-2147483647,1\n" for state in range(4))
        return (F / "extremes.amos").read_text() + data + (F / "routines.amos").read_text()
    if name == "cases":
        spec = importlib.util.spec_from_file_location("flow_oracle", F / "oracle.py")
        if spec is None or spec.loader is None:
            raise RuntimeError("Missing maintained game-flow oracle")
        oracle = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(oracle)
        rows = oracle.cases()
        observer = (F / "observer.amos").read_text()
        for token, value in {"__BANK_SIZE__": len(oracle.packet()),
                             "__LAST_CASE__": len(rows) - 1,
                             "__PAYLOAD_BYTES__": len(rows) * oracle.RECORD_BYTES,
                             "__CASE_COUNT__": len(rows)}.items():
            if observer.count(token) != 1:
                raise ValueError("Observer anchor missing: " + token)
            observer = observer.replace(token, str(value))
        data = "".join("Data " + ",".join(map(str, row)) + "\n" for row in rows)
        return observer + data + (F / "routines.amos").read_text()
    settings = (F / ("custom.amos" if name == "custom" else "settings.amos")).read_text()
    caller = (F / "caller.amos").read_text()
    if name in {"wrong", "repaired"}:
        needle = "   If PL_GF_FRESH<>0\n"
        if caller.count(needle) != 1:
            raise ValueError("Session-reset fault must identify exactly one owner decision")
        caller = caller.replace(needle, "   " + (F / (name + ".amos")).read_text())
    return settings + caller + (F / "routines.amos").read_text()
if __name__ == "__main__":
    dest = F / "build"
    dest.mkdir(exist_ok=True)
    for name in VARIANTS:
        (dest / (name + ".asc")).write_text(program(name), encoding="ascii")
    (dest / "demo.asc").write_text(program("small"), encoding="ascii")
