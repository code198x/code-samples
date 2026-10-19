"""Execute the three remaining input/edge/sound callers on identified machines.

Positive cases use real emulator key/controller events. One explicitly labelled
negative control clears input history while Fire remains held; the same count
guard must reject that extra event. No firmware or generated binary is committed.
"""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import queue
import re
import subprocess
import sys
import threading
import wave
from array import array
from itertools import pairwise
from pathlib import Path
from statistics import median
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
REL = Path("patterns/assembly/framework/input-to-sound")
SYSTEMS = {
    "spectrum": "sinclair-zx-spectrum",
    "nes": "nintendo-entertainment-system",
    "amiga": "commodore-amiga",
}


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


def audio(path: Path) -> dict:
    with wave.open(str(path)) as stream:
        require(stream.getsampwidth() == 2, "Expected 16-bit captured PCM")
        count, channels, rate = (
            stream.getnframes(),
            stream.getnchannels(),
            stream.getframerate(),
        )
        samples = array("h", stream.readframes(count))
    if sys.byteorder != "little":
        samples.byteswap()
    tracks = [samples[i::channels] for i in range(channels)]

    def span(values: array) -> int:
        return max(values) - min(values) if values else 0

    track = max(tracks, key=span)
    midpoint = (min(track) + max(track)) / 2
    rising = [i for i in range(1, len(track)) if track[i - 1] < midpoint <= track[i]]
    periods = [b - a for a, b in pairwise(rising)]
    frequency = rate / median(periods) if periods else 0
    # Last half rejects startup/DC/filter transients when testing steady output.
    return {
        "rate": rate,
        "frames": count,
        "channels": channels,
        "span": span(track),
        "tail_span": span(track[len(track) // 2 :]),
        "rising_crossings": len(rising),
        "frequency_hz": frequency,
        "sha256": sha(path),
    }


def input_events(name: str, mask: int) -> list[dict]:
    if name == "spectrum":
        return [
            {"Key": {"name": key, "pressed": bool(mask & bit)}}
            for key, bit in [("q", 1), ("a", 2), ("o", 4), ("p", 8), ("space", 16)]
        ]
    buttons = (
        [("up", 1), ("down", 2), ("left", 4), ("right", 8), ("fire", 16)]
        if name == "amiga"
        else [
            ("a", 128),
            ("b", 64),
            ("select", 32),
            ("start", 16),
            ("up", 8),
            ("down", 4),
            ("left", 2),
            ("right", 1),
        ]
    )
    return [
        {
            "Button": {
                "port": 2 if name == "amiga" else 1,
                "name": key,
                "pressed": bool(mask & bit),
            }
        }
        for key, bit in buttons
    ]


def held_word(name: str, mask: int) -> int:
    if name != "amiga":
        return mask
    return sum(
        value
        for bit, value in [(1, 0x100), (2, 1), (4, 0x200), (8, 2), (16, 16)]
        if mask & bit
    )


def run_case(name: str, args: argparse.Namespace) -> dict:
    folder = ROOT / SYSTEMS[name] / REL
    subprocess.run(
        ["make", f"BUILD198X={args.build198x}"],
        cwd=folder,
        check=True,
        capture_output=True,
        text=True,
        timeout=60,
    )
    out = folder / "build/verification"
    out.mkdir(exist_ok=True)
    binary = folder / (
        "build/demo.sna"
        if name == "spectrum"
        else "build/demo.adf"
        if name == "amiga"
        else "build/demo.nes"
    )
    sym = symbols(folder / "build/demo.sym")
    executable = str(getattr(args, name))
    command = [executable, "--mcp"]
    if name == "nes":
        command += ["--rom", str(binary), "--region", "ntsc"]
    elif name == "amiga":
        command += [
            "--model",
            "a500",
            "--kickstart",
            str(args.kickstart),
            "--disk",
            str(binary),
        ]
    machine = Machine(command)
    try:
        if name == "spectrum":
            machine.call("load_snapshot", path=str(binary))
        # An already-held action counts on the first poll: zero history is deliberate.
        action = 128 if name == "nes" else 16
        machine.call("input", events=input_events(name, action))
        base = 0
        if name == "amiga":
            found = []
            for _ in range(20):
                machine.call("run_frames", frames=100)
                scan = machine.call(
                    "memory_scan", start=0, end=0x80000, value=0x31393858
                )
                require(not scan["truncated"], "Signature scan truncated")
                for hit in scan["hits"]:
                    candidate = int(hit["addr"][1:], 16) - sym["signature"]
                    if memory(machine, candidate + sym["ready"], 2, True) == 0xCAFE:
                        found.append(candidate)
                if found:
                    break
            require(
                len(found) == 1, f"Expected one running Amiga program, found {found}"
            )
            base = found[0]
            require(
                0 <= base and base + sym["program_end"] <= 0x80000,
                "Program must be chip RAM",
            )
        else:
            machine.call("run_frames", frames=12)
        size = 2 if name == "amiga" else 1

        def read(label: str, width: int = size) -> int:
            return memory(machine, base + sym[label], width, name == "amiga")

        def tick() -> None:
            if name == "amiga":
                # Observe the ordinary caller with the full native clock running.
                # Guest per-bit edge counters preserve first-frame transitions.
                machine.call("run_frames", frames=3)
                return
            machine.call("step", instructions=1)
            reached = machine.call(
                "run_until_pc", addr=base + sym["frame_done"], max_steps=50000
            )
            require(reached.get("reached") is True, f"Update did not finish: {reached}")

        if name != "amiga":
            reached = machine.call(
                "run_until_pc", addr=base + sym["frame_done"], max_steps=50000
            )
            require(reached.get("reached") is True, str(reached))
        require(read("trigger_count") == 1, f"{name}: held-on-entry must trigger once")
        previous = held_word(name, action)
        count = 1
        rows = []
        edge_counts = [0, 0, 0, 0, 1]
        combinations = list(range(256 if name == "nes" else 32))
        if name == "amiga":
            # The emulator's stick adapter resolves opposing directions first.
            # Cover all nine normal positions, with Fire released and held.
            combinations = [
                mask for mask in combinations if mask & 3 != 3 and mask & 12 != 12
            ]
        masks = [0, action, action, action | 8, 8, action | 8, 0] + combinations
        for index, mask in enumerate(masks):
            machine.call("input", events=input_events(name, mask))
            # Apply queued host events through the normal run path without advancing time.
            machine.call("run_frames", frames=0)
            before = read("updates", 2)
            tick()
            held = held_word(name, mask)
            new = held & ~previous
            if new & action:
                count = (count + 1) & (0xFFFF if name == "amiga" else 255)
            observed = {
                "held": read("controls"),
                "new": read("new_presses"),
                "triggers": read("trigger_count"),
                "updates": read("updates", 2),
            }
            require(
                observed["held"] == held,
                f"{name} held mask {index}: {observed} expected {held}",
            )
            require(
                observed["new"] == (0 if name == "amiga" else new),
                f"{name} press mask {index}: {observed} expected {new}",
            )
            require(
                observed["triggers"] == count,
                f"{name} trigger count {index}: {observed} expected {count}",
            )
            advanced = (observed["updates"] - before) & 0xFFFF
            require(
                2 <= advanced <= 4 if name == "amiga" else advanced == 1,
                f"{name} update progression mismatch: {advanced}",
            )
            if name == "amiga":
                for i, bit in enumerate([0x100, 1, 0x200, 2, 16]):
                    if new & bit:
                        edge_counts[i] += 1
                actual = [
                    memory(machine, base + sym["press_counts"] + i * 2, 2, True)
                    for i in range(5)
                ]
                require(
                    actual == edge_counts,
                    f"Amiga per-bit edge counts disagree: {actual} expected {edge_counts}",
                )
                observed["edge_counts"] = actual
            if name == "nes":
                require(
                    read("audio_status") & 1 == bool(mask & action),
                    f"{name} pulse length state mismatch",
                )
            rows.append({"input": mask, **observed})
            previous = held
        # Debug stepping accumulates native audio until the next normal run drains it.
        # Flush that matrix backlog before clearing the separate sound windows.
        machine.call("run_frames", frames=2)
        # Sound checks use steady runs, rather than changing emulator registers.
        tones = []
        for label, mask in [
            ("release", 0),
            ("press", action),
            ("hold", action),
            ("stop", 0),
            ("repress", action),
        ]:
            machine.call("input", events=input_events(name, mask))
            before_updates = read("updates", 2)
            before_events = read("trigger_count")
            machine.call("clear_audio_capture")
            # Paula DMA stop leaves a decaying analogue-filter tail in this emulator.
            # Keep the same silence threshold, with a longer measured settling window.
            window_frames = 24 if name == "amiga" else 8
            machine.call("run_frames", frames=window_frames)
            wav = out / (label + ".wav")
            machine.call("save_audio_capture", path=str(wav))
            measured = audio(wav)
            advanced = (read("updates", 2) - before_updates) & 0xFFFF
            require(
                advanced > 0,
                f"{name}: updates did not continue during audio window: {advanced}",
            )
            expected_events = 1 if label in ["press", "repress"] else 0
            events = (read("trigger_count") - before_events) & (
                0xFFFF if name == "amiga" else 255
            )
            require(
                events == expected_events,
                f"{name}: wrong sound event count at {label}: {events}",
            )
            measured["native_video_frames"] = window_frames
            measured["updates_advanced"] = advanced
            measured["new_sound_events"] = events
            expect_tone = label in ["press", "repress"] or (
                label == "hold" and name != "spectrum"
            )
            require(measured["frames"] > 0, f"{name}: empty audio")
            if expect_tone:
                require(
                    measured["span"] > 1000,
                    f"{name} missing sound at {label}: {measured}",
                )
            else:
                require(
                    measured["tail_span"] < 100,
                    f"{name} should be silent at {label}: {measured}",
                )
            if expect_tone and (name == "spectrum" or label == "hold"):
                expected = {
                    "spectrum": 3_500_000 / (26 * 127 + 51),
                    "nes": 1_789_773 / (16 * 254),
                    "amiga": 3_546_895 / (424 * 16),
                }[name]
                require(
                    measured["rising_crossings"] >= 6,
                    f"{name}: no sustained measurable waveform",
                )
                require(
                    abs(measured["frequency_hz"] / expected - 1) < 0.025,
                    f"{name}: captured pitch disagrees with the caller: {measured}",
                )
                measured["expected_hz"] = expected
            tones.append({"stage": label, **measured})
        machine.call("save_screenshot", path=str(out / "running.png"))
        # Diagnostic negative control, explicitly distinct from ordinary input runs.
        before = read("trigger_count")
        for offset in range(size):
            machine.call(
                "poke_byte", addr=base + sym["previous_controls"] + offset, value=0
            )
        tick()
        altered = read("trigger_count")
        require(
            altered == (before + 1) & (0xFFFF if name == "amiga" else 255),
            f"{name}: negative control failed to retrigger",
        )
        try:
            require(
                altered == before,
                "Held-state count guard rejects the injected history reset",
            )
        except AssertionError:
            negative = True
        else:
            negative = False
        require(negative, "Regression control did not go red")
        result = {
            "status": "passed",
            "server": machine.server["serverInfo"],
            "configuration": {
                "spectrum": "48K PAL, snapshot startup; ROM tape boot checked separately",
                "nes": "NTSC NROM, cartridge reset, controller 1, DMC disabled",
                "amiga": "A500 OCS PAL, Kickstart 1.3, cold ADF boot, physical port 2",
            }[name],
            "emulator_sha256": sha(Path(executable).resolve()),
            "binary_sha256": sha(binary),
            "sources": {
                str(p.relative_to(ROOT)): sha(p)
                for p in folder.glob("*")
                if p.suffix in [".asm", ".inc"]
            },
            "input_checks": rows,
            "sound_checks": tones,
            "held_on_entry_triggers": 1,
            "negative_control": "History cleared while action held: extra event observed; count guard rejected it",
            "limits": "Emulator observations on the named configuration; no original-hardware or listening claim.",
            "input_scope": "Nine normal stick positions with and without Fire; opposing directions excluded because the host adapter resolves them"
            if name == "amiga"
            else "All button-mask combinations plus held/released/repressed sequence",
        }
        if name == "amiga":
            result["kickstart_sha256"] = sha(args.kickstart)
            driver = (
                ROOT
                / "commodore-amiga/patterns/assembly/audio/playing-a-sample/paula-sample.inc"
            )
            result["sources"][str(driver.relative_to(ROOT))] = sha(driver)
        elif name == "spectrum":
            driver = (
                ROOT
                / "sinclair-zx-spectrum/patterns/assembly/audio/sound-beep/sound-beep.inc"
            )
            result["sources"][str(driver.relative_to(ROOT))] = sha(driver)
        (out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
        print(
            "PASS",
            name,
            len(rows),
            "input stages, audio press/hold/stop/repress, negative control",
            flush=True,
        )
        return result
    finally:
        machine.close()


def tape_boot(args: argparse.Namespace) -> dict:
    """Load the complete Spectrum caller through its ROM tape loader."""
    helper = (
        ROOT / "sinclair-zx-spectrum/basic/meet-basic/opening/verification/verify.py"
    )
    spec = importlib.util.spec_from_file_location("spectrum_transport", helper)
    transport = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(transport)
    folder = ROOT / SYSTEMS["spectrum"] / REL
    sym = symbols(folder / "build/demo.sym")
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
        updates = machine.call("memory_read", addr=sym["updates"], len=2)["bytes"]
        require(
            int.from_bytes(bytes(updates), "little") > 2,
            "ROM tape boot did not reach the update loop",
        )
        before = int.from_bytes(
            bytes(
                machine.call("memory_read", addr=sym["trigger_count"], len=1)["bytes"]
            ),
            "little",
        )
        machine.call("input", events=input_events("spectrum", 16))
        machine.frames(5)
        require(
            machine.call("memory_read", addr=sym["trigger_count"], len=1)["bytes"]
            == [(before + 1) & 255],
            "ROM-loaded caller did not respond to Space",
        )
        machine.frames(5)
        require(
            machine.call("memory_read", addr=sym["trigger_count"], len=1)["bytes"]
            == [(before + 1) & 255],
            "ROM-loaded caller retriggered held Space",
        )
        machine.call("input", events=input_events("spectrum", 0))
        machine.frames(2)
        machine.call("input", events=input_events("spectrum", 16))
        machine.frames(5)
        require(
            machine.call("memory_read", addr=sym["trigger_count"], len=1)["bytes"]
            == [(before + 2) & 255],
            "ROM-loaded caller did not retrigger after release",
        )
        machine.call(
            "save_screenshot", path=str(folder / "build/verification/tape-running.png")
        )
        print("PASS spectrum fresh ROM tape load reaches the update loop", flush=True)
        return {
            "status": "passed",
            "method": "Fresh 48K ROM, typed LOAD, normal tape playback",
            "tap_sha256": sha(folder / "build/demo.tap"),
            "space_events_after_loading": 2,
        }
    finally:
        machine.close()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spectrum", type=Path, required=True)
    parser.add_argument("--nes", type=Path, required=True)
    parser.add_argument("--amiga", type=Path, required=True)
    parser.add_argument("--kickstart", type=Path, required=True)
    parser.add_argument("--build198x", default="build198x")
    parser.add_argument("--only", choices=["spectrum", "nes", "amiga"])
    args = parser.parse_args()
    for name in [args.only] if args.only else SYSTEMS:
        result = run_case(name, args)
        if name == "spectrum":
            result["tape_boot"] = tape_boot(args)
            (ROOT / SYSTEMS[name] / REL / "build/verification/results.json").write_text(
                json.dumps(result, indent=2) + "\n"
            )


if __name__ == "__main__":
    main()
