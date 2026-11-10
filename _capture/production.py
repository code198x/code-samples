"""Verify a production: one build, run twice on every model it names.

A production record is a schema 2 proof manifest. Beside what a schema 1 proof
pins (tool revisions, a build that assembles identically twice, firmware), it
names every model the production supports, and for each one:

- how the tape is loaded (the machine's autoload, or explicit key steps for a
  machine whose menu the autoload can't drive);
- an end marker: a byte the program writes when it has finished, which must
  hold the expected value within a frame budget;
- reads: other bytes to check, such as the model the program detected;
- captures: frames, counted from the end of loading, whose PNG must match the
  recorded reference.

Each model runs twice, and the two runs must match each other before either is
compared with the record.

A control is another build of the same production, named with the models it
must fail on. Every full verify builds and runs it, and it must fail on exactly
those models and pass on the rest. A deliberately broken control keeps proving
the verifier can tell a mistimed effect from a right one; a harmless one, with
an empty list, proves the references don't break on changes that shouldn't
matter. A model that fails is reported and the rest still
run, so a timing fault shows which models it breaks.

Evidence cites published works only, by title and page or section, never a
path into a research library or a fingerprint of a scan.

`--record` writes the observed hashes into the record. Use it only after
watching the output and judging it right: the references are claims.
"""

from __future__ import annotations

import json
import re
import shutil
import tempfile
from pathlib import Path
from typing import Any

from verify import (
    CODE_SAMPLES,
    MACHINES,
    UMBRELLA,
    ProofFailure,
    add_stage,
    run,
    sha256,
    tool_path,
    verify_locked_revision,
)

# The research library's own folders, the knowledge graph and paths on a
# machine. A bare "reference/" is a Vault category and stays allowed.
PRIVATE = re.compile(
    r"(?<![\w.-])(?:/Users/|/home/[a-z]|/private/(?:tmp|var)/|/Volumes/)|~/Projects|Projects/198x|file://"
    r"|facts\.sqlite|knowledge\.py"
    r"|reference/(?:_meta|_quarantine|_raw-extracts|_recovered|_tools|by-system|by-topic|contextual)(?=[/\s\"')\],;:]|$)"
)
LOAD_SLOT = "tape-1"


def strings(value: Any, where: str = "") -> list[tuple[str, str]]:
    """Every string in a JSON value, with where it sits."""
    if isinstance(value, str):
        return [(where, value)]
    if isinstance(value, dict):
        return [item for key, inner in value.items() for item in strings(inner, f"{where}.{key}")]
    if isinstance(value, list):
        return [item for index, inner in enumerate(value) for item in strings(inner, f"{where}[{index}]")]
    return []


def validate_production(manifest: dict[str, Any], *, recording: bool = False) -> list[str]:
    """Problems with the record itself, before anything runs."""
    problems = []
    for key in ("id", "machine", "program", "lock"):
        if not manifest.get(key):
            problems.append(f"missing {key}")
    if manifest.get("machine") not in MACHINES:
        problems.append(f"unknown machine {manifest.get('machine')!r}")
    build = manifest.get("build", {})
    if build.get("format") != "tap" or not build.get("executable", "").endswith(".tap"):
        problems.append("build must name a .tap executable with format tap")
    if not recording and not re.fullmatch(r"[0-9a-f]{64}", build.get("executable_sha256", "")):
        problems.append("build needs its executable_sha256 (record it with --record)")
    for index, item in enumerate(manifest.get("evidence", [])):
        if set(item) - {"citation", "claim"} or not item.get("citation") or not item.get("claim"):
            problems.append(f"evidence[{index}] must be a citation of a published work and the claim it supports")
    for where, text in strings(manifest):
        if PRIVATE.search(text):
            problems.append(f"{where.lstrip('.')} names a private path: {text!r}")
    models = manifest.get("models", [])
    if not models:
        problems.append("a production names at least one model")
    seen = set()
    for model in models:
        name = model.get("model", "?")
        if name in seen:
            problems.append(f"{name} is listed twice")
        seen.add(name)
        end = model.get("end", {})
        if not {"address", "value", "within_frames"} <= set(end):
            problems.append(f"{name}: end needs address, value and within_frames")
        if not model.get("firmware"):
            problems.append(f"{name}: firmware must be pinned")
        ids = [capture.get("id") for capture in model.get("captures", [])]
        if len(ids) != len(set(ids)):
            problems.append(f"{name}: capture ids repeat")
        for capture in model.get("captures", []):
            if not 0 < capture.get("frame", 0) < end.get("within_frames", 0):
                problems.append(f"{name}: capture {capture.get('id')} must fall inside the frame budget")
            if not recording and not re.fullmatch(r"[0-9a-f]{64}", capture.get("png_sha256", "")):
                problems.append(f"{name}: capture {capture.get('id')} has no reference (record it with --record)")
    names = {model.get("model") for model in models}
    for control in manifest.get("controls", []):
        label = control.get("id", "?")
        if not control.get("program") or not isinstance(control.get("must_fail_on"), list):
            problems.append(f"control {label} needs a program and the models it must fail on (an empty list: none)")
        unknown = set(control.get("must_fail_on", [])) - names
        if unknown:
            problems.append(f"control {label} names models the production doesn't: {sorted(unknown)}")
    return problems


def build_tape(asm: Path, source: Path, name: str, folder: Path) -> Path:
    """Assemble a tape under a bare name: the tape's code block is named after it."""
    folder.mkdir(parents=True)
    result = run_in(folder, [str(asm), "--dialect", "pasmo", "--cpu", "z80", "--tapbas", str(source), "-o", name])
    if result.returncode:
        raise ProofFailure(f"Asm198x failed on {source.name}:\n{result.stderr}")
    return folder / name


def model_steps(model: dict[str, Any], frames_dir: Path, run_index: int) -> list[dict[str, Any]]:
    """The emulator script for one run on one model."""
    load = model.get("load", {"autoload": True})
    if load.get("autoload"):
        steps = [{"action": "autoload_tape", "slot": LOAD_SLOT, "max_boot_frames": load.get("max_boot_frames", 300)}]
    else:
        steps = list(load["steps"]) + [{"action": "media_transport", "slot": LOAD_SLOT, "transport": "start"}]
    elapsed = 0
    for capture in sorted(model.get("captures", []), key=lambda c: c["frame"]):
        steps.append({"action": "run_frames", "frames": capture["frame"] - elapsed})
        elapsed = capture["frame"]
        steps.append({"action": "save_screenshot",
                      "path": str(frames_dir / f"{model['model']}-run{run_index}-{capture['id']}.png")})
    steps.append({"action": "run_frames", "frames": model["end"]["within_frames"] - elapsed})
    steps.append({"action": "memory_read", "addr": model["end"]["address"], "len": 1})
    for read in model.get("reads", []):
        steps.append({"action": "memory_read", "addr": read["address"], "len": 1})
    return steps


def run_model(emu: Path, model: dict[str, Any], tape: Path, work: Path, run_index: int) -> dict[str, Any]:
    """Run one model once and return what it showed."""
    script = work / f"{model['model']}-run{run_index}.json"
    script.write_text(json.dumps(model_steps(model, work, run_index), indent=2) + "\n")
    result = run([str(emu), "--machine", model["model"], "--tape", str(tape), "--script", str(script)])
    if result.returncode:
        raise ProofFailure(f"Emu198x failed on {model['model']}:\n{result.stderr.strip()}")
    report = json.loads(result.stdout)
    bytes_read = [o["bytes"][0] for o in report["observations"] if o.get("kind") == "memory_read"]
    captures = {
        capture["id"]: sha256(work / f"{model['model']}-run{run_index}-{capture['id']}.png")
        for capture in model.get("captures", [])
    }
    return {
        "end": bytes_read[0],
        "reads": {read["label"]: value for read, value in zip(model.get("reads", []), bytes_read[1:])},
        "captures": captures,
    }


def check_firmware(model: dict[str, Any]) -> list[dict[str, str]]:
    checked = []
    for rom in model["firmware"]:
        path = Path(rom["path"]).expanduser()
        if not path.is_file():
            raise ProofFailure(f"{model['model']}: firmware missing at {rom['path']}")
        digest = sha256(path)
        if digest not in rom["accepted_sha256"]:
            raise ProofFailure(f"{model['model']}: unrecognised firmware {path.name} ({digest})")
        checked.append({"name": path.name, "sha256": digest})
    return checked


def judge_model(model: dict[str, Any], first: dict[str, Any], second: dict[str, Any], *, recording: bool) -> list[str]:
    """Failures for one model: runs that differ, an unreached end, wrong reads or captures."""
    failures = []
    if first != second:
        failures.append("two runs differ")
    if first["end"] != model["end"]["value"]:
        failures.append(f"end marker is {first['end']}, not {model['end']['value']}, after {model['end']['within_frames']} frames")
    for read in model.get("reads", []):
        if "expect" in read and first["reads"][read["label"]] != read["expect"]:
            failures.append(f"{read['label']} is {first['reads'][read['label']]}, not {read['expect']}")
    if not recording:
        for capture in model.get("captures", []):
            if first["captures"][capture["id"]] != capture["png_sha256"]:
                failures.append(f"capture {capture['id']} differs from the reference")
    return failures


def verify_production(manifest: dict[str, Any], manifest_path: Path, report: dict[str, Any], *,
                      full: bool, tool_root: Path | None, record: bool, keep_build: bool) -> None:
    """Fill the report; raise ProofFailure on the first fault that stops everything."""
    problems = validate_production(manifest, recording=record)
    if problems:
        raise ProofFailure("production record: " + "; ".join(problems))
    add_stage(report, "manifest", "passed", path=str(manifest_path.relative_to(CODE_SAMPLES)), schema_version=2)
    add_stage(report, "evidence", "passed", citations=len(manifest.get("evidence", [])))

    lock = json.loads((manifest_path.parent / manifest["lock"]).read_text())
    spec = MACHINES[manifest["machine"]]
    asm = tool_path("asm198x", "ASM198X", Path("Asm198x/asm198x/target/release/asm198x"), tool_root)
    emu = None
    if full:
        name, env, rel = spec["emulator"]
        emu = tool_path(name, env, Path(rel), tool_root)
    verify_locked_revision("asm198x", UMBRELLA / "Asm198x/asm198x", lock, report, binary=asm)
    if emu is not None:
        verify_locked_revision("emu198x", UMBRELLA / "Emu198x/emu198x", lock, report, binary=emu)
    add_stage(report, "revision-lock", "passed")

    work = Path(tempfile.mkdtemp(prefix="198x-production-"))
    try:
        source = (manifest_path.parent / manifest["program"]).resolve()
        name = manifest["build"]["executable"]
        # The tape's code block is named after the output, so build under a
        # bare name in the work directory: a path would end up on screen.
        outputs = [build_tape(asm, source, name, work / folder) for folder in ("a", "b")]
        if outputs[0].read_bytes() != outputs[1].read_bytes():
            raise ProofFailure("two clean assemblies differ")
        tape = outputs[0]
        digest = sha256(tape)
        if record:
            manifest["build"]["executable_sha256"] = digest
        elif digest != manifest["build"]["executable_sha256"]:
            raise ProofFailure(f"executable hash mismatch: {digest}")
        add_stage(report, "assemble", "passed", sha256=digest, bytes=tape.stat().st_size, deterministic=True)

        if not full:
            add_stage(report, "execute", "skipped-restricted-input", requirement="each model's firmware")
            report["result"] = "passed-public"
            return

        results, failed = {}, []
        for model in manifest["models"]:
            entry: dict[str, Any] = {}
            try:
                entry["firmware"] = check_firmware(model)
                first = run_model(emu, model, tape, work, 1)
                second = run_model(emu, model, tape, work, 2)
                entry.update(observed=first, failures=judge_model(model, first, second, recording=record))
                if record and not entry["failures"]:
                    for capture in model.get("captures", []):
                        capture["png_sha256"] = first["captures"][capture["id"]]
            except ProofFailure as error:
                entry["failures"] = [str(error)]
            entry["status"] = "failed" if entry["failures"] else "passed"
            if entry["failures"]:
                failed.append(model["model"])
            results[model["model"]] = entry
        add_stage(report, "execute", "failed" if failed else "passed", models=results)
        if failed:
            raise ProofFailure(f"failed on {', '.join(failed)}")

        controls, wrong = {}, []
        for control in manifest.get("controls", []):
            control_tape = build_tape(asm, (manifest_path.parent / control["program"]).resolve(), name,
                                      work / f"control-{control['id']}")
            outcome = {}
            for model in manifest["models"]:
                observed = run_model(emu, model, control_tape, work / f"control-{control['id']}", 1)
                outcome[model["model"]] = judge_model(model, observed, observed, recording=False)
            failed_on = sorted(m for m, failures in outcome.items() if failures)
            expected = sorted(control["must_fail_on"])
            controls[control["id"]] = {"must_fail_on": expected, "failed_on": failed_on, "detail": outcome}
            if failed_on != expected:
                wrong.append(f"control {control['id']} failed on {failed_on or 'nothing'}, expected {expected}")
        if manifest.get("controls"):
            add_stage(report, "controls", "failed" if wrong else "passed", controls=controls)
        if wrong:
            raise ProofFailure("; ".join(wrong))
        if record:
            manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
        report["result"] = "passed"
    finally:
        if not keep_build:
            shutil.rmtree(work, ignore_errors=True)


def run_in(cwd: Path, argv: list[str]):
    import subprocess

    return subprocess.run(argv, cwd=cwd, capture_output=True, text=True, check=False)
