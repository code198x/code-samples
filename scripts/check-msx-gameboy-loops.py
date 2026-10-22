"""Independently decode retained state, video writes and native-frame evidence."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "png", ROOT / "scripts/verify-sega-turns.py"
)
PNG = importlib.util.module_from_spec(spec)
spec.loader.exec_module(PNG)
ROUTES = [("msx", "basic"), ("msx", "assembly"), ("nintendo-game-boy", "assembly")]


def require(value: bool, message: str) -> None:
    if not value:
        raise ValueError(message)


def bound(root: Path, name: str, digest: str) -> Path:
    p = (root / name).resolve()
    require(
        p.is_relative_to(root.resolve()) and p.is_file(), "Missing/outside evidence"
    )
    require(
        hashlib.sha256(p.read_bytes()).hexdigest() == digest,
        f"Changed evidence: {name}",
    )
    return p


def check_record(root: Path, r: dict) -> None:
    require(r["status"] == "passed", "Incomplete native run")
    require((r["system"], r["track"]) in ROUTES, "Unknown machine/language route")
    asm = r["track"] == "assembly"
    gb = r["system"] == "nintendo-game-boy"
    required = (
        {"working", "step-three", "wrong-reset", "repaired", "wrap", "nonzero"}
        | ({"no-edge"} if asm else set())
        | ({"no-wait"} if gb else set())
    )
    require(set(r["cases"]) == required, "Missing cases")
    for section in ("sources", "observer_sources"):
        require(bool(r[section]), "Missing source bindings")
        for name, digest in r[section].items():
            bound(root, name, digest)
    for key, version in [
        ("producer_source_lock", "0.44.1"),
        ("assembler_source_lock", "0.0.71"),
    ]:
        p = r[key]
        require(
            p["version"] == version
            and p["before_lock_sha256"]
            == p["after_lock_sha256"]
            == p["committed_lock_sha256"],
            "Unqualified producer",
        )
    parity = {}
    for variant, case in r["cases"].items():
        obs = case["observations"]
        require(
            [o["stage"] for o in obs]
            == ["initial", "idle", "first", "held", "ignored", "second"],
            "Missing/reordered observation",
        )
        initial = 254 if variant == "wrap" else 100 if variant == "nonzero" else 0
        step = 3 if variant == "step-three" else 255 if variant == "nonzero" else 1
        expected = [
            initial,
            initial,
            (initial + step) % 256,
            (initial + step) % 256,
            (initial + step) % 256,
            (initial + 2 * step) % 256,
        ]
        if variant == "wrong-reset":
            expected = [0] * 6
        actual = []
        for o in obs:
            raw = o["memory"]
            require(
                bool(raw) and all(type(v) is int and 0 <= v <= 255 for v in raw),
                "Invalid observed bytes",
            )
            if asm:
                require(len(raw) == (4 if gb else 1), "Missing caller context")
                count = raw[0]
                if gb:
                    require(
                        o["ticks"] == raw[2] + 256 * raw[3],
                        "Claimed clock differs from actual context",
                    )
            else:
                require(len(raw) == 960, "Missing actual VPEEK screen readback")
                matches = re.findall(
                    r"TURN\s*(\d+)", "".join(chr(v & 127) for v in raw), re.IGNORECASE
                )
                require(len(matches) == 1, "Missing displayed count")
                count = int(matches[0])
            require(
                count == o["count"], "Claimed count differs from actual observation"
            )
            actual.append(count)
            image = bound(root, o["capture"], o["capture_sha256"])
            if gb and variant not in ("no-edge", "no-wait"):
                key = count % 2
                frame = PNG.raster(image)
                if key in parity:
                    require(
                        frame == parity[key],
                        "Visible palette disagrees with count parity",
                    )
                else:
                    parity[key] = frame
        if variant == "no-edge":
            require(
                actual != [0, 0, 1, 1, 1, 2],
                "Disabled edge detection passed normal guard",
            )
        else:
            require(
                actual == expected, f"{variant}: wrong independently decoded sequence"
            )
        if asm:
            payload = bytes(case["loaded_bytes"])
            require(len(payload) == (32768 if gb else 164), "Wrong native payload size")
            require(
                hashlib.sha256(payload).hexdigest() == case["loaded_sha256"],
                "Changed loaded bytes",
            )
            if gb:
                delta = (obs[1]["ticks"] - obs[0]["ticks"]) % 65536
                require(
                    not 118 <= delta <= 122
                    if variant == "no-wait"
                    else 118 <= delta <= 122,
                    "Display-service rate guard disagrees",
                )
            else:
                require(
                    re.search(
                        r"RETURNED\s*5",
                        "".join(chr(v & 127) for v in case["returned_screen"]),
                        re.IGNORECASE,
                    )
                    is not None,
                    "No working BASIC after USR",
                )
                require(
                    set(case["io_traces"]) == {"first", "second"},
                    "Missing actual video-write trace",
                )
                if variant != "no-edge":
                    for stage in ["first", "second"]:
                        trace = case["io_traces"][stage]
                        require(
                            trace["sample_limit"] == 4096 and trace["frames"] == 1,
                            "Changed native trace scope",
                        )
                        events = trace["events"]
                        writes = bytes(
                            int(e["value"][1:], 16)
                            for e in events
                            if e["dir"] == "out" and e["port"] == "$0098"
                        )
                        count = next(o["count"] for o in obs if o["stage"] == stage)
                        require(
                            writes == f"TURN ${count:02X}".encode(),
                            "Actual VDP writes disagree with rule state",
                        )
                        address = [
                            int(e["value"][1:], 16)
                            for e in events
                            if e["dir"] == "out" and e["port"] == "$0099"
                        ]
                        require(
                            address == [0, 64],
                            "Video write did not target SCREEN 0 name-table start",
                        )
    if gb:
        require(
            set(parity) == {0, 1} and parity[0] != parity[1], "No actual palette change"
        )


def check(root: Path) -> int:
    inventory = json.loads((root / "docs/msx-gameboy-loops.json").read_text())
    require(
        set(inventory["routes"]) == {s + "/" + t for s, t in ROUTES},
        "Missing inventory route",
    )
    for system, track in ROUTES:
        record = f"{system}/patterns/{track}/framework/command-loop/verification/reusable-results.json"
        path = bound(
            root, record, inventory["routes"][system + "/" + track]["record_sha256"]
        )
        check_record(root, json.loads(path.read_text()))
    return len(ROUTES)


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--root", type=Path, default=ROOT)
    a = p.parse_args()
    print("PASS", check(a.root.resolve()), "independent language routes")


if __name__ == "__main__":
    main()
