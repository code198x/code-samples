"""Qualify turn progression separately from an optional frame-based deadline.

Native cartridge reset, real input, memory observations and frame captures.
Negative controls remove the wait or button edge detection in assembled ROMs.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import shutil
import struct
import subprocess
import zlib
from pathlib import Path

spec = importlib.util.spec_from_file_location(
    "loop_transport", Path(__file__).with_name("verify-game-loops.py")
)
transport = importlib.util.module_from_spec(spec)
spec.loader.exec_module(transport)
Machine, require, sha = transport.Machine, transport.require, transport.sha
evidence_spec = importlib.util.spec_from_file_location(
    "turn_evidence_bytes", Path(__file__).with_name("evidence_bytes.py")
)
E = importlib.util.module_from_spec(evidence_spec)
evidence_spec.loader.exec_module(E)
ROOT = Path(__file__).resolve().parents[1]
SYSTEMS = {
    "sega-master-system": "sms",
    "sega-game-gear": "gg",
    "sega-sg-1000": "sg",
}


def raster(path: Path) -> tuple[bytes, bytes]:
    """Compare PNG raster streams, excluding metadata and compression choices."""
    data = path.read_bytes()
    require(data[:8] == b"\x89PNG\r\n\x1a\n", "Capture is not PNG")
    pos, header, chunks = 8, b"", []
    while pos < len(data):
        size = struct.unpack_from(">I", data, pos)[0]
        kind, payload = data[pos + 4 : pos + 8], data[pos + 8 : pos + 8 + size]
        if kind == b"IHDR":
            header = payload
        if kind == b"IDAT":
            chunks.append(payload)
        pos += size + 12
    require(bool(header) and bool(chunks), "Capture has no raster")
    return header, zlib.decompress(b"".join(chunks))


NEGATIVES = [
    ("no-wait", "    call wait_frame", "    nop\n    nop\n    nop"),
    ("no-edge", "    and c\n    ld b,a", "    ld a,c\n    ld b,a"),
]


def build(system: str, assembler: str, output: Path) -> dict[str, Path]:
    """Assemble the caller and its no-wait and no-edge negatives, without the emulator.

    Returns each program the machine is given, by the name the record keeps.
    """
    folder = ROOT / system / "patterns/assembly/framework/turn-deadline"
    subprocess.run(
        ["make", "-B", "ASM198X=" + assembler],
        cwd=folder,
        check=True,
        timeout=30,
        capture_output=True,
    )
    output.mkdir(parents=True, exist_ok=True)
    extension = SYSTEMS[system]
    programs = {f"demo.{extension}": folder / f"build/demo.{extension}"}
    source = (folder / "demo.asm").read_text()
    for control, old, new in NEGATIVES:
        require(source.count(old) == 1, f"Ambiguous mutation: {control}")
        mutant = folder / "negative-control.asm"
        mutant.write_text(source.replace(old, new))
        cart = output / f"{control}.{extension}"
        try:
            subprocess.run(
                [
                    assembler,
                    "--dialect",
                    "pasmo",
                    "--cpu",
                    "z80",
                    str(mutant),
                    "-o",
                    str(cart),
                ],
                cwd=folder,
                check=True,
                capture_output=True,
                timeout=30,
            )
            subprocess.run(
                ["python3", str(ROOT / "scripts/build-sega-probe.py"), str(cart)],
                check=True,
                timeout=30,
            )
        finally:
            mutant.unlink()
        programs[cart.name] = cart
    return programs


def build_programs(system: str, assembler: str, output: str) -> None:
    """Write the caller and both negatives into output, without the emulator."""
    out = Path(output).resolve()
    for name, path in build(system, assembler, out).items():
        if path != out / name:
            shutil.copyfile(path, out / name)


def qualify(system: str, native: Path, assembler: str = "asm198x") -> dict:
    folder = ROOT / system / "patterns/assembly/framework/turn-deadline"
    executable = native / f"emu198x-{system}"
    output = folder / "build/verification"
    programs = build(system, assembler, output)
    binary = programs[f"demo.{SYSTEMS[system]}"]
    machine = Machine([str(executable), "--mcp", "--cart", str(binary)])

    def state() -> dict:
        b = machine.call("memory_read", addr=0xC000, len=8)["bytes"]
        return {
            "turns": b[0] + 256 * b[1],
            "ticks": b[2] + 256 * b[3],
            "remaining": b[4],
            "timed": b[5],
            "previous": b[6],
            "expiries": b[7],
        }

    def frames(n: int) -> None:
        machine.call("run_frames", frames=n)

    def button(name: str, pressed: bool, n: int = 2) -> None:
        machine.call(
            "input", events=[{"Button": {"port": 1, "name": name, "pressed": pressed}}]
        )
        frames(n)

    def capture(name: str) -> None:
        machine.call("save_screenshot", path=str(output / name))

    try:
        frames(8)
        before = state()
        frames(120)
        idle = state()
        require(
            before == idle and idle["turns"] == idle["ticks"] == 0,
            f"Untimed idle advanced state: {before} -> {idle}",
        )
        capture("untimed-even.png")
        button("button1", True)
        pressed = state()
        require(pressed["turns"] == 1, f"Press did not commit one turn: {pressed}")
        capture("untimed-odd.png")
        frames(30)
        held = state()
        require(held == pressed, f"Held action repeated: {pressed} -> {held}")
        button("button1", False)
        button("button1", True)
        require(state()["turns"] == 2, "Second distinct press did not commit a turn")
        button("button1", False)
        button("button2", True)
        button("button2", False)
        start = state()
        require(start["timed"] == 1, "Button 2 failed to enable deadline")
        frames(30)
        after = state()
        delta = (after["ticks"] - start["ticks"]) & 65535
        transport.normal_rate(delta, 30)
        require(
            after["turns"] == start["turns"]
            and after["remaining"] < start["remaining"],
            f"Countdown did not run independently: {start} -> {after}",
        )
        require(
            after["remaining"] == start["remaining"] - delta,
            "Countdown and accepted clock disagree",
        )
        frames(after["remaining"] - 2)
        near_expiry = state()
        require(
            near_expiry["turns"] == start["turns"] and near_expiry["expiries"] == 0,
            "Turn expired before its deadline",
        )
        frames(4)
        expired = state()
        require(
            expired["turns"] == start["turns"] + 1 and expired["expiries"] == 1,
            f"Deadline failed to end one turn without an action: {expired}",
        )
        button("button1", True)
        action = state()
        require(
            action["turns"] == expired["turns"] + 1 and action["remaining"] >= 116,
            f"Action failed to restart deadline: {action}",
        )
        button("button1", False)
        button("button2", True)
        button("button2", False)
        stopped = state()
        frames(150)
        require(
            state() == stopped and stopped["timed"] == 0,
            "Disabling timer failed to stop deadline",
        )
        capture("untimed-again.png")
        even_header, even_raster = raster(output / "untimed-even.png")
        odd_header, odd_raster = raster(output / "untimed-odd.png")
        again_header, again_raster = raster(output / "untimed-again.png")
        require(even_header == odd_header == again_header, "Capture geometry changed")
        require(
            even_raster != odd_raster and again_raster == even_raster,
            "Turn action did not change and restore visible feedback",
        )
        result = {
            "status": "passed",
            "machine_id": system,
            "startup": "32 KiB homebrew cartridge, reset, default model; no firmware",
            "server": machine.server.get("serverInfo"),
            "untimed_idle_frames": 120,
            "held_frames_without_repeat": 30,
            "normal_ticks_in_30_frames": delta,
            "countdown_before": start,
            "countdown_after": after,
            "expired_without_input": expired,
            "action_restarts_deadline": action,
            "timer_disabled_frames": 150,
            "visible_feedback": {
                "changed_after_action": True,
                "restored_after_even_turns": True,
                "width": int.from_bytes(even_header[:4], "big"),
                "height": int.from_bytes(even_header[4:8], "big"),
                "raster_sha256": {
                    "even": hashlib.sha256(even_raster).hexdigest(),
                    "odd": hashlib.sha256(odd_raster).hexdigest(),
                },
            },
            "limits": "Default-model emulator evidence; polling collapses missed frame announcements. A deadline is 120 accepted ticks, not a universal two seconds. No original hardware, rendered tile/sprite path or whole-emulator claim.",
            "emulator_sha256": sha(executable),
            "binary_sha256": sha(binary),
            "assembler_sha256": sha(Path(shutil.which(assembler) or assembler)),
            # Each program the machine is given, so the checker can rebuild it.
            "programs": {name: sha(path) for name, path in programs.items()},
            "tools": {
                "assembler": E.tool_identity(assembler),
                "emulator": E.tool_identity(executable),
            },
            "sources_sha256": {
                str(p.relative_to(ROOT)): sha(p)
                for p in [
                    folder / "demo.asm",
                    folder / "frame.inc",
                    folder / "Makefile",
                    ROOT / "cross-platform/assembly/framework/turn-deadline/turn.inc",
                    ROOT / "scripts/build-sega-probe.py",
                    Path(__file__),
                    ROOT / "scripts/verify-game-loops.py",
                ]
            },
        }
        machine.close()
        controls = {}
        for control, _, _ in NEGATIVES:
            cart = programs[f"{control}.{SYSTEMS[system]}"]
            machine = Machine([str(executable), "--mcp", "--cart", str(cart)])
            frames(8)
            if control == "no-wait":
                button("button2", True, 1)
                button("button2", False, 1)
                first = state()["ticks"]
                frames(10)
                count = (state()["ticks"] - first) & 65535
                try:
                    transport.normal_rate(count, 10)
                except AssertionError:
                    rejected = True
                else:
                    rejected = False
                require(rejected, "Unpaced ROM passed normal-rate guard")
            else:
                button("button1", True, 1)
                first = state()["turns"]
                frames(30)
                count = (state()["turns"] - first) & 65535
                rejected = count != 0
                require(rejected, "Missing edge detector passed held-action guard")
            controls[control] = {"rejected": rejected, "observed_delta": count}
            machine.close()
        result["negative_controls"] = controls
        (output / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        return result
    finally:
        if machine.process.poll() is None:
            machine.close()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument("--assembler", default="asm198x")
    parser.add_argument("--only", choices=SYSTEMS)
    args = parser.parse_args()
    for system in [args.only] if args.only else SYSTEMS:
        result = qualify(system, args.native.resolve(), args.assembler)
        print(
            system,
            json.dumps(
                {
                    k: result[k]
                    for k in [
                        "status",
                        "normal_ticks_in_30_frames",
                        "negative_controls",
                    ]
                }
            ),
            flush=True,
        )


if __name__ == "__main__":
    main()
