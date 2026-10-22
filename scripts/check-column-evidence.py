"""Check language-specific input/audio evidence without running an emulator."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import json
import re
import sys
import wave
from array import array
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
EXPECTED = {
    **dict.fromkeys(
        (
            "acorn-atom",
            "amstrad-cpc",
            "atari-800xl",
            "commodore-pet",
            "commodore-vic-20",
            "dragon-32",
            "mattel-aquarius",
            "msx",
            "oric-atmos",
            "spectravideo-svi-328",
            "sinclair-zx80",
            "sinclair-zx81",
        ),
        "basic",
    ),
    **dict.fromkeys(
        (
            "atari-2600",
            "atari-5200",
            "atari-7800",
            "coleco-colecovision",
            "memotech-mtx",
            "nintendo-game-boy",
            "sega-game-gear",
            "sega-master-system",
            "sega-sg-1000",
            "sord-m5",
            "tatung-einstein",
            "bbc-micro",
            "acorn-electron",
        ),
        "assembly",
    ),
    "jupiter-ace": "forth",
}


def require(ok: bool, message: str) -> None:
    if not ok:
        raise ValueError(message)


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def bound(root: Path, name: str, digest: str) -> Path:
    path = (root / name).resolve()
    require(
        path.is_relative_to(root.resolve()) and path.is_file(),
        f"Missing/outside file: {name}",
    )
    require(sha(path) == digest, f"Changed file: {name}")
    return path


def inventory(routes: list[dict]) -> None:
    require(len(routes) == len(EXPECTED), "Missing/duplicate machine routes")
    require(
        {row["system"]: row["track"] for row in routes} == EXPECTED,
        "Wrong machine/language inventory",
    )
    require(
        {r["system"] for r in routes if r.get("sound_absent")}
        == {"sinclair-zx80", "sinclair-zx81"},
        "Invented/hidden stock sound",
    )


def basic_lines(text: str) -> None:
    numbers = [int(line.split()[0]) for line in text.splitlines() if line.strip()]
    require(
        bool(numbers) and len(set(numbers)) == len(numbers),
        "Empty/overlapping BASIC lines",
    )
    require(all(0 < n < 65536 for n in numbers), "Invalid BASIC line number")


def decode(system: str, sample: dict) -> int:
    raw = sample["bytes"]
    require(
        bool(raw) and all(type(v) is int and 0 <= v <= 255 for v in raw),
        "Missing/invalid actual memory",
    )
    require(
        type(sample["address"]) is int and 0 <= sample["address"] <= 65535,
        "Missing actual address",
    )
    if len(raw) == 1:
        value = raw[0]
    elif system in ("sinclair-zx80", "sinclair-zx81"):
        require(raw[0] == 118 and 118 in raw[1:], "Malformed D_FILE line")
        digits = raw[1 : raw.index(118, 1)]
        require(
            bool(digits) and all(28 <= x <= 37 for x in digits),
            "Missing display digits",
        )
        value = int("".join(str(x - 28) for x in digits))
    else:
        if system in ("acorn-atom", "dragon-32"):
            raw = [x & 63 for x in raw]
        if system in ("oric-atmos", "mattel-aquarius", "jupiter-ace"):
            text = "".join(chr(x & 127) for x in raw)
        elif system == "atari-800xl":
            text = "".join(chr((x & 127) + 32) if x & 127 < 64 else " " for x in raw)
        else:
            text = "".join(
                chr(x & 127)
                if 32 <= (x & 127) < 64
                else chr((x & 127) + 64)
                if 1 <= (x & 127) <= 26
                else " "
                for x in raw
            )
        matches = re.findall(r"TURN\s*(\d+)", text, re.IGNORECASE)
        require(bool(matches), "No actual displayed counter")
        value = int(matches[-1])
    require(value == sample["count"], "Claimed counter differs from memory")
    return value


def check_native(row: dict, record: dict) -> None:
    require(record["status"] == "passed", "Unfinished native run")
    if row.get("mos"):
        require(record["initial"]["score"] == 0, "MOS initial state wrong")
        require(
            record["collected"]["score"] == 1
            and record["collected"]["item_active"] == 0,
            "MOS collection failed",
        )
        require(
            record["held_restart_allows_movement"] is True
            and record["negative_collection_rejected"] is True,
            "Missing MOS input/negative evidence",
        )
        return
    values = [decode(row["system"], sample) for sample in record["observations"]]
    if row.get("sound_absent"):
        require(
            values == [0, 0, 0, 1, 1, 2, 7, 8, 0, 2],
            "ZX submitted values/initialisation/fault differ",
        )
        require(
            record["negative_control"]["accepted_turn_guard_rejected"] is True,
            "Missing ZX fault control",
        )
    elif row["track"] == "forth":
        require(
            values == [0, 0, 0, 1, 2, 2, 1, 1], "FORTH input/fault sequence differs"
        )
        require(
            record["sound_negative_rejected"] is True
            and record["negative_control"]["idle_guard_rejected"] is True,
            "Missing FORTH controls",
        )
    elif row["track"] == "basic":
        require(values == [0, 0, 1, 0, 1], "BASIC input/drawing/muted sequence differs")
        require(
            record["sound_negative_rejected"] is True, "Missing BASIC sound control"
        )
    else:
        require(
            values == [0, 0, 1, 1, 2, 1, 1],
            "Hardware input/hold/negative sequence differs",
        )
        require(
            all(
                record["negative_controls"][key]["same_guard_rejected"] is True
                for key in ("drawing", "sound")
            ),
            "Missing hardware controls",
        )


def pcm(path: Path) -> dict:
    with wave.open(str(path)) as stream:
        require(
            stream.getsampwidth() == 2 and stream.getnframes() > 0,
            "Empty/unsupported PCM",
        )
        values = array("h", stream.readframes(stream.getnframes()))
        if sys.byteorder != "little":
            values.byteswap()
        channels = stream.getnchannels()
        per_channel = [values[c::channels] for c in range(channels)]
        return {
            "range": max(max(v) - min(v) for v in per_channel),
            "power": max(
                sum(x * x for x in v) / len(v) - (sum(v) / len(v)) ** 2
                for v in per_channel
            ),
        }


def sound_guard(working: dict, negative: dict, baseline: dict | None = None) -> None:
    floor = max(1000, 4 * baseline["power"]) if baseline else 0
    require(
        working["range"] > 200 and working["power"] > floor,
        "No program audio above baseline",
    )
    require(
        negative["range"] <= 200 or negative["power"] <= floor,
        "Muted control passes audio guard",
    )


def check_fault(row: dict, record: dict) -> None:
    require(record["status"] == "passed", "Missing fault run")
    if row["track"] == "basic":
        values = [decode(row["system"], s) for s in record["observations"]]
        require(
            bool(values) and values[-1] == record["observed_turn"] != 0,
            "Stale command passed idle guard",
        )
        require(record["idle_guard_rejected"] is True, "Unrejected stale-command fault")
    else:
        require(
            record["held_guard_rejected"] is True and record["first"] != record["held"],
            "Missing edge passed held guard",
        )


def validate(root: Path, manifest: dict) -> dict:
    require(manifest.get("version") == 1, "Unknown evidence version")
    inventory(manifest["routes"])
    require(bool(manifest.get("observers")), "Missing observer bindings")
    for name, digest in manifest["observers"].items():
        bound(root, name, digest)
    png_spec = importlib.util.spec_from_file_location(
        "png", root / "scripts/verify-sega-turns.py"
    )
    png = importlib.util.module_from_spec(png_spec)
    png_spec.loader.exec_module(png)
    assembler = manifest["assembler_producer"]
    require(
        assembler["version"] == "0.0.71"
        and assembler["before_lock_sha256"]
        == assembler["after_lock_sha256"]
        == assembler["committed_lock_sha256"],
        "Unqualified assembler producer",
    )
    captures = 0
    for row in manifest["routes"]:
        require(bool(row.get("files")), "Missing source/evidence bindings")
        for name, digest in row["files"].items():
            path = bound(root, name, digest)
            if path.suffix == ".png":
                header, raster = png.raster(path)
                require(bool(header) and bool(raster), "Empty decoded PNG")
                captures += 1
        folder = root / row["folder"]
        native = json.loads((folder / "verification/results.json").read_text())
        check_native(row, native)
        for name, digest in native["sources"].items():
            bound(root, name, digest)
        observer = row["observer"]
        require(
            native.get("observer_sha256", native["sources"].get(observer))
            == sha(root / observer),
            "Observer identity changed",
        )
        producer = manifest["producers"][row["producer"]]
        require(
            producer["version"] == "0.44.1"
            and producer["before_lock_sha256"]
            == producer["after_lock_sha256"]
            == producer["committed_lock_sha256"],
            "Unqualified native producer",
        )
        require(
            native["emulator_sha256"] == producer["executable_sha256"],
            "Wrong native executable",
        )
        if row["track"] == "assembly" and not row.get("mos"):
            ready = png.raster(folder / "verification/ready.png")
            pressed = png.raster(folder / "verification/pressed.png")
            restored = png.raster(folder / "verification/second-press.png")
            require(
                ready != pressed and ready == restored,
                "Visible input feedback failed to change/restore",
            )
        if row["track"] == "basic":
            basic_lines((folder / "demo.bas").read_text())
            if not row.get("sound_absent"):
                require(
                    (folder / "demo.bas").read_text()
                    == "".join(
                        (folder / n).read_text()
                        for n in (
                            "caller.bas",
                            "draw.bas",
                            "sound.bas",
                            "read-command.bas",
                        )
                    ),
                    "Caller/modules differ from executed program",
                )
        if row.get("fault_record"):
            fault = json.loads((root / row["fault_record"]).read_text())
            check_fault(row, fault)
            name = "stale-command.bas" if row["track"] == "basic" else "no-edge.asm"
            require(
                fault["source_sha256"] == sha(folder / "mistakes" / name),
                "Changed deliberate fault",
            )
            fault_observer = (
                "scripts/verify-column-basic-errors.py"
                if row["track"] == "basic"
                else "scripts/verify-column-edges.py"
            )
            require(
                fault["observer_sha256"] == sha(root / fault_observer),
                "Fault observer changed",
            )
        if not row.get("sound_absent"):
            working = pcm(folder / "verification/sound.wav")
            negative = pcm(folder / "verification/sound-negative.wav")
            baseline_path = folder / "verification/keyboard-baseline.wav"
            baseline = pcm(baseline_path) if baseline_path.exists() else None
            sound_guard(working, negative, baseline)
            if row.get("mos"):
                require(
                    native["sound_negative_rejected"] is True,
                    "Missing MOS muted control",
                )
    return {
        "machine_language_routes": len(manifest["routes"]),
        "input_routes": 26,
        "audio_routes": 24,
        "stock_without_speaker": 2,
        "native_captures": captures,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--manifest", type=Path, default=ROOT / "docs/column-expansion.json"
    )
    args = parser.parse_args()
    print(json.dumps(validate(ROOT, json.loads(args.manifest.read_text())), indent=2))


if __name__ == "__main__":
    main()
