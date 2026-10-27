"""Check retained pool cases against independent occupancy and ownership rules."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import re
from collections.abc import Iterator
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "ace_pool_native", ROOT / "scripts/verify-ace-object-pool.py"
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing native pool verifier")
V = importlib.util.module_from_spec(spec)
spec.loader.exec_module(V)
T, C = V.T, V.C
P = V.module("pool_png", ROOT / "scripts/check-amiga-command-loops.py")
GROUPS = ("masks", "bounds", "working", "custom", "single", "wrong", "repaired")
ADDRESS = {
    "PB": 15469,
    "PC": 15480,
    "PS": 15491,
    "PK": 15502,
    "PF": 15513,
    "PX": 15524,
    "PI": 15535,
    "SLOTS": 16128,
    "PAYLOAD": 16151,
}
INITIAL_SHA = "403f5750b68aeeb5e2a5eef0a056537a6a6e691c9f083943a76ecfd3b44274ed"
COUNTS = {
    "masks": 1096,
    "bounds": 99,
    "working": 12,
    "custom": 8,
    "single": 605,
    "wrong": 11,
    "repaired": 12,
}


def scenario(group: str) -> Iterator[dict[str, Any]]:
    """The written case schedule, independent of the native runner loops."""

    def call(
        tag: str,
        operation: str,
        argument: int = 0,
        base: int = 16128,
        owner: bool = False,
    ) -> dict[str, Any]:
        return {
            "tag": tag,
            "operation": operation,
            "argument": argument,
            "base": base,
            "owner": owner,
        }

    if group == "masks":
        for capacity, masks in ((1, 2), (4, 16), (8, 256)):
            for mask in range(masks):
                prefix = f"mask-{capacity}-{mask}"
                yield call(prefix + "-init", "init", capacity)
                flags = [77] * 8 + [99]
                for index in range(capacity):
                    flags[index] = (1, 128, 255)[index % 3] if mask & 2**index else 0
                yield {
                    "seed_flags": flags,
                    "seed_payload": list(range(1000, 1008)) + [65535],
                }
                free = next((i for i in range(capacity) if not flags[i]), capacity)
                yield call(prefix + "-get", "get")
                yield call(prefix + "-release", "release", free)
                yield call(prefix + "-double", "release", free)
    elif group == "bounds":
        for size in (0, 9, 255, 256, 32767, 32768, 65535, -1, -32768):
            yield call(f"bad-init-{size}", "init", size)
            yield call(f"disabled-get-{size}", "get")
            yield call(f"disabled-release-{size}", "release")
        for pointer in (0, 15440, 16272, 16279, 16383, 32768, 65535):
            yield call(f"bad-pointer-{pointer}", "init", 8, pointer)
            yield call(f"bad-pointer-get-{pointer}", "get")
            yield call(f"bad-pointer-release-{pointer}", "release")
        for size in (0, 9, 255, 256, 32768, 65535):
            yield call(f"extent-{size}-init", "init", 8)
            yield {"seed_fields": {"PS": size, "PI": 91}}
            yield call(f"extent-{size}-get", "get")
            yield call(f"extent-{size}-release", "release")
        for capacity in (1, 4, 8):
            yield call(f"index-{capacity}-init", "init", capacity)
            yield {"seed_flags": [1] * capacity + [77] * (8 - capacity) + [99]}
            for index in (capacity, 8, 255, 256, 32767, 32768, 65535, -1, -32768):
                yield call(f"index-{capacity}-{index}", "release", index)
            yield {"seed_fields": {"PC": 0}}
            yield call(f"private-extent-{capacity}", "get")
    else:
        capacity = {"custom": 4, "single": 1}.get(group, 8)
        yield {"seed_payload": list(range(1000, 1008)) + [65535]}
        yield call("owner-init", "init", capacity)
        for index in range(capacity + 1):
            yield call(f"owner-get-{index}", "get", owner=True)
        if group == "single":
            for age in range(300):
                yield call(f"age-{age}-release", "release")
                yield call(f"age-{age}-reuse", "get", owner=True)
        if group == "wrong":
            yield {"wrong": True}
        else:
            yield call("owner-release", "release")
        yield call("owner-reuse", "get", owner=True)


def capture(group: str, record: dict[str, Any], state: dict[str, int]) -> None:
    cap = record["capture"]
    path = V.V / (group + ".png")
    T.require(
        cap["image"] == path.name and cap["sha256"] == T.sha(path), "Changed capture"
    )
    native = cap["pixels"]
    raw = bytes.fromhex(native["video_hex"])
    T.require(
        len(raw) == 768 and native["pixel_match"] is True, "Incomplete native screen"
    )
    text = "".join(chr(c & 127) if 32 <= c & 127 < 127 else " " for c in raw)
    T.require(
        re.match(
            rf"\s*SLOT\s+{state['PK']}\s+OK\s+{state['PF']}\s", text, re.IGNORECASE
        )
        is not None
        and "ERROR" not in text.upper(),
        "Native display differs from state",
    )
    width, height, channels, pixels = P.png(path)
    T.require((width, height, channels) == (320, 288, 4), "Wrong capture extent")
    glyphs = native["glyphs"]
    T.require(
        set(glyphs) == {str(c & 127) for c in raw}
        and all(len(g) == 8 and all(0 <= b <= 255 for b in g) for g in glyphs.values()),
        "Incomplete native font",
    )
    for y in range(192):
        for x in range(256):
            code = raw[y // 8 * 32 + x // 8]
            bit = bool(glyphs[str(code & 127)][y % 8] & (128 >> (x % 8))) ^ bool(
                code & 128
            )
            offset = ((y + 48) * width + x + 32) * 4
            expected = bytes((207, 207, 207, 255)) if bit else bytes((0, 0, 0, 255))
            T.require(
                bytes(pixels[offset : offset + 4]) == expected,
                "Pixels disagree with native RAM",
            )


def check_group(group: str, r: dict[str, Any]) -> None:
    T.require(group in GROUPS and r.get("complete") is True, "Incomplete native group")
    T.require(r["sources"] == V.sources(), "Source or native observer identity differs")
    T.require(
        r["configuration"]
        == json.loads((ROOT / "docs/ace-map-tools.json").read_text()),
        "Wrong original runtime",
    )
    setting = {"custom": "customise.fth", "single": "single.fth"}.get(
        group, "settings.fth"
    )
    files = ["routines.fth", "storage.fth", "caller.fth", setting]
    T.require(
        r["files"] == files
        and r["sizes"] == dict(zip(files, (16116, 16169, 16279, 16279), strict=True))
        and r["before"] == 15460
        and r["here"] == 16279
        and r["addresses"] == ADDRESS,
        "Changed native layout, resource size or load order",
    )
    T.require(
        r["entered_source_sha256"]
        == hashlib.sha256(
            "".join((V.F / f).read_text() for f in files).encode("ascii")
        ).hexdigest(),
        "Changed ordered typed source",
    )
    initial = bytes.fromhex(r["dictionary_before_hex"])
    T.require(len(initial) == 819, "Truncated compiled dictionary")
    normal = bytearray(initial)
    pc = ADDRESS["PC"] - 15460
    normal[pc : pc + 2] = b"\x08\x00"
    T.require(
        hashlib.sha256(normal).hexdigest() == INITIAL_SHA,
        "Changed original compiled code or data",
    )
    capacity = {"custom": 4, "single": 1}.get(group, 8)
    T.require(
        int.from_bytes(initial[pc : pc + 2], "little") == capacity,
        "Wrong initial capacity",
    )
    state = {n: capacity if n == "PC" else 0 for n in C.NAMES}
    flags, payload = [77] * 8 + [99], [60] * 8 + [65535]
    entered = [": NUMBER CLS U. ;"]
    for file in files:
        entered.extend((V.F / file).read_text().splitlines())
    entered.append("77")
    plan = list(scenario(group))
    actions = [event for event in plan if "operation" in event]
    T.require(
        len(actions) == len(r["rows"]) == COUNTS[group] > 0,
        "Missing or extra native cases",
    )
    rows = iter(r["rows"])
    for event in plan:
        if "seed_fields" in event:
            for name, value in event["seed_fields"].items():
                state[name] = value & 65535
                entered.append(f"{value & 65535} {name} !")
        if "seed_flags" in event:
            flags = event["seed_flags"].copy()
            entered.extend(f"{value} SLOTS {i} + C!" for i, value in enumerate(flags))
        if "seed_payload" in event:
            payload = event["seed_payload"].copy()
            entered.extend(
                f"{value} PAYLOAD {2 * i} + !" for i, value in enumerate(payload)
            )
        if event.get("wrong"):
            entered.extend((V.F / "mistakes/omit-release.fth").read_text().splitlines())
        if "operation" not in event:
            continue
        row = next(rows)
        T.require(
            all(row[k] == value for k, value in event.items()),
            "Wrong case or input order",
        )
        T.require(
            row["before_state"] == state
            and row["before_flags"] == flags
            and row["before_payload"] == payload,
            "Wrong seeded input or lifetime state",
        )
        operation, argument, base = event["operation"], event["argument"], event["base"]
        result = C.step(state, flags, 16279, operation, argument, base)
        if event["owner"] and result[1]:
            payload[result[0]] = 60
        entered.append(
            f"{base} {argument} PINIT"
            if operation == "init"
            else "NEWOBJ"
            if event["owner"]
            else "PGET"
            if operation == "get"
            else f"{argument} PREL"
        )
        T.require(
            row["state"] == state
            and row["flags"] == flags
            and row["payload"] == payload
            and row["stack"] == [77, *result],
            "Native pool/context/payload/result mismatch",
        )
        top = 16279 + 12 + 2 * len(row["stack"])
        T.require(
            row["data_top"] == top and top < row["cpu_sp"] <= 16384,
            "Stack leak or collision",
        )
        expected = bytearray(initial)
        for name, value in state.items():
            offset = ADDRESS[name] - 15460
            expected[offset : offset + 2] = value.to_bytes(2, "little")
        offset = ADDRESS["SLOTS"] - 15460
        expected[offset : offset + 9] = bytes(flags)
        offset = ADDRESS["PAYLOAD"] - 15460
        expected[offset : offset + 18] = b"".join(
            v.to_bytes(2, "little") for v in payload
        )
        T.require(
            bytes.fromhex(row["dictionary_hex"]) == expected,
            "Compiled code or owned RAM mismatch",
        )
        entered.append(" ".join(["DROP"] * len(result)))
    entered += ["PSHOW", "NUMBER"]
    T.require(r["entered_lines"] == entered, "Typed native diagnostic recipe differs")
    capture(group, r, state)


def check(records: dict[str, dict[str, Any]] | None = None) -> None:
    records = (
        records
        if records is not None
        else {g: json.loads((V.V / (g + ".json")).read_text()) for g in GROUPS}
    )
    T.require(set(records) == set(GROUPS), "Missing or extra native boot")
    for group in GROUPS:
        check_group(group, records[group])


if __name__ == "__main__":
    check()
    print(
        "Ace pool: all seven stock-ROM groups, full RAM, recipes, stacks and pixels passed"
    )
