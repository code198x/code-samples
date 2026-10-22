import argparse
import importlib.util
import json
import subprocess
from pathlib import Path

r = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument("--native", type=Path, required=True)
args = parser.parse_args()
native = args.native.resolve()


def mod(name, path):
    s = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


V = mod("cols", r / "scripts/verify-column-hardware.py")
T = V.T
# Extra fresh cartridge starts observe a missing edge filter. The same held-input invariant must fail.
for row in json.loads((r / "docs/column-expansion.json").read_text())["routes"]:
    if row["track"] != "assembly" or row.get("mos"):
        continue
    system = row["system"]
    cfg = V.CONFIGS[system]
    folder = r / row["folder"]
    s = (folder / "demo.asm").read_text()
    if cfg["dialect"] == "acme":
        previous = "$81" if system == "atari-2600" else "previous"
        current = "$84" if system == "atari-2600" else "current"
        old = f"    lda {previous}\n    eor #$ff\n    and {current}"
        new = f"    lda {current}\n    nop\n    nop\n    nop\n    nop"
    else:
        old = "    cpl\n    and b\n    jr z,no_action"
        new = "    ld a,b\n    nop\n    jr z,no_action"
    T.require(s.count(old) == 1, f"{system}: ambiguous missing-edge mutation")
    wrong = folder / "mistakes/no-edge.asm"
    wrong.parent.mkdir(exist_ok=True)
    wrong.write_text(
        s.replace(old, new)
        .replace('"sample.inc"', '"../sample.inc"')
        .replace('"picture.inc"', '"../picture.inc"')
        .replace('"sound.inc"', '"../sound.inc"')
    )
    binary = (
        folder
        / "build"
        / (
            "no-edge.bin"
            if system == "tatung-einstein"
            else "no-edge." + cfg["extension"]
        )
    )
    subprocess.run(
        [
            str(native / "asm198x"),
            "--dialect",
            cfg["dialect"],
            *cfg["finalise"],
            str(wrong),
            "-o",
            str(binary),
        ],
        cwd=folder,
        check=True,
        capture_output=True,
    )
    if system.startswith("sega"):
        subprocess.run(
            ["python3", str(r / "scripts/build-sega-probe.py"), str(binary)],
            check=True,
            capture_output=True,
        )
    if system == "tatung-einstein":
        p = binary.with_suffix(".dsk")
        p.write_bytes(V.H.PACK.einstein_disk(binary.read_bytes()))
        binary = p
    command = [str(native / cfg["binary"]), "--mcp"]
    if cfg["flag"]:
        command += [cfg["flag"], str(binary)]
    if cfg.get("firmware"):
        command += [
            cfg.get("firmware_flag", "--bios"),
            str(Path.home() / ".emu198x/roms" / cfg["firmware"]),
        ]
    machine = T.Machine(command)
    try:
        machine.call("run_frames", frames=cfg.get("boot", 60))
        if system == "memotech-mtx":
            for line in V.H.PACK.basic_loader(binary.read_bytes()).splitlines():
                machine.call("type_string", text=line + "\n", settle_frames=60)
            machine.call("type_string", text="RUN\n", settle_frames=120)
            machine.call("run_frames", frames=900)
        elif system == "tatung-einstein":
            machine.call("load_media", slot="floppy-0", kind="disk", path=str(binary))
            for key, down, count in [
                ("control", True, 3),
                ("break", True, 6),
                ("break", False, 30),
                ("control", False, 300),
            ]:
                machine.call("input", events=[{"Key": {"name": key, "pressed": down}}])
                machine.call("run_frames", frames=count)
        machine.call("run_frames", frames=30)

        def state(machine=machine, cfg=cfg):
            return machine.call("memory_read", addr=cfg["ram"], len=1)["bytes"][0]

        T.require(state() == 0, f"{system}: broken edge invalid before input")
        event = (
            {"Key": {"name": cfg["button"], "pressed": True}}
            if cfg.get("key")
            else {"Button": {"port": 1, "name": cfg["button"], "pressed": True}}
        )
        machine.call("input", events=[event])
        machine.call("run_frames", frames=2)
        first = state()
        machine.call("run_frames", frames=30)
        held = state()
        T.require(first != held, f"{system}: missing edge passed held guard")
        image = folder / "verification/no-edge.png"
        machine.call("save_screenshot", path=str(image))
        record = {
            "observer_sha256": T.sha(Path(__file__)),
            "status": "passed",
            "system": system,
            "fault": "held state used in place of a new-press mask",
            "first": first,
            "held": held,
            "held_guard_rejected": True,
            "source_sha256": T.sha(wrong),
            "binary_sha256": T.sha(binary),
            "image_sha256": T.sha(image),
            "emulator_sha256": T.sha(native / cfg["binary"]),
        }
        (folder / "verification/no-edge.json").write_text(
            json.dumps(record, indent=2) + "\n"
        )
        print("PASS missing edge", system, first, held, flush=True)
    finally:
        machine.close()
