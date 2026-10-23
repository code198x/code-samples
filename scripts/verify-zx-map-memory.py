"""Measure actual ROM storage and execute separately qualified compact maps."""

from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "zx_base", ROOT / "scripts/verify-zx-basic-map.py"
)
assert SPEC and SPEC.loader
V = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(V)
T = V.T


class Keyboard(V.Keyboard):
    def expression(self, text: str) -> None:
        for word, key in [("CODE ", "i"), ("CHR$ ", "u")]:
            if self.system.endswith("81") and word in text:
                a, b = text.split(word, 1)
                super().expression(a)
                self.chord("enter")
                self.key(key)
                self.expression(b)
                return
        super().expression(text)

    def line(self, text: str) -> None:
        # Keep the original observer immutable. Its records remain valid.
        super().line(text)
        if self.system.endswith("80"):
            self.machine.call("run_frames", frames=150)

    def command(self, text: str, frames: int = 600) -> None:
        self.statement(text)
        self.key("enter")
        self.machine.call("run_frames", frames=frames)


def word(raw: list, offset: int) -> int:
    return int.from_bytes(bytes(raw[offset : offset + 2]), "little")


def program(machine: object, system: str) -> tuple[list, list]:
    start = 16424 if system.endswith("80") else 16509
    end = word(V.read(machine, 16384, 40), 8 if system.endswith("80") else 12)
    raw = V.read(machine, start, end - start)
    lines = []
    pos = 0
    while pos < len(raw):
        n = int.from_bytes(bytes(raw[pos : pos + 2]), "big")
        if system.endswith("80"):
            size = raw.index(118, pos + 2) - pos + 1
        else:
            size = 4 + word(raw, pos + 2)
        T.require(
            size > 2 and pos + size <= len(raw), "Invalid stored program boundary"
        )
        lines.append({"number": n, "bytes": size})
        pos += size
    return raw, lines


def snapshot(machine: object, system: str, ram: int, label: str) -> dict:
    raw = V.read(machine, 16384, 125 if system.endswith("81") else 40)
    cpu = machine.call("query_cpu")["registers"]
    sp = int(cpu["sp"].lstrip("$"), 16)
    if system.endswith("80"):
        pointers = {
            k: word(raw, o)
            for k, o in [
                ("vars", 8),
                ("e_line", 10),
                ("d_file", 12),
                ("df_ea", 14),
                ("df_end", 16),
            ]
        }
        frontier = pointers["df_end"]
    else:
        pointers = {
            k: word(raw, o)
            for k, o in [
                ("ramtop", 4),
                ("d_file", 12),
                ("vars", 16),
                ("e_line", 20),
                ("stkbot", 26),
                ("stkend", 28),
            ]
        }
        frontier = pointers["stkend"]
    return {
        "label": label,
        "system_hex": bytes(raw).hex(),
        "pointers": pointers,
        "cpu": cpu,
        "frontier": frontier,
        "sp": sp,
        "observed_gap": sp - frontier,
        "ram_bytes": ram,
    }


def boot(system: str, native: Path, ram: int) -> tuple:
    rom = (
        Path.home()
        / ".emu198x/roms"
        / system
        / ("zx80.rom" if system.endswith("80") else "zx81.rom")
    )
    exe = native / ("emu198x-" + system)
    m = T.Machine([str(exe), "--mcp", "--rom", str(rom), "--ram-bytes", str(ram)])
    m.call("run_frames", frames=150)
    return (
        m,
        Keyboard(m, system),
        {"emulator_sha256": T.sha(exe), "firmware_sha256": T.sha(rom)},
    )


def screen(machine: object, system: str) -> dict:
    rawsys = V.read(machine, 16384, 40)
    addr = word(rawsys, 12)
    if system.endswith("80"):
        size = word(rawsys, 16) - addr
    else:
        size = word(rawsys, 16) - addr
    raw = V.read(machine, addr, size)
    chars = {
        0: " ",
        26: ",",
        27: ".",
        118: "\n",
        **{28 + i: str(i) for i in range(10)},
        **{38 + i: chr(65 + i) for i in range(26)},
    }
    chars[18 if system.endswith("80") else 22] = "-"
    chars[21 if system.endswith("80") else 24] = "/"
    return {
        "address": addr,
        "hex": bytes(raw).hex(),
        "text": "".join(chars.get(b, "?") for b in raw),
    }


def readable(system: str, native: Path, ram: int) -> dict:
    m, k, identity = boot(system, native, ram)
    p = V.folder(system)
    out = p / "verification/memory"
    out.mkdir(exist_ok=True)
    data = {
        "machine": system,
        "ram_bytes": ram,
        "identity": identity,
        "sources": {n: T.sha(p / n) for n in ("routines.bas", "room.bas", "demo.bas")},
        "snapshots": [snapshot(m, system, ram, "boot")],
        "status": "incomplete",
    }
    try:
        entered = []
        for name in ("routines.bas", "room.bas", "demo.bas"):
            for i, line in enumerate((p / name).read_text().splitlines()):
                try:
                    k.line(line)
                except AssertionError:
                    data.update(
                        status="entry-rejected",
                        rejected_line=line,
                        screen=screen(m, system),
                    )
                    data["snapshots"].append(snapshot(m, system, ram, "entry-rejected"))
                    m.call("save_screenshot", path=str(out / f"readable-{ram}.png"))
                    return data
                entered.append(int(line.split()[0]))
                raw, actual = program(m, system)
                if [l["number"] for l in actual] != sorted(entered):
                    data.update(
                        status="entry-rejected",
                        rejected_line=line,
                        screen=screen(m, system),
                    )
                    data["snapshots"].append(snapshot(m, system, ram, "entry-rejected"))
                    m.call("save_screenshot", path=str(out / f"readable-{ram}.png"))
                    return data
                if i % 25 == 0:
                    print(system, ram, name, i, flush=True)
            data["snapshots"].append(snapshot(m, system, ram, "entered-" + name))
        data["program_hex"] = bytes(raw).hex()
        data["lines"] = actual
        data["component_bytes"] = {
            name: sum(
                l["bytes"]
                for l in actual
                if (
                    l["number"] < 1000
                    if name == "caller"
                    else 1000 <= l["number"] < 2000
                    if name == "routines"
                    else l["number"] >= 2000
                )
            )
            for name in ("routines", "initialiser", "caller")
        }
        k.key("r")
        k.key("enter")
        samples = []
        for frame in range(4000):
            m.call("run_frames", frames=1)
            samples.append(snapshot(m, system, ram, str(frame)))
            if frame % 40 == 0:
                s = screen(m, system)
                if "TILE 2" in s["text"] and "9/190" in s["text"].replace("?", "/"):
                    break
                # The report may lie in the lower area, outside upper D_FILE lines.
                if "TILE 2" in s["text"] and frame > 300:
                    break
        m.call("run_frames", frames=200)
        data["screen"] = screen(m, system)
        T.require(
            all(
                t in data["screen"]["text"]
                for t in ("TILE 3", "FLAGS 4", "CHANGED 3", "WORLD 6,4", "TILE 2")
            ),
            "Readable caller incomplete",
        )
        data["snapshots"].append(snapshot(m, system, ram, "stopped-caller"))
        data["sampled_max_frontier"] = max(s["frontier"] for s in samples)
        data["sampled_min_sp"] = min(s["sp"] for s in samples)
        data["sampled_min_gap"] = min(s["observed_gap"] for s in samples)
        data["sample_frames"] = len(samples)
        data["extrema"] = {
            key: next(s for s in samples if s[field] == data[key])
            for key, field in [
                ("sampled_max_frontier", "frontier"),
                ("sampled_min_sp", "sp"),
                ("sampled_min_gap", "observed_gap"),
            ]
        }
        data["status"] = "passed"
        m.call("save_screenshot", path=str(out / f"readable-{ram}.png"))
        return data
    finally:
        (out / f"readable-{ram}.json").write_text(json.dumps(data, indent=2) + "\n")
        m.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument("--system", choices=V.SYSTEMS, required=True)
    parser.add_argument("--ram", type=int, default=16384)
    args = parser.parse_args()
    result = readable(args.system, args.native.resolve(), args.ram)
    print(
        result["status"],
        result.get("component_bytes"),
        result.get("sampled_min_gap"),
        flush=True,
    )


if __name__ == "__main__":
    main()
