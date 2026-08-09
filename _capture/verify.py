#!/usr/bin/env python3
"""Verify a versioned Code198x executable curriculum proof."""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import platform
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
    if manifest["machine"] != "commodore-amiga-asm":
        raise ProofFailure("schema v1 currently supports commodore-amiga-asm only")
    program = (manifest_path.parent.parent / manifest["program"]).resolve()
    if not program.is_relative_to(CODE_SAMPLES) or not program.is_file():
        raise ProofFailure(f"program is missing or escapes code-samples: {program}")
    for key in ("executable_sha256", "media_sha256"):
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
        if not item.get("locator") or item["locator"] not in text:
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


def verify_locked_revision(name: str, repo: Path, lock: dict[str, Any], report: dict[str, Any]) -> None:
    actual = git_revision(repo)
    expected = lock["repositories"][name]["revision"]
    actual.update(expected_revision=expected, matches_lock=actual.get("revision") == expected)
    report["repositories"][name] = actual
    if actual["available"] and not actual["matches_lock"]:
        raise ProofFailure(f"{name} is at {actual.get('revision')}, proof locks {expected}")


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
        report["repositories"]["code_samples"] = git_revision(CODE_SAMPLES)
        verify_locked_revision("asm198x", UMBRELLA / "Asm198x/asm198x", lock, report)
        verify_locked_revision("build198x", UMBRELLA / "Build198x/build198x", lock, report)
        if args.full:
            verify_locked_revision("emu198x", UMBRELLA / "Emu198x/emu198x", lock, report)
        add_stage(report, "revision-lock", "passed", lock=str(lock_path.relative_to(CODE_SAMPLES)))

        asm = tool_path("asm198x", "ASM198X", Path("Asm198x/asm198x/target/release/asm198x"), args.tool_root)
        build = tool_path("build198x", "BUILD198X", Path("Build198x/build198x/target/release/build198x"), args.tool_root)
        work = Path(tempfile.mkdtemp(prefix="198x-proof-"))
        source = (manifest_path.parent.parent / manifest["program"]).resolve()
        executable = work / manifest["build"]["executable"]
        media_a = work / manifest["build"]["media"]
        media_b = work / f"second-{manifest['build']['media']}"
        result = run([str(asm), "--dialect", "vasm", "--exe", str(source), "-o", str(executable)])
        if result.returncode:
            raise ProofFailure(f"Asm198x failed:\n{result.stderr}")
        exe_hash = sha256(executable)
        if exe_hash != manifest["build"]["executable_sha256"]:
            raise ProofFailure(f"executable hash mismatch: {exe_hash}")
        add_stage(report, "assemble", "passed", sha256=exe_hash, bytes=executable.stat().st_size)

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

        firmware = manifest["firmware"]
        if not args.full:
            add_stage(report, "execute", "skipped-restricted-input", requirement=firmware["environment"])
            report["result"] = "passed-public"
        else:
            firmware_value = os.environ.get(firmware["environment"])
            if not firmware_value:
                raise ProofFailure(f"full proof requires {firmware['environment']}")
            firmware_path = Path(firmware_value).expanduser().resolve()
            firmware_hash = sha256(firmware_path)
            if firmware_hash not in firmware["accepted_sha256"]:
                raise ProofFailure(f"unrecognised firmware hash: {firmware_hash}")
            emu = tool_path("emu198x-amiga", "EMU198X_AMIGA", Path("Emu198x/emu198x/target/release/emu198x-amiga"), args.tool_root)
            screenshot, script = work / "frame.png", work / "proof.script.json"
            script.write_text(json.dumps([
                {"action": "run_frames", "frames": manifest["execution"]["frames"]},
                {"action": "save_screenshot", "path": str(screenshot)},
            ], indent=2) + "\n")
            result = run([str(emu), "--headless", "--kickstart", str(firmware_path), "--model",
                          manifest["execution"]["model"], "--disk", str(media_a), "--script", str(script)])
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
