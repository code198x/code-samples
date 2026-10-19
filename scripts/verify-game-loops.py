"""Execute reusable waits using full native frames, real input and slow CPU work.

The labelled negative control replaces the frame wait with a return. The same
normal-rate guard must reject it. No original-hardware or whole-emulator claim.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import queue
import re
import subprocess
import threading
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def require(value: bool, message: str) -> None:
    if not value:
        raise AssertionError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


class Machine:
    def __init__(self, command: list[str]) -> None:
        self.process = subprocess.Popen(
            command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
        )
        self.responses: queue.Queue[dict[str, Any] | None] = queue.Queue()
        self.sequence = 0
        threading.Thread(target=self.read, daemon=True).start()
        self.server = self.rpc(
            "initialize",
            {
                "protocolVersion": "2025-06-18",
                "capabilities": {},
                "clientInfo": {"name": "pattern-callers", "version": "1"},
            },
        )

    def read(self) -> None:
        for line in self.process.stdout:
            self.responses.put(json.loads(line))
        self.responses.put(None)

    def rpc(self, method: str, params: dict) -> dict:
        self.sequence += 1
        self.process.stdin.write(
            json.dumps(
                {
                    "jsonrpc": "2.0",
                    "id": self.sequence,
                    "method": method,
                    "params": params,
                }
            )
            + "\n"
        )
        self.process.stdin.flush()
        while True:
            result = self.responses.get(timeout=60)
            if result is None:
                raise RuntimeError("Emulator exited: " + self.process.stderr.read())
            if result.get("id") == self.sequence:
                if "error" in result:
                    raise RuntimeError(result)
                return result["result"]

    def call(self, name: str, **arguments: Any) -> Any:
        result = self.rpc("tools/call", {"name": name, "arguments": arguments})
        require(not result.get("isError"), str(result))
        text = result["content"][0]["text"]
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            return text

    def close(self) -> None:
        self.process.stdin.close()
        try:
            self.process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            self.process.kill()
            self.process.wait(timeout=5)


def symbols(path: Path) -> dict[str, int]:
    return {
        key: int(value, 16)
        for key, value in re.findall(
            r"^(\w+) = (?:code\+)?\$(\w+)", path.read_text(), re.MULTILINE
        )
    }


def memory(machine: Machine, address: int, size: int = 1, big: bool = False) -> int:
    return int.from_bytes(
        bytes(machine.call("memory_read", addr=address, len=size)["bytes"]),
        "big" if big else "little",
    )


SYSTEMS = {
    "c64": "commodore-64",
    "spectrum": "sinclair-zx-spectrum",
    "amiga": "commodore-amiga",
    "nes": "nintendo-entertainment-system",
    "bbc": "bbc-micro",
}


def normal_rate(updates: int, frames: int) -> None:
    require(
        frames - 2 <= updates <= frames + 1,
        f"{updates} updates in {frames} native frames",
    )


def tape_start(args: argparse.Namespace, folder: Path, sym: dict[str, int]) -> dict:
    helper = (
        ROOT / "sinclair-zx-spectrum/basic/meet-basic/opening/verification/verify.py"
    )
    spec = importlib.util.spec_from_file_location("spectrum_transport", helper)
    transport = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(transport)
    machine = transport.Spectrum(str(args.spectrum), folder / "build/verification")
    try:
        machine.call(
            "load_media",
            slot="tape-1",
            kind="tape",
            path=str(folder / "build/demo.tap"),
        )
        machine.statement('LOAD ""')
        machine.call("media_transport", slot="tape-1", transport="start")
        machine.frames(3000)
        before = memory(machine, sym["updates"], 2)
        machine.frames(30)
        delta = (memory(machine, sym["updates"], 2) - before) & 65535
        normal_rate(delta, 30)
        machine.call(
            "save_screenshot", path=str(folder / "build/verification/tape-running.png")
        )
        return {
            "status": "passed",
            "updates_in_30_frames": delta,
            "tap_sha256": sha(folder / "build/demo.tap"),
            "transport_sha256": sha(helper),
        }
    finally:
        machine.close()


def run(name: str, args: argparse.Namespace) -> dict:
    folder = (
        ROOT
        / SYSTEMS["bbc" if name == "electron" else name]
        / "patterns/assembly/framework/game-loop"
    )
    subprocess.run(
        ["make", f"BUILD198X={args.build198x}"],
        cwd=folder,
        check=True,
        capture_output=True,
        timeout=60,
    )
    sym = symbols(folder / "build/demo.sym")
    out = folder / (
        "build/verification-electron" if name == "electron" else "build/verification"
    )
    out.mkdir(exist_ok=True)
    executable = (
        args.spectrum
        if name == "spectrum"
        else args.native
        / (
            "emu198x-"
            + {
                "c64": "c64",
                "amiga": "amiga",
                "nes": "nes",
                "bbc": "acorn-bbc-micro",
                "electron": "acorn-electron",
            }[name]
        )
    )
    binary = folder / (
        "build/demo.sna"
        if name == "spectrum"
        else "build/demo.adf"
        if name == "amiga"
        else "build/demo.nes"
        if name == "nes"
        else "build/demo.prg"
        if name == "c64"
        else "build/demo.bin"
    )
    command = [str(executable), "--mcp"]
    firmware = {}
    if name == "c64":
        firmware = {
            n: args.firmware_root / "commodore-c64" / n
            for n in ["kernal.rom", "basic.rom", "chargen.rom"]
        }
    elif name == "spectrum":
        firmware = {"48k": args.firmware_root / "sinclair-zx-spectrum-48k/48.rom"}
        command += ["--rom", str(firmware["48k"])]
    elif name == "amiga":
        firmware = {"kickstart": args.kickstart}
    elif name in ("bbc", "electron"):
        fw = args.firmware_root / (
            "acorn-bbc-micro" if name == "bbc" else "acorn-electron"
        )
        firmware = {
            "mos": fw / "os.rom",
            "basic": args.bbc_basic if name == "bbc" else fw / "basic.rom",
        }

    if name == "c64":
        # --load is handled by the script/UI startup path, not by MCP startup.
        # Use the existing headless importer once, then resume its booted state.
        bootstrap = out / "import.json"
        snapshot = out / "import.vsf"
        bootstrap.write_text(
            json.dumps([{"action": "save_snapshot", "path": str(snapshot)}])
        )
        subprocess.run(
            [
                str(executable),
                "--rom-dir",
                str(args.firmware_root / "commodore-c64"),
                "--model",
                "pal",
                "--load",
                str(binary),
                "--script",
                str(bootstrap),
            ],
            check=True,
            capture_output=True,
            text=True,
            timeout=60,
        )
        command += [
            "--model",
            "pal",
            "--rom-dir",
            str(args.firmware_root / "commodore-c64"),
        ]
    if name == "nes":
        command += ["--rom", str(binary), "--region", "ntsc"]
    if name == "amiga":
        command += [
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(binary),
        ]
    if name == "bbc":
        command += [
            "--mos",
            str(firmware["mos"]),
            "--rom",
            f"acorn-bbc-basic={firmware['basic']}",
        ]
    if name == "electron":
        command += ["--os", str(firmware["mos"]), "--basic", str(firmware["basic"])]
    machine = Machine(command)
    try:
        base = 0
        if name == "spectrum":
            machine.call("load_snapshot", path=str(binary))
            machine.call("run_frames", frames=30)
        elif name == "c64":
            machine.call("load_snapshot", path=str(snapshot))
            machine.call("type_string", text="RUN\n", hold_frames=3, settle_frames=10)
        elif name in ("bbc", "electron"):
            machine.call("run_frames", frames=150)
            for line in (folder / "build/loader.bas").read_text().splitlines():
                machine.call(
                    "type_string", text=line + "\n", hold_frames=2, settle_frames=2
                )
            machine.call("type_string", text="RUN\n", hold_frames=2, settle_frames=10)
            state_offsets = {
                sym["updates"] - 0x3000,
                sym["updates"] - 0x3000 + 1,
                sym["slow"] - 0x3000,
            }
            expected = binary.read_bytes()
            for load_wait in range(0, 301, 10):
                actual = bytes(
                    machine.call("memory_read", addr=0x3000, len=len(expected))["bytes"]
                )
                mismatches = [
                    (i, a, b)
                    for i, (a, b) in enumerate(zip(actual, expected, strict=True))
                    if i not in state_offsets and a != b
                ]
                if not mismatches:
                    break
                if load_wait < 300:
                    machine.call("run_frames", frames=10)
            if mismatches:
                machine.call("save_screenshot", path=str(out / "loader-failure.png"))
            require(
                not mismatches,
                f"Typed loader did not install executable: {mismatches[:8]}",
            )
        elif name == "amiga":
            found = []
            for _ in range(20):
                machine.call("run_frames", frames=100)
                scan = machine.call(
                    "memory_scan", start=0, end=0x80000, value=0x31393858
                )
                require(not scan["truncated"], "Amiga signature scan truncated")
                for hit in scan["hits"]:
                    candidate = int(hit["addr"][1:], 16) - sym["signature"]
                    if memory(machine, candidate + sym["ready"], 2, True) == 0xCAFE:
                        found.append(candidate)
                if found:
                    break
            require(len(found) == 1, f"Expected one relocated caller: {found}")
            base = found[0]
        else:
            machine.call("run_frames", frames=30)
        big = name == "amiga"
        width = 2 if big else 1

        def read(label: str, size: int = width) -> int:
            return memory(machine, base + sym[label], size, big)

        def advance(frames: int) -> int:
            before = read("updates", 2)
            machine.call("run_frames", frames=frames)
            return (read("updates", 2) - before) & 65535

        def action(pressed: bool) -> None:
            event = (
                {"Key": {"name": "space", "pressed": pressed}}
                if name in ("spectrum", "bbc", "electron")
                else {
                    "Button": {
                        "port": 1 if name == "nes" else 2,
                        "name": "a" if name == "nes" else "fire",
                        "pressed": pressed,
                    }
                }
            )
            machine.call("input", events=[event])

        action(False)
        machine.call("run_frames", frames=8)
        fast = advance(30)
        if fast == 0:
            print(
                name,
                "STALLED",
                machine.call("query_cpu"),
                machine.call(
                    "memory_read",
                    addr=0x0801 if name == "c64" else sym["updates"],
                    len=16,
                ),
                flush=True,
            )
            machine.call("save_screenshot", path=str(out / "stalled.png"))
        normal_rate(fast, 30)
        action(True)
        machine.call("run_frames", frames=8)
        require(read("slow") != 0, "Real input did not select the CPU workload")
        slow = advance(30)
        require(
            0 < slow < fast // 2,
            f"Slow workload did not reduce update rate: {fast}, {slow}",
        )
        delta = read("frame_delta") if "frame_delta" in sym else None
        if delta is not None:
            require(delta > 1, "Interrupt clock did not retain missed boundaries")
        action(False)
        machine.call("run_frames", frames=12)
        require(read("slow") == 0, "Input did not recover after slow work")
        recovered = advance(30)
        normal_rate(recovered, 30)
        machine.call("save_screenshot", path=str(out / "running.png"))
        # Positive cases finish before this explicitly invasive control.
        if name == "nes":
            # Cartridge ROM correctly ignores pokes. Assemble the same-sized
            # caller mutation instead of pretending a ROM write took effect.
            mutant = folder / "negative-control.asm"
            source = (folder / "demo.asm").read_text()
            require(source.count("    jsr wait_frame") == 1, "Expected one wait call")
            mutant.write_text(
                source.replace("    jsr wait_frame", "    nop\n    nop\n    nop")
            )
            try:
                subprocess.run(
                    [
                        "asm198x",
                        "--dialect",
                        "ca65",
                        str(mutant),
                        "-o",
                        str(out / "negative.nes"),
                    ],
                    cwd=folder,
                    check=True,
                    capture_output=True,
                    text=True,
                    timeout=30,
                )
            finally:
                mutant.unlink()
            machine.close()
            machine = Machine(
                [
                    str(executable),
                    "--mcp",
                    "--rom",
                    str(out / "negative.nes"),
                    "--region",
                    "ntsc",
                ]
            )
            machine.call("run_frames", frames=30)
        else:
            replacement = (
                [0x4E, 0x75] if big else [0xC9] if name == "spectrum" else [0x60]
            )
            for offset, value in enumerate(replacement):
                machine.call(
                    "poke_byte", addr=base + sym["wait_frame"] + offset, value=value
                )
        unpaced = advance(10)
        try:
            normal_rate(unpaced, 10)
        except AssertionError:
            rejected = True
        else:
            rejected = False
        require(rejected, "Unpaced negative control passed the same normal-rate guard")
        result = {
            "status": "passed",
            "system": name,
            "server": machine.server.get("serverInfo"),
            "startup": {
                "c64": "PRG imported after ROM boot, typed RUN",
                "spectrum": "48K snapshot; separate tape qualification required",
                "bbc": "Fresh MOS/BASIC boot; loader typed through keyboard and RUN; executable bytes compared excluding declared state",
                "electron": "Fresh Electron OS/BASIC boot; same typed loader and executable; executable bytes compared excluding declared state",
                "nes": "NTSC NROM reset",
                "amiga": "Cold ADF boot, A500 OCS PAL, KS1.3",
            }[name],
            "firmware_sha256": {key: sha(path) for key, path in firmware.items()},
            "observer_sha256": sha(Path(__file__)),
            "emulator_sha256": sha(Path(executable)),
            "binary_sha256": sha(binary),
            "sources": {
                str(p.resolve().relative_to(ROOT)): sha(p)
                for p in [
                    folder / "demo.asm",
                    folder / "frame.inc",
                    folder / "Makefile",
                    *[
                        folder / x
                        for x in re.findall(
                            r'(?:include|!source)\s+"([^"]+)"',
                            (folder / "demo.asm").read_text(),
                            re.IGNORECASE,
                        )
                        if x != "frame.inc"
                    ],
                    *(
                        [folder / "loader.py", folder / "build/loader.bas"]
                        if name in ("bbc", "electron")
                        else []
                    ),
                ]
            },
            "normal_updates_in_30_frames": fast,
            "over_budget_updates_in_30_frames": slow,
            "over_budget_last_frame_delta": delta,
            "recovered_updates_in_30_frames": recovered,
            "negative_control": {
                "intervention": "assemble caller with wait call replaced by three NOPs"
                if name == "nes"
                else "replace wait_frame with return",
                "updates_in_10_frames": unpaced,
                "same_rate_guard_rejected": rejected,
            },
            "limits": "Native-emulator configuration evidence. Not original hardware, full emulator conformance or a runtime cost benchmark. Polling loops discard missed boundaries; interrupt-byte clocks require <256 frames between samples.",
        }
        if name == "bbc":
            result["basic_sha256"] = sha(args.bbc_basic)
        if name == "amiga":
            result["kickstart_sha256"] = sha(args.kickstart)
        if name == "spectrum":
            result["fresh_rom_tape"] = tape_start(args, folder, sym)
        (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        print("PASS", name, fast, slow, recovered, "unpaced", unpaced, flush=True)
        return result
    finally:
        machine.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--native", type=Path, required=True)
    parser.add_argument(
        "--spectrum", type=Path, default=Path("/opt/homebrew/bin/emu198x-spectrum")
    )
    parser.add_argument("--kickstart", type=Path, required=True)
    parser.add_argument("--bbc-basic", type=Path, required=True)
    parser.add_argument("--build198x", required=True)
    parser.add_argument(
        "--firmware-root", type=Path, default=Path.home() / ".emu198x/roms"
    )
    parser.add_argument("--include-electron", action="store_true")
    parser.add_argument("--only", choices=[*SYSTEMS, "electron"])
    args = parser.parse_args()
    for name in (
        [args.only]
        if args.only
        else [*SYSTEMS, *(["electron"] if args.include_electron else [])]
    ):
        run(name, args)
