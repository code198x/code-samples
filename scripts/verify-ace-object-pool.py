"""Qualify bounded pool operations using the original Ace ROM and keyboard."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import signal
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
F = ROOT / "jupiter-ace/patterns/forth/framework/object-pool"
V = F / "verification"


def module(name: str, path: Path) -> Any:
    spec = importlib.util.spec_from_file_location(name, path)
    if spec is None or spec.loader is None:
        raise RuntimeError(path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


A = module("ace_pool_transport", ROOT / "scripts/verify-ace-deadline.py")
T = A.T
C = module("ace_pool_model", F / "oracle.py")


def sources() -> dict[str, str]:
    paths = [p for p in F.rglob("*.fth") if not p.is_relative_to(F / "build")]
    paths += [F / "oracle.py", F / "build.py", F / "Makefile", Path(__file__)]
    paths += [
        ROOT / p
        for p in (
            "docs/ace-map-tools.json",
            "scripts/verify-ace-deadline.py",
            "scripts/verify-game-loops.py",
            "scripts/check-amiga-command-loops.py",
        )
    ]
    return {str(p.relative_to(ROOT)): T.sha(p) for p in sorted(paths)}


class Native:
    def __init__(self, args: argparse.Namespace, group: str) -> None:
        self.group = group
        self.machine = T.Machine(
            [str(args.emulator), "--mcp", "--rom", str(args.firmware)]
        )
        self.record: dict[str, Any] = {
            "sources": sources(),
            "rows": [],
            "entered_lines": [],
        }

    def enter(self, line: str) -> None:
        T.require(len(line) <= 78, "Keyboard source exceeds two-line editor bound")
        A.enter(self.machine, line)
        self.record["entered_lines"].append(line)

    def bytes(self, start: int, length: int) -> bytes:
        data = bytearray()
        for offset in range(0, length, 128):
            size = min(128, length - offset)
            part = self.machine.call("memory_read", addr=start + offset, len=size)[
                "bytes"
            ]
            T.require(len(part) == size, "Truncated native RAM")
            data.extend(part)
        return bytes(data)

    def prepare(self) -> None:
        self.machine.call("run_frames", frames=150)
        self.enter(": NUMBER CLS U. ;")
        before = A.value(self.machine, "HERE")
        T.require(A.value(self.machine, "15384 @") == 16384, "Changed stock RAM")
        files = ["routines.fth", "storage.fth", "caller.fth"]
        files.append(
            "customise.fth"
            if self.group == "custom"
            else "single.fth"
            if self.group == "single"
            else "settings.fth"
        )
        sizes = {}
        for file in files:
            for line in (F / file).read_text().splitlines():
                self.enter(line)
            sizes[file] = A.value(self.machine, "HERE")
        self.here = A.read(self.machine, 15415)
        self.addresses = {
            n: A.value(self.machine, n) for n in (*C.NAMES, "SLOTS", "PAYLOAD")
        }
        self.state = {n: A.read(self.machine, self.addresses[n]) for n in C.NAMES}
        self.flags = list(self.bytes(self.addresses["SLOTS"], 9))
        self.payload = [
            A.read(self.machine, self.addresses["PAYLOAD"] + 2 * i) for i in range(9)
        ]
        self.record.update(
            before=before,
            here=self.here,
            sizes=sizes,
            addresses=self.addresses,
            entered_source_sha256=hashlib.sha256(
                "".join((F / f).read_text() for f in files).encode("ascii")
            ).hexdigest(),
            files=files,
            dictionary_before_hex=self.bytes(before, self.here - before).hex(),
        )
        T.require(A.read(self.machine, 15419) == self.here + 12, "Import leaked stack")
        self.enter("77")

    def seed(
        self,
        fields: dict[str, int] | None = None,
        flags: list[int] | None = None,
        payload: list[int] | None = None,
    ) -> None:
        for n, value in (fields or {}).items():
            self.enter(f"{value & 65535} {n} !")
            self.state[n] = value & 65535
        if flags is not None:
            for i, value in enumerate(flags):
                self.enter(f"{value} SLOTS {i} + C!")
            self.flags = flags.copy()
        if payload is not None:
            for i, value in enumerate(payload):
                self.enter(f"{value} PAYLOAD {2 * i} + !")
            self.payload = payload.copy()

    def call(
        self,
        tag: str,
        operation: str,
        argument: int = 0,
        base: int | None = None,
        owner: bool = False,
    ) -> None:
        base = self.addresses["SLOTS"] if base is None else base
        before_state = self.state.copy()
        before_flags, before_payload = self.flags.copy(), self.payload.copy()
        result = C.step(self.state, self.flags, self.here, operation, argument, base)
        if owner and result[1]:
            self.payload[result[0]] = 60
        command = (
            f"{base} {argument} PINIT"
            if operation == "init"
            else "NEWOBJ"
            if owner
            else "PGET"
            if operation == "get"
            else f"{argument} PREL"
        )
        self.enter(command)
        top = A.read(self.machine, 15419)
        actual_stack = [A.read(self.machine, a) for a in range(self.here + 12, top, 2)]
        raw = self.bytes(self.record["before"], self.here - self.record["before"])

        def cell(address: int) -> int:
            offset = address - self.record["before"]
            return int.from_bytes(raw[offset : offset + 2], "little")

        state = {n: cell(self.addresses[n]) for n in C.NAMES}
        offset = self.addresses["SLOTS"] - self.record["before"]
        flags = list(raw[offset : offset + 9])
        payload = [cell(self.addresses["PAYLOAD"] + 2 * i) for i in range(9)]
        T.require(
            actual_stack == [77, *result], f"{tag}: result or prefix {actual_stack}"
        )
        T.require(state == self.state, f"{tag}: full context {state} != {self.state}")
        T.require(
            flags == self.flags and payload == self.payload, f"{tag}: storage changed"
        )
        T.require(
            A.read(self.machine, 15415) == self.here, "Dictionary grew during calls"
        )
        mutable = set()
        for n in C.NAMES:
            mutable.update((self.addresses[n], self.addresses[n] + 1))
        mutable.update(range(self.addresses["SLOTS"], self.addresses["SLOTS"] + 9))
        mutable.update(range(self.addresses["PAYLOAD"], self.addresses["PAYLOAD"] + 18))
        initial = bytes.fromhex(self.record["dictionary_before_hex"])
        T.require(
            all(
                a == b or self.record["before"] + i in mutable
                for i, (a, b) in enumerate(zip(initial, raw, strict=True))
            ),
            "Compiled code changed",
        )
        cpu_sp = int(self.machine.call("query_cpu")["registers"]["sp"].lstrip("$"), 16)
        T.require(top < cpu_sp <= 16384, "Native CPU/data stacks collided")
        self.record["rows"].append(
            {
                "tag": tag,
                "operation": operation,
                "argument": argument,
                "base": base,
                "owner": owner,
                "before_state": before_state,
                "before_flags": before_flags,
                "before_payload": before_payload,
                "state": state,
                "flags": flags,
                "payload": payload,
                "stack": actual_stack,
                "data_top": top,
                "cpu_sp": cpu_sp,
                "dictionary_hex": raw.hex(),
            }
        )
        self.enter(" ".join(["DROP"] * len(result)))
        T.require(
            A.read(self.machine, 15419) == self.here + 14, "Call consumed caller prefix"
        )
        if len(self.record["rows"]) % 32 == 0:
            self.save()
            print(self.group, len(self.record["rows"]), tag, flush=True)

    def save(self) -> None:
        T.require(
            self.record["sources"] == sources(),
            "Runtime input changed during qualification",
        )
        (V / (self.group + ".json")).write_text(
            json.dumps(self.record, indent=2) + "\n"
        )

    def finish(self) -> None:
        self.enter("PSHOW")
        path = V / (self.group + ".png")
        self.machine.call("save_screenshot", path=str(path))
        self.record["capture"] = {
            "image": path.name,
            "sha256": T.sha(path),
            "pixels": A.capture_check(self.machine, path),
        }
        self.enter("NUMBER")
        T.require(
            A.read(self.machine, 15419) == self.here + 12, "Final stack not empty"
        )
        self.record["complete"] = True
        self.save()


def qualify(n: Native) -> None:
    n.prepare()
    if n.group == "masks":
        for cap in (1, 4, 8):
            for mask in range(1 << cap):
                n.call(f"mask-{cap}-{mask}-init", "init", cap)
                flags = [
                    ((1, 128, 255)[i % 3] if mask & (1 << i) else 0) if i < cap else 77
                    for i in range(8)
                ] + [99]
                n.seed(flags=flags, payload=[1000 + i for i in range(8)] + [65535])
                n.call(f"mask-{cap}-{mask}-get", "get")
                slot = n.state["PK"]
                n.call(f"mask-{cap}-{mask}-release", "release", slot)
                n.call(f"mask-{cap}-{mask}-double", "release", slot)
    elif n.group == "bounds":
        for cap in (0, 9, 255, 256, 32767, 32768, 65535, -1, -32768):
            n.call(f"bad-init-{cap}", "init", cap)
            n.call(f"disabled-get-{cap}", "get")
            n.call(f"disabled-release-{cap}", "release", 0)
        for pointer in (0, 15440, n.here - 7, n.here, 16383, 32768, 65535):
            n.call(f"bad-pointer-{pointer}", "init", 8, pointer)
            n.call(f"bad-pointer-get-{pointer}", "get")
            n.call(f"bad-pointer-release-{pointer}", "release", 0)
        for size in (0, 9, 255, 256, 32768, 65535):
            n.call(f"extent-{size}-init", "init", 8)
            n.seed(fields={"PS": size, "PI": 91})
            n.call(f"extent-{size}-get", "get")
            n.call(f"extent-{size}-release", "release", 0)
        for cap in (1, 4, 8):
            n.call(f"index-{cap}-init", "init", cap)
            n.seed(flags=[1] * cap + [77] * (8 - cap) + [99])
            for index in (cap, 8, 255, 256, 32767, 32768, 65535, -1, -32768):
                n.call(f"index-{cap}-{index}", "release", index)
            n.seed(fields={"PC": 0})
            n.call(f"private-extent-{cap}", "get")
    else:
        cap = 4 if n.group == "custom" else 1 if n.group == "single" else 8
        n.seed(payload=[1000 + i for i in range(8)] + [65535])
        n.call("owner-init", "init", cap)
        for i in range(cap + 1):
            n.call(f"owner-get-{i}", "get", owner=True)
        if n.group == "single":
            for age in range(300):
                n.call(f"age-{age}-release", "release", 0)
                n.call(f"age-{age}-reuse", "get", owner=True)
        if n.group != "wrong":
            n.call("owner-release", "release", 0)
        else:
            for line in (F / "mistakes/omit-release.fth").read_text().splitlines():
                n.enter(line)
        n.call("owner-reuse", "get", owner=True)
    n.finish()


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--emulator", type=Path, required=True)
    parser.add_argument("--firmware", type=Path, required=True)
    parser.add_argument(
        "--group",
        choices=("masks", "bounds", "working", "custom", "single", "wrong", "repaired"),
        required=True,
    )
    args = parser.parse_args()
    cfg = json.loads((ROOT / "docs/ace-map-tools.json").read_text())
    T.require(
        T.sha(args.emulator) == cfg["emulator_sha256"]
        and T.sha(args.firmware) == cfg["firmware_sha256"],
        "Changed original runtime",
    )
    V.mkdir(exist_ok=True)
    T.require(
        not (V / (args.group + ".json")).exists(),
        "Preserve previous evidence before rerun",
    )
    signal.signal(
        signal.SIGALRM,
        lambda *_: (_ for _ in ()).throw(TimeoutError("1800 second native bound")),
    )
    signal.alarm(1800)
    n = Native(args, args.group)
    n.record["configuration"] = cfg
    try:
        qualify(n)
        print(args.group, len(n.record["rows"]), "original ROM passed", flush=True)
    finally:
        try:
            n.save()
        finally:
            n.machine.close()
            signal.alarm(0)


if __name__ == "__main__":
    main()
