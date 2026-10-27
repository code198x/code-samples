"""Check retained native occupancy packets; other pool qualifications remain separate."""
from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("pool_native", ROOT / "scripts/verify-amos-object-pool.py")
if spec is None or spec.loader is None:
    raise RuntimeError("Missing pool verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)


def check(record=None, callers=None):
    r = record if record is not None else json.loads((V.V / "packets.json").read_text())
    require = V.T.require
    require((r["system"], r["language"]) == ("commodore-amiga", "amos"), "Wrong route")
    require(r["sources"] == {str(p.relative_to(ROOT)): V.T.sha(p) for p in V.source_paths()}, "Changed source/observer")
    cfg = json.loads((V.A.FOLDER / "verification/configuration.json").read_text())
    keys = ("emulator_sha256", "firmware_sha256", "runtime_media_sha256", "builder_sha256", "configuration", "runtime")
    require(r["configuration"] == {k: cfg[k] for k in keys}, "Changed runtime configuration")
    identities = {n: hashlib.sha256(V.B.program(n).encode("ascii")).hexdigest() for n in V.B.VARIANTS}
    require(r["fixture"]["programs"] == identities, "Stale source fixture")
    fixture_hash = r["fixture"]["fixture_sha256"]
    require(len(fixture_hash) == 64 and all(c in "0123456789abcdef" for c in fixture_hash), "Invalid fixture identity")
    require(set(r["cases"]) == {"cases", "wrong-cases", "repaired-cases"}, "Missing native packet variant")
    normal = V.C.packet(False)
    broken = V.C.packet(True)
    require(len(V.C.cases()) == 768 and len(normal) == 190468 and normal != broken, "Incomplete independent model")
    for name, case in r["cases"].items():
        expected = broken if name == "wrong-cases" else normal
        raw = bytes(case["packet"])
        require(raw == expected, "Native integer packet differs")
        require(hashlib.sha256(raw).hexdigest() == case["packet_sha256"], "Changed packet digest")
        require(case["case_count"] == 768 and case["record_bytes"] == 248 and case["allocated_observer_bytes"] == len(expected), "Wrong completion/allocation")
        require(case["program_sha256"] == identities[name], "Wrong imported program")
        require(case["server"]["version"] == "0.44.1", "Wrong native producer")
        require(0 < case["bank_address"] < 2 * 1024 * 1024 - len(expected), "Invalid observer address")
        require(case["image"] == name + ".png", "Wrong native capture")
        image = V.V / case["image"]
        require(V.T.sha(image) == case["image_sha256"], "Changed native capture")
        require(V.A.number(image, 420, 66, 3) == 768 and V.A.number(image, 388, 82, 2) == 0, "Native completion pixels differ")
        require(V.A.number(image, 388, 98) == case["bank_address"] and V.A.number(image, 388, 114) == len(expected), "Native allocation pixels differ")
    require(identities["cases"] == identities["repaired-cases"] != identities["wrong-cases"], "Fault/repair source identity differs")


    owner = V.module("pool_owner", ROOT / "scripts/verify-amos-object-pool-callers.py")
    trace = callers if callers is not None else json.loads((V.V / "callers.json").read_text())
    require(trace["sources"] == {str(p.relative_to(ROOT)): V.T.sha(p) for p in V.source_paths() + [ROOT / "scripts/verify-amos-object-pool-callers.py"]}, "Changed owner source")
    require(trace["configuration"] == cfg and trace["fixture"] == r["fixture"], "Changed owner configuration/fixture")
    require(set(trace["cases"]) == {"small", "working", "custom", "single", "wrong", "repaired"}, "Missing native owner variant")
    for name, case in trace["cases"].items():
        require(case["program_sha256"] == identities[name] and case["server"]["version"] == "0.44.1", "Wrong owner import/producer")
        require(case["outputs"] == owner.expected(name), "Native pool allocation/reuse differs")
        require(case["image"] == "caller-" + name + ".png", "Wrong owner capture")
        image = V.V / case["image"]
        require(V.T.sha(image) == case["image_sha256"], "Changed owner capture")
        capacity = owner.expected(name)[0]
        positions = [(676, 50)] + [(x, 66 + slot * 16) for slot in range(capacity + 1) for x in (388, 804)]
        reuse_y = 50 + (capacity + 2) * 16
        positions += [(420, reuse_y), (836, reuse_y), (484, reuse_y + 16), (836, reuse_y + 16)]
        require([V.A.number(image, x, y, 3) for x, y in positions] == case["outputs"], "Native owner pixels differ")
    require(trace["cases"]["working"]["outputs"] == trace["cases"]["repaired"]["outputs"] != trace["cases"]["wrong"]["outputs"], "Omitted-release fault/repair absent")


if __name__ == "__main__":
    check()
    print("AMOS pool occupancy: normal, omitted-release and repaired native packets and pixels passed")
