"""Validate actual native pool results, loaded code and display evidence."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import zlib
from pathlib import Path


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(file))
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


V = module("pool_native", "verify-object-pool.py")
P = module("native_pictures", "check-seeded-random.py")
T = V.T


def pixels(c, system):
    f = V.folder(system)
    w, h, ch, data = P.P.png(f / "verification" / c["image"])
    nes = system == V.SYSTEMS[1]
    T.require((w, h, ch) == ((256, 240, 4) if nes else (416, 312, 4)), "Wrong geometry")
    text = " ".join(f"{n:02X}" for n in c["preview"]) + " "
    font = V.R.font()
    ox, oy = (16, 8) if nes else (48, 51)
    if not nes:
        wanted = [0] * 1000
        for i, char in enumerate(text):
            wanted[i] = 0 if char == " " else int(char, 16) + 1
        T.require(c["screen"] == wanted, "Screen names differ")
    for y in range(8):
        for x in range(len(text) * 8):
            char = text[x // 8]
            tile = 0 if char == " " else int(char, 16) + 1
            on = bool(font[tile * 8 + y] & (128 >> (x % 8)))
            i = ((oy + y) * w + ox + x) * ch
            T.require(
                (tuple(data[i : i + 3]) != (0, 0, 0)) == on and data[i + 3] == 255,
                "Native PNG differs from displayed state",
            )


def check(system, record=None):
    T.require(system in V.SYSTEMS, "Unknown target")
    f = V.folder(system)
    v = f / "verification"
    r = json.loads((v / "results.json").read_text()) if record is None else record
    T.require(r["system"] == system and r["language"] == "assembly", "Wrong identity")
    T.require(
        r["configuration"] == json.loads((v / "configuration.json").read_text()),
        "Changed configuration",
    )
    T.require(
        r["sources"]
        == {str(p.relative_to(V.ROOT)): T.sha(p) for p in V.source_paths(system)},
        "Changed source",
    )
    T.require(set(r["cases"]) == set(V.VARIANTS), "Missing native variant")
    for name, c in r["cases"].items():
        cap = 4 if name == "custom" else 8
        T.require(c["server"]["version"] == "0.44.2", "Changed producer")
        T.require(
            c["ready"] == [165] and c["packet"] == V.O.packet(cap),
            "Ownership/guards/register evidence differs",
        )
        T.require(
            c["preview"] == V.O.preview(cap, name == "wrong"),
            "Reuse/ageing evidence differs",
        )
        T.require(
            c["capacity"] == cap
            and c["state_bytes"] == cap
            and c["age_state_bytes"] == cap,
            "RAM contract differs",
        )
        binary = zlib.decompress(bytes.fromhex(c["program_zlib"]))
        loaded = bytes(c["loaded_bytes"])
        T.require(
            len(binary) == c["program_bytes"]
            and hashlib.sha256(binary).hexdigest() == c["program_sha256"],
            "Program identity differs",
        )
        T.require(
            hashlib.sha256(loaded).hexdigest() == c["loaded_sha256"],
            "Loaded identity differs",
        )
        if system == V.SYSTEMS[0]:
            T.require(
                binary[:2] == b"\x01\x08" and loaded == binary[2:], "Stock PRG differs"
            )
        else:
            T.require(
                binary[:4] == b"NES\x1a"
                and len(binary) == 40976
                and loaded == binary[16:32784],
                "NROM differs",
            )
            full = [
                v for i in range(17) for v in V.R.font()[i * 8 : i * 8 + 8] + [0] * 8
            ]
            T.require(
                binary[32784:] == bytes(full) + bytes(8192 - len(full)), "CHR differs"
            )
            T.require(
                r["configuration"]["firmware_sha256"] == {},
                "NES has no firmware requirement",
            )
        for prefix in ("helper", "age"):
            off, size = c[prefix + "_offset"], c[prefix + "_code_bytes"]
            T.require(
                off >= 0
                and size > 0
                and len(c[prefix + "_bytes"]) == size
                and loaded[off : off + size] == bytes(c[prefix + "_bytes"]),
                "Component extent differs",
            )
        T.require(T.sha(v / c["image"]) == c["image_sha256"], "Capture differs")
        pixels(c, system)
    T.require(
        r["cases"]["demo"]["program_sha256"]
        == r["cases"]["repaired"]["program_sha256"],
        "Repair is not exact",
    )


if __name__ == "__main__":
    for system in V.SYSTEMS:
        check(system)
        print(system, "exhaustive slot ownership, native code and image checks passed")
