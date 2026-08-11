#!/usr/bin/env python3
"""Verify a versioned Code198x executable curriculum proof."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
import re
import shutil
import struct
import subprocess
import sys
import tempfile
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

CODE_SAMPLES = Path(__file__).resolve().parents[1]
UMBRELLA = Path(os.environ.get("ROOT198X", Path(__file__).resolve().parents[3])).resolve()
STATUSES = {"passed", "failed", "skipped-restricted-input", "not-applicable"}

# Per-machine proof chains. The Amiga assembles an executable and then masters a
# separate bootable ADF, so it needs Build198x. The Spectrum's assembler emits a
# runnable 48K snapshot in one step, so it has no media-mastering stage and no
# Build198x dependency — the chain is shorter, not weaker.
MACHINES = {
    "commodore-amiga-asm": {
        "dialect": "vasm",
        "emit": "--exe",
        "masters_media": True,
        "emulator": ("emu198x-amiga", "EMU198X_AMIGA", "Emu198x/emu198x/target/release/emu198x-amiga"),
        "load": "cli-disk",       # bootable medium handed to the emulator
        "model_flag": "--model",
        "boot": None,             # Kickstart boots the disk unaided
    },
    "sinclair-zx-spectrum-asm": {
        "dialect": "pasmonext",
        "emit": "--sna",
        "masters_media": False,
        "emulator": ("emu198x-spectrum", "EMU198X_SPECTRUM", "Emu198x/emu198x/target/release/emu198x-spectrum"),
        "load": "script-snapshot",  # snapshot restores a running machine
        "model_flag": "--machine",
        "boot": None,
    },
    "commodore-64-asm": {
        "dialect": "acme",
        "emit": "--prg",
        "masters_media": False,
        "emulator": ("emu198x-c64", "EMU198X_C64", "Emu198x/emu198x/target/release/emu198x-c64"),
        "load": "cli-load",       # PRG injected, but nothing starts it
        "model_flag": None,
        "boot": "type-run",       # so the proof must reach READY. and type RUN
    },
}

# A 48K .sna is a 27-byte register header followed by the full 48K of RAM.
SNA_48K_BYTES = 27 + 49152

# Cold-boot RUN timing, matching _capture/capture.py's type_run().
KEY_DOWN_FRAMES, KEY_UP_FRAMES, BOOT_SETTLE_FRAMES = 4, 3, 30


class ProofFailure(RuntimeError):
    pass


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def run(argv: list[str]) -> subprocess.CompletedProcess[str]:
    return subprocess.run(argv, text=True, capture_output=True, check=False)


def tool_path(name: str, env_name: str, sibling: Path, tool_root: Path | None) -> Path:
    candidates: list[Path] = []
    if os.environ.get(env_name):
        candidates.append(Path(os.environ[env_name]))
    if tool_root:
        candidates.append(tool_root / sibling)
    candidates.append(UMBRELLA / sibling)
    if shutil.which(name):
        candidates.append(Path(shutil.which(name) or ""))
    for candidate in candidates:
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return candidate.resolve()
    raise ProofFailure(f"{name} not found; set {env_name}, use --tool-root, or build {sibling}")


def locator_found(locator: str, text: str) -> bool:
    """Match an evidence locator ignoring how whitespace fell.

    The evidence corpus is OCR of scanned manuals, where runs of spaces and
    line breaks land arbitrarily inside a sentence — the same phrase can read
    "starting    at" on one pass and "starting\nat" on another. Matching the
    literal string would make every locator hostage to a scanning artefact
    rather than to what the page says, so the words must match in order with
    any whitespace between them.
    """
    words = locator.split()
    if not words:
        return False
    return re.search(r"\s+".join(re.escape(w) for w in words), text) is not None


def add_stage(report: dict[str, Any], name: str, status: str, **details: Any) -> None:
    if status not in STATUSES:
        raise AssertionError(status)
    report["stages"].append({"name": name, "status": status, **details})


def validate_manifest(manifest: dict[str, Any], manifest_path: Path) -> None:
    if manifest.get("schema_version") != 1:
        raise ProofFailure(f"unsupported schema_version: {manifest.get('schema_version')!r}")
    required = {"id", "machine", "lesson", "program", "evidence", "build", "firmware", "execution"}
    missing = sorted(required - manifest.keys())
    if missing:
        raise ProofFailure(f"manifest missing fields: {', '.join(missing)}")
    if manifest["machine"] not in MACHINES:
        raise ProofFailure(
            f"unsupported machine {manifest['machine']!r}; known: {', '.join(sorted(MACHINES))}")
    program = (manifest_path.parent.parent / manifest["program"]).resolve()
    if not program.is_relative_to(CODE_SAMPLES) or not program.is_file():
        raise ProofFailure(f"program is missing or escapes code-samples: {program}")
    keys = ["executable_sha256"]
    if MACHINES[manifest["machine"]]["masters_media"]:
        keys.append("media_sha256")
    for key in keys:
        value = manifest["build"].get(key, "")
        if len(value) != 64 or any(c not in "0123456789abcdef" for c in value):
            raise ProofFailure(f"build.{key} must be a lowercase SHA-256")


def validate_evidence(manifest: dict[str, Any], report: dict[str, Any], *, require_checkout: bool) -> None:
    checked = []
    for item in manifest["evidence"]:
        path = (UMBRELLA / item["path"]).resolve()
        declared_hash = item.get("sha256", "")
        if len(declared_hash) != 64 or any(c not in "0123456789abcdef" for c in declared_hash):
            raise ProofFailure(f"evidence SHA-256 is missing or malformed: {item['path']}")
        if not path.is_relative_to(UMBRELLA):
            raise ProofFailure(f"evidence path escapes family root: {item['path']}")
        if not path.is_file():
            if require_checkout:
                raise ProofFailure(f"evidence path not found: {item['path']}")
            checked.append({**item, "checkout_verified": False})
            continue
        text = path.read_text(errors="replace")
        if not item.get("locator") or not locator_found(item["locator"], text):
            raise ProofFailure(f"evidence locator not found in {item['path']}: {item.get('locator')!r}")
        actual_hash = sha256(path)
        if actual_hash != declared_hash:
            raise ProofFailure(f"evidence hash mismatch for {item['path']}: {actual_hash}")
        checked.append({**item, "checkout_verified": True})
    status = "passed" if all(item["checkout_verified"] for item in checked) else "not-applicable"
    add_stage(report, "evidence", status, sources=checked)


def png_dimensions(path: Path) -> list[int]:
    data = path.read_bytes()[:24]
    if len(data) != 24 or data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR":
        raise ProofFailure(f"not a PNG: {path}")
    return list(struct.unpack(">II", data[16:24]))


def git_revision(path: Path) -> dict[str, Any]:
    revision = run(["git", "-C", str(path), "rev-parse", "HEAD"])
    dirty = run(["git", "-c", "core.fsmonitor=false", "-C", str(path), "status", "--porcelain"])
    return {"available": revision.returncode == 0, "revision": revision.stdout.strip(), "dirty": bool(dirty.stdout.strip())}


def repo_for_binary(binary: Path | None) -> Path | None:
    """The git checkout a built tool came out of, if it came out of one.

    `target/release/<tool>` sits inside its own checkout, so walking up from
    the binary finds the revision that actually produced it.
    """
    if binary is None:
        return None
    for parent in binary.resolve().parents:
        if (parent / ".git").exists():
            return parent
    return None


def verify_locked_revision(name: str, repo: Path, lock: dict[str, Any], report: dict[str, Any],
                           *, binary: Path | None = None) -> None:
    """Check the locked revision against the checkout that built the tool.

    Falling back to the sibling checkout measures the wrong thing whenever the
    tool is supplied from elsewhere: a proof run against an explicitly-provided
    binary would be judged on whatever revision a neighbouring working tree
    happened to be sitting at, which for a repo under active development is
    both unrelated to the run and changing under it.
    """
    source = "sibling-checkout"
    from_binary = repo_for_binary(binary)
    if from_binary is not None:
        repo, source = from_binary, "binary"
    actual = git_revision(repo)
    expected = lock["repositories"][name]["revision"]
    actual.update(expected_revision=expected, matches_lock=actual.get("revision") == expected,
                  revision_source=source, checkout=str(repo))
    report["repositories"][name] = actual
    if actual["available"] and not actual["matches_lock"]:
        raise ProofFailure(
            f"{name} is at {actual.get('revision')} (from {source} {repo}), proof locks {expected}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--public", action="store_true")
    mode.add_argument("--full", action="store_true")
    parser.add_argument("--tool-root", type=Path)
    parser.add_argument("--report", type=Path)
    parser.add_argument("--keep-build", action="store_true")
    args = parser.parse_args()

    manifest_path = args.manifest.resolve()
    manifest = json.loads(manifest_path.read_text())
    report_path = (args.report or CODE_SAMPLES / "build/proofs" / f"{manifest.get('id', 'proof')}.json").resolve()
    report: dict[str, Any] = {
        "schema_version": 1, "proof_id": manifest.get("id"),
        "mode": "full" if args.full else "public", "started_at": datetime.now(UTC).isoformat(),
        "host": {"os": platform.system(), "architecture": platform.machine()}, "repositories": {}, "stages": [],
    }
    work: Path | None = None
    try:
        validate_manifest(manifest, manifest_path)
        add_stage(report, "manifest", "passed", path=str(manifest_path.relative_to(CODE_SAMPLES)))
        validate_evidence(manifest, report, require_checkout=args.full)
        lock_path = (manifest_path.parent / manifest.get("lock", "proof.lock.json")).resolve()
        lock = json.loads(lock_path.read_text())
        if lock.get("schema_version") != 1:
            raise ProofFailure("unsupported proof lock schema")
        spec = MACHINES[manifest["machine"]]
        report["repositories"]["code_samples"] = git_revision(CODE_SAMPLES)

        # Resolve every tool before judging any revision, so each lock is
        # checked against the checkout that built the binary being run.
        asm = tool_path("asm198x", "ASM198X", Path("Asm198x/asm198x/target/release/asm198x"), args.tool_root)
        build = None
        if spec["masters_media"]:
            build = tool_path("build198x", "BUILD198X", Path("Build198x/build198x/target/release/build198x"), args.tool_root)
        emu = None
        if args.full:
            emu_name, emu_env, emu_rel = spec["emulator"]
            emu = tool_path(emu_name, emu_env, Path(emu_rel), args.tool_root)

        verify_locked_revision("asm198x", UMBRELLA / "Asm198x/asm198x", lock, report, binary=asm)
        if build is not None:
            verify_locked_revision("build198x", UMBRELLA / "Build198x/build198x", lock, report, binary=build)
        if emu is not None:
            verify_locked_revision("emu198x", UMBRELLA / "Emu198x/emu198x", lock, report, binary=emu)
        add_stage(report, "revision-lock", "passed", lock=str(lock_path.relative_to(CODE_SAMPLES)))

        work = Path(tempfile.mkdtemp(prefix="198x-proof-"))
        source = (manifest_path.parent.parent / manifest["program"]).resolve()
        executable = work / manifest["build"]["executable"]
        second = work / f"second-{manifest['build']['executable']}"

        # Assemble twice from clean: the hash is only a claim if it repeats.
        for output in (executable, second):
            result = run([str(asm), "--dialect", spec["dialect"], spec["emit"], str(source), "-o", str(output)])
            if result.returncode:
                raise ProofFailure(f"Asm198x failed:\n{result.stderr}")
        if executable.read_bytes() != second.read_bytes():
            raise ProofFailure("two clean assemblies differ")
        exe_hash = sha256(executable)
        if exe_hash != manifest["build"]["executable_sha256"]:
            raise ProofFailure(f"executable hash mismatch: {exe_hash}")
        add_stage(report, "assemble", "passed", sha256=exe_hash,
                  bytes=executable.stat().st_size, deterministic=True)

        media_a = executable
        if spec["masters_media"]:
            media_a = work / manifest["build"]["media"]
            media_b = work / f"second-{manifest['build']['media']}"
            for output in (media_a, media_b):
                result = run([str(build), "adf", str(executable), "-o", str(output)])
                if result.returncode:
                    raise ProofFailure(f"Build198x failed:\n{result.stderr}")
            media_hash = sha256(media_a)
            if media_a.read_bytes() != media_b.read_bytes():
                raise ProofFailure("two clean ADF builds differ")
            if media_hash != manifest["build"]["media_sha256"]:
                raise ProofFailure(f"media hash mismatch: {media_hash}")
            adf = media_a.read_bytes()
            if len(adf) != 901120 or adf[:4] != b"DOS\0" or b"startup-sequence" not in adf or executable.name.encode() not in adf:
                raise ProofFailure("ADF structural check failed")
            add_stage(report, "master-media", "passed", sha256=media_hash, bytes=len(adf), deterministic=True)
        else:
            # No mastering step: the assembler emitted the runnable artefact, so
            # check it is structurally what the emulator expects.
            size = executable.stat().st_size
            detail: dict[str, Any] = {}
            if spec["emit"] == "--sna":
                if size != SNA_48K_BYTES:
                    raise ProofFailure(f"48K snapshot is {size} bytes, expected {SNA_48K_BYTES}")
                detail = {"snapshot_bytes": size}
            elif spec["emit"] == "--prg":
                # A PRG opens with its little-endian load address; $0801 is the
                # BASIC start, which is what makes RUN the right way to launch it.
                if size < 3:
                    raise ProofFailure(f"PRG is {size} bytes, too short to hold a load address")
                head = executable.read_bytes()[:2]
                load_address = head[0] | (head[1] << 8)
                expected = manifest["build"].get("load_address")
                if expected is not None and load_address != expected:
                    raise ProofFailure(
                        f"PRG loads at ${load_address:04X}, manifest expects ${expected:04X}")
                detail = {"prg_bytes": size, "load_address": f"${load_address:04X}"}
            add_stage(report, "master-media", "not-applicable",
                      reason="assembler emits the runnable artefact directly", **detail)

        firmware = manifest["firmware"]
        if not args.full:
            requirement = (firmware.get("environment")
                           or firmware.get("resolved_path")
                           or ", ".join(r["path"] for r in firmware.get("roms", []))
                           or "firmware")
            add_stage(report, "execute", "skipped-restricted-input", requirement=requirement)
            report["result"] = "passed-public"
        else:
            # The Amiga takes its Kickstart from an environment variable and is
            # passed it explicitly. emu198x-spectrum has no --rom flag: it
            # resolves the ROM itself from a fixed path, so the proof verifies
            # the ROM the emulator *will* load rather than handing one over.
            wanted: list[tuple[Path, list[str]]] = []
            if "environment" in firmware:
                firmware_value = os.environ.get(firmware["environment"])
                if not firmware_value:
                    raise ProofFailure(f"full proof requires {firmware['environment']}")
                wanted.append((Path(firmware_value).expanduser().resolve(),
                               firmware["accepted_sha256"]))
            elif "roms" in firmware:
                # The C64 boots from three ROMs, so one hash cannot pin the machine.
                for rom in firmware["roms"]:
                    wanted.append((Path(rom["path"]).expanduser().resolve(),
                                   rom["accepted_sha256"]))
            else:
                wanted.append((Path(firmware["resolved_path"]).expanduser().resolve(),
                               firmware["accepted_sha256"]))
            checked = []
            for fw_path, accepted in wanted:
                if not fw_path.is_file():
                    raise ProofFailure(f"full proof requires firmware at {fw_path}")
                fw_hash = sha256(fw_path)
                if fw_hash not in accepted:
                    raise ProofFailure(f"unrecognised firmware hash for {fw_path.name}: {fw_hash}")
                checked.append({"name": fw_path.name, "sha256": fw_hash})
            firmware_path = wanted[0][0]
            firmware_hash = checked[0]["sha256"]
            screenshot, script = work / "frame.png", work / "proof.script.json"
            steps: list[dict[str, Any]] = []
            if spec["load"] == "script-snapshot":
                steps.append({"action": "load_snapshot", "path": str(media_a)})
            if spec["boot"] == "type-run":
                # A PRG is only injected, never started. Wait for READY. and
                # type RUN, exactly as the capture pipeline does.
                steps.append({"action": "wait_for_boot",
                              "max_frames": manifest["execution"].get("boot_max_frames", 300)})
                for ch in ("R", "U", "N", "RETURN"):
                    steps.append({"action": "input", "events": [{"Key": {"name": ch, "pressed": True}}]})
                    steps.append({"action": "run_frames", "frames": KEY_DOWN_FRAMES})
                    steps.append({"action": "input", "events": [{"Key": {"name": ch, "pressed": False}}]})
                    steps.append({"action": "run_frames", "frames": KEY_UP_FRAMES})
                steps.append({"action": "run_frames", "frames": BOOT_SETTLE_FRAMES})
            steps += [
                {"action": "run_frames", "frames": manifest["execution"]["frames"]},
                {"action": "save_screenshot", "path": str(screenshot)},
            ]
            script.write_text(json.dumps(steps, indent=2) + "\n")

            argv = [str(emu), "--headless"]
            if spec["load"] == "cli-disk":
                argv += ["--kickstart", str(firmware_path), "--disk", str(media_a)]
            elif spec["load"] == "cli-load":
                argv += ["--load", str(media_a)]
            if spec["model_flag"]:
                argv += [spec["model_flag"], manifest["execution"]["model"]]
            argv += ["--script", str(script)]
            result = run(argv)
            if result.returncode:
                raise ProofFailure(f"Emu198x failed:\n{result.stderr}")
            frame_hash, dimensions = sha256(screenshot), png_dimensions(screenshot)
            if frame_hash != manifest["execution"]["frame_png_sha256"]:
                raise ProofFailure(f"frame hash mismatch: {frame_hash}")
            if dimensions != manifest["execution"]["frame_dimensions"]:
                raise ProofFailure(f"frame dimensions mismatch: {dimensions}")
            add_stage(report, "execute", "passed", firmware_sha256=firmware_hash,
                      frame_png_sha256=frame_hash, frame_dimensions=dimensions)
            report["result"] = "passed"
    except (OSError, KeyError, ValueError, json.JSONDecodeError, ProofFailure) as exc:
        report.update(result="failed", error=str(exc))
    finally:
        report["finished_at"] = datetime.now(UTC).isoformat()
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, indent=2, sort_keys=True) + "\n")
        if work and not args.keep_build:
            shutil.rmtree(work, ignore_errors=True)
    print(f"{report['result']}: {manifest.get('id')} ({report_path})")
    if report.get("error"):
        print(report["error"], file=sys.stderr)
    return 0 if report["result"] in {"passed", "passed-public"} else 1


if __name__ == "__main__":
    raise SystemExit(main())
