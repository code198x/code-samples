"""Show why injection completion must not stand in for FORTH compilation."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "transport", ROOT / "scripts/verify-game-loops.py"
)
T = importlib.util.module_from_spec(spec)
spec.loader.exec_module(T)
F = ROOT / "jupiter-ace/patterns/assembly/framework/turn-deadline"


def run(executable: Path, firmware: Path) -> dict:
    m = T.Machine([str(executable), "--mcp", "--rom", str(firmware)])
    try:
        m.call("run_frames", frames=150)
        for line in (
            "DECIMAL",
            ": RESERVE HERE 15616 > IF ABORT THEN 15616 HERE - ALLOT ;",
            "RESERVE",
        ):
            r = m.call("type_string", text=line + "\n", hold_frames=3, settle_frames=28)
            T.require(r["chars_typed"] == len(line) + 1, "Incomplete setup text")
        expected = [245, 197, 213, 229, 175, 50, 81, 62]
        line = " ".join(f"{n} C," for n in expected) + "\n"
        r = m.call("type_string", text=line, hold_frames=3, settle_frames=8)
        early = m.call("memory_read", addr=15616, len=8)["bytes"]
        early_pointers = m.call("memory_read", addr=15415, len=6)["bytes"]
        T.require(r["chars_typed"] == len(line), "Injection incomplete")
        T.require(early != expected, "Early-read negative control no longer reproduces")
        for waited in range(201):
            pointers = m.call("memory_read", addr=15415, len=6)["bytes"]
            here = int.from_bytes(bytes(pointers[:2]), "little")
            spare = int.from_bytes(bytes(pointers[4:6]), "little")
            if here == 15624 and spare == here + 12:
                break
            m.call("run_frames", frames=1)
        final = m.call("memory_read", addr=15616, len=8)["bytes"]
        T.require(
            final == expected and here == 15624 and spare == here + 12,
            "Waiting for interpreter did not complete exact payload",
        )
        return {
            "injection": r,
            "early": early,
            "early_pointers": early_pointers,
            "completed": final,
            "completed_pointers": pointers,
            "waited_frames": waited,
            "server": m.server["serverInfo"],
            "executable_sha256": T.sha(executable),
            "firmware_sha256": T.sha(firmware),
        }
    finally:
        m.close()


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--emulator", type=Path, required=True)
    p.add_argument("--firmware", type=Path, required=True)
    a = p.parse_args()
    r = run(a.emulator, a.firmware)
    r["sources"] = {
        str(p.relative_to(ROOT)): T.sha(p)
        for p in (Path(__file__), ROOT / "scripts/verify-game-loops.py")
    }
    (F / "verification/loader-regression.json").write_text(
        json.dumps(r, indent=2) + "\n"
    )
    print(
        "Same boot: early-read guard rejects incomplete bytes, then compilation produces exact payload",
        r["waited_frames"],
    )
