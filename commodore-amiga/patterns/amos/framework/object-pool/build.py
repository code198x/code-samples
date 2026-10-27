"""Combine maintained ASCII source for import into AMOS Professional."""
import importlib.util
from pathlib import Path
from types import ModuleType

F = Path(__file__).resolve().parent
VARIANTS = ("small", "working", "custom", "wrong", "repaired", "single", "age", "boundaries", "extremes", "cases", "wrong-cases", "repaired-cases")
def oracle_module(filename: str) -> ModuleType:
    spec = importlib.util.spec_from_file_location("pool_oracle", F / filename)
    if spec is None or spec.loader is None:
        raise RuntimeError("Missing maintained pool oracle: " + filename)
    oracle = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(oracle)
    return oracle


def program(name: str) -> str:
    if name not in VARIANTS:
        raise ValueError(name)
    if name == "extremes":
        data = "Data 1,-2147483647,4,-1,0\nData 2,4,-2147483647,-1,1\nData 3,4,-2147483647,-1,1\n"
        data += "".join("Data 3," + str(cap) + "," + str(cap) + ",-2147483647,2\n" for cap in (1, 4, 8))
        return (F / "extremes.amos").read_text() + data + (F / "routines.amos").read_text()
    if name == "age":
        return (F / "age.amos").read_text() + (F / "routines.amos").read_text()
    if name == "boundaries":
        oracle = oracle_module("boundary_oracle.py")
        rows = oracle.cases()
        observer = (F / "boundaries.amos").read_text()
        for token, value in {"__BANK_SIZE__": len(oracle.packet()),
                             "__LAST_CASE__": len(rows) - 1,
                             "__PAYLOAD_BYTES__": len(rows) * oracle.RECORD_BYTES,
                             "__CASE_COUNT__": len(rows)}.items():
            if observer.count(token) != 1:
                raise ValueError("Boundary anchor missing: " + token)
            observer = observer.replace(token, str(value))
        data = "".join("Data " + ",".join(map(str, row)) + "\n" for row in rows)
        return observer + data + (F / "routines.amos").read_text()
    if name in {"cases", "wrong-cases", "repaired-cases"}:
        oracle = oracle_module("oracle.py")
        rows = oracle.cases()
        observer = (F / "observer.amos").read_text()
        values = {"__BANK_SIZE__": len(rows) * oracle.RECORD_BYTES + len(oracle.MARKER),
                  "__LAST_CASE__": len(rows) - 1,
                  "__PAYLOAD_BYTES__": len(rows) * oracle.RECORD_BYTES,
                  "__CASE_COUNT__": len(rows), "__RECORD_BYTES__": oracle.RECORD_BYTES}
        for token, value in values.items():
            if observer.count(token) != 1:
                raise ValueError("Observer anchor missing: " + token)
            observer = observer.replace(token, str(value))
        if observer.count("__RELEASE_CALL__") != 1:
            raise ValueError("Observer release anchor missing")
        observer = observer.replace("__RELEASE_CALL__", "Rem Release omitted" if name == "wrong-cases" else "Gosub PL_OP_RELEASE")
        data = "".join("Data " + ",".join(map(str, row)) + "\n" for row in rows)
        return observer + data + (F / "routines.amos").read_text()
    settings = (F / ("custom.amos" if name == "custom" else "settings.amos")).read_text()
    if name == "single":
        settings = "PL_OP_CAP=1\n"
    caller = (F / "caller.amos").read_text()
    if name in {"wrong", "repaired"}:
        needle = "Gosub PL_OP_RELEASE\nGosub PL_OP_ACQUIRE"
        if caller.count(needle) != 1:
            raise ValueError("Release fault no longer identifies exactly one owner call")
        fragment = (F / (name + ".amos")).read_text().rstrip("\n")
        caller = caller.replace(needle, fragment)
    return settings + caller + (F / "routines.amos").read_text()
if __name__ == "__main__":
    dest = F / "build"
    dest.mkdir(exist_ok=True)
    for variant in VARIANTS:
        (dest / (variant + ".asc")).write_text(program(variant), encoding="ascii")
    (dest / "demo.asc").write_text(program("small"), encoding="ascii")
