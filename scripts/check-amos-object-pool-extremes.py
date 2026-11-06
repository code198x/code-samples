"""Check retained native pool extremes packets; other pool qualifications remain separate."""
from __future__ import annotations

import hashlib
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("pool_extremes_native", ROOT / "scripts/verify-amos-object-pool-extremes.py")
if spec is None or spec.loader is None:
    raise RuntimeError("Missing pool verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
_E = importlib.util.spec_from_file_location("amos_typed", ROOT / "scripts/evidence_bytes.py")
assert _E and _E.loader
E = importlib.util.module_from_spec(_E)
_E.loader.exec_module(E)


def check(record=None):
    r = record if record is not None else json.loads((V.V / "extremes.json").read_text())
    require = V.T.require
    require((r["system"], r["language"]) == ("commodore-amiga", "amos"), "Wrong route")
    # Imported into the AMOS runtime, so the text is the program (rule 2);
    # source and script digests are provenance only.
    cfg = json.loads((V.A.FOLDER / "verification/configuration.json").read_text())
    keys = ("emulator_sha256", "firmware_sha256", "runtime_media_sha256", "builder_sha256", "configuration", "runtime")
    require(r["configuration"] == {k: cfg[k] for k in keys}, "Changed runtime configuration")
    identities = {n: hashlib.sha256(V.B.program(n).encode("ascii")).hexdigest() for n in V.B.VARIANTS}
    require(set(r["fixture"]["programs"]) == set(identities), "Stale source fixture")
    for n in identities:
        E.require_typed(V.B.program(n).encode("ascii"), r["fixture"]["programs"][n], n + ".asc")
    fixture_hash = r["fixture"]["fixture_sha256"]
    require(len(fixture_hash) == 64 and all(c in "0123456789abcdef" for c in fixture_hash), "Invalid fixture identity")
    require(set(r["cases"]) == {"extremes"}, "Missing native packet variant")
    normal = V.C.packet()
    require(len(V.C.cases()) == 6 and len(normal) == 652, "Incomplete independent model")
    for name, case in r["cases"].items():
        expected = normal
        raw = bytes(case["packet"])
        require(raw == expected, "Native integer packet differs")
        require(hashlib.sha256(raw).hexdigest() == case["packet_sha256"], "Changed packet digest")
        require(case["case_count"] == 6 and case["record_bytes"] == 108 and case["allocated_observer_bytes"] == len(expected), "Wrong completion/allocation")
        require(case["program_sha256"] == identities[name], "Wrong imported program")
        require(case["server"]["version"] == "0.44.1", "Wrong native producer")
        require(0 < case["bank_address"] < 2 * 1024 * 1024 - len(expected), "Invalid observer address")
        require(case["image"] == name + ".png", "Wrong native capture")
        image = V.V / case["image"]
        require(V.T.sha(image) == case["image_sha256"], "Changed native capture")
        require(V.A.number(image, 420, 66, 3) == 6 and V.A.number(image, 388, 82, 2) == 0, "Native completion pixels differ")
        require(V.A.number(image, 388, 98) == case["bank_address"] and V.A.number(image, 388, 114) == len(expected), "Native allocation pixels differ")


if __name__ == "__main__":
    check()
    print("AMOS pool extremes: all native records, full arrays and pixels passed")
