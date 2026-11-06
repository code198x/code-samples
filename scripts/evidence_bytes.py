"""Rebuild a record's program with the assembler it pins and compare bytes.

A record is stale when its program's bytes change, not when the text of a
source or a script changes. A checker describes how its family builds each
program (the family's own Makefile or build.py, with the assembler passed in
`ASM198X` as its recorder passes it), and this module rebuilds that program
with the Asm198x release the record pins and compares the bytes with the
record. See plans/2026-11-06-evidence-byte-check.md.

The record pins the assembler by the digest of the binary it ran, usually a
macOS one. `evidence-assemblers.json` maps each release to every target's
archive and binary digests, taken from the release's own source locks, so
the same release can be fetched and verified on any host. A fetched binary
is never run until both digests match the table.

Command line:
  python3 scripts/evidence_bytes.py fetch <binary-sha256-or-tag>
  python3 scripts/evidence_bytes.py add-release asm198x-v0.0.74
"""

import argparse
import hashlib
import json
import os
import platform
import shutil
import subprocess
import tarfile
import tempfile
import time
import urllib.request
from dataclasses import dataclass, field
from functools import cache
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RELEASES = Path(__file__).with_name("evidence-assemblers.json")
ASSEMBLER = "{asm198x}"
DOWNLOAD = "https://github.com/asm198x/asm198x/releases/download/{tag}/{name}"
TARGETS = (
    "aarch64-apple-darwin",
    "x86_64-apple-darwin",
    "x86_64-unknown-linux-gnu",
    "aarch64-unknown-linux-gnu",
)


@dataclass(frozen=True)
class Build:
    """One run of a family's own build, and the files it must write.

    `command` and `env` values may contain `{asm198x}`, replaced with the
    pinned assembler's path. `outputs` are relative to `cwd`; each is deleted
    before the build runs, so a build that writes nothing cannot pass by
    leaving an old file behind.
    """

    cwd: Path
    command: tuple[str, ...]
    outputs: tuple[str, ...]
    env: tuple[tuple[str, str], ...] = field(default=())


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def releases() -> dict[str, dict]:
    return json.loads(RELEASES.read_text())


def host_target() -> str:
    machine = platform.machine().lower()
    cpu = {
        "arm64": "aarch64",
        "aarch64": "aarch64",
        "x86_64": "x86_64",
        "amd64": "x86_64",
    }.get(machine)
    system = {"Darwin": "apple-darwin", "Linux": "unknown-linux-gnu"}.get(
        platform.system()
    )
    if cpu is None or system is None:
        raise LookupError(
            f"No Asm198x release target for {platform.system()} {machine}"
        )
    return f"{cpu}-{system}"


def release_for(pin: str) -> str:
    """Return the release tag whose binary, on any target, has this digest.

    A tag is accepted as well, for fetching ahead of a check.
    """
    table = releases()
    if pin in table:
        return pin
    for tag, release in table.items():
        if any(t["executable_sha256"] == pin for t in release["targets"].values()):
            return tag
    raise LookupError(
        f"Assembler {pin} is not a release in {RELEASES.name}; "
        "add it with `evidence_bytes.py add-release <tag>`"
    )


def tools_dir() -> Path:
    return Path(os.environ.get("CODE198X_TOOLS", Path.home() / ".cache/code198x/tools"))


def download(url: str, target: Path) -> None:
    for attempt in range(3):
        try:
            with (
                urllib.request.urlopen(url, timeout=60) as response,
                target.open("wb") as out,
            ):
                shutil.copyfileobj(response, out)
            return
        except OSError:
            if attempt == 2:
                raise
            time.sleep(2 * (attempt + 1))


@cache
def assembler(pin: str) -> Path:
    """Return a verified local binary of the Asm198x release this record pins."""
    tag = release_for(pin)
    target = host_target()
    entry = releases()[tag]["targets"].get(target)
    if entry is None:
        raise LookupError(f"{tag} has no {target} binary in {RELEASES.name}")
    binary = tools_dir() / tag / target / "asm198x"
    if not binary.is_file():
        binary.parent.mkdir(parents=True, exist_ok=True)
        work = Path(tempfile.mkdtemp(dir=binary.parent))
        try:
            archive = work / entry["archive"]
            download(DOWNLOAD.format(tag=tag, name=entry["archive"]), archive)
            if sha256(archive.read_bytes()) != entry["archive_sha256"]:
                raise AssertionError(
                    f"Downloaded {entry['archive']} for {tag} has the wrong digest"
                )
            with tarfile.open(archive) as tar:
                member = next(
                    m
                    for m in tar.getmembers()
                    if m.isfile() and Path(m.name).name == "asm198x"
                )
                tar.extract(member, work / "x", filter="data")
            extracted = work / "x" / member.name
            extracted.chmod(0o755)
            os.replace(extracted, binary)
        finally:
            shutil.rmtree(work, ignore_errors=True)
    if sha256(binary.read_bytes()) != entry["executable_sha256"]:
        raise AssertionError(f"{binary} is not the {tag} {target} binary")
    return binary


def _fill(value: str, path: Path) -> str:
    return value.replace(ASSEMBLER, str(path))


@cache
def rebuild(build: Build, pin: str) -> dict[str, bytes]:
    """Run the build with the pinned assembler and return each output's bytes.

    Results are kept for the life of the process, so a checker that checks
    many records (and many altered copies of them) builds each program once.
    Tests that change a source must build from a copy in another folder.
    """
    path = assembler(pin)
    for name in build.outputs:
        (build.cwd / name).unlink(missing_ok=True)
    result = subprocess.run(
        [_fill(part, path) for part in build.command],
        check=False,
        cwd=build.cwd,
        env=os.environ | {k: _fill(v, path) for k, v in build.env},
        capture_output=True,
        text=True,
        timeout=120,
    )
    if result.returncode != 0:
        raise AssertionError(
            f"Program no longer builds with the pinned assembler in {build.cwd}:\n"
            + (result.stdout + result.stderr).strip()[-2000:]
        )
    missing = [name for name in build.outputs if not (build.cwd / name).is_file()]
    if missing:
        raise AssertionError(f"Build in {build.cwd} did not write {', '.join(missing)}")
    return {name: (build.cwd / name).read_bytes() for name in build.outputs}


def require_program(
    build: Build,
    output: str,
    pin: str,
    *,
    recorded_sha256: str | None = None,
    recorded: bytes | None = None,
) -> bytes:
    """Rebuild `output` and require its bytes to match the record.

    Pass the recorded program bytes when the record keeps them, so a failure
    names the first differing offset; otherwise pass the recorded digest.
    """
    if (recorded_sha256 is None) == (recorded is None):
        raise ValueError("Pass exactly one of recorded_sha256 and recorded")
    data = rebuild(build, pin)[output]
    label = (
        str((build.cwd / output).relative_to(ROOT))
        if build.cwd.is_relative_to(ROOT)
        else output
    )
    if recorded is not None:
        if data != recorded:
            at = next(
                (
                    i
                    for i, (a, b) in enumerate(zip(data, recorded, strict=False))
                    if a != b
                ),
                min(len(data), len(recorded)),
            )
            raise AssertionError(
                f"Program bytes differ from the record: {label} at offset {at} "
                f"({len(data)} rebuilt, {len(recorded)} recorded)"
            )
    elif sha256(data) != recorded_sha256:
        raise AssertionError(
            f"Program bytes differ from the record: {label} rebuilds to {sha256(data)}, "
            f"the record has {recorded_sha256}"
        )
    return data


def make(folder: Path, outputs: tuple[str, ...]) -> Build:
    """A pattern Makefile run as its recorder runs it, always rebuilding."""
    return Build(
        folder, ("make", "-B", "--no-print-directory", f"ASM198X={ASSEMBLER}"), outputs
    )


def add_release(tag: str) -> None:
    """Add a release's per-target digests to the table from its source locks."""
    table = releases() if RELEASES.exists() else {}
    targets = {}
    commits = set()
    for target in TARGETS:
        with urllib.request.urlopen(
            DOWNLOAD.format(tag=tag, name=f"asm198x-{target}-source-lock.json"),
            timeout=60,
        ) as response:
            lock = json.load(response)
        if lock.get("kind") != "producer-source-lock" or lock.get("target") != target:
            raise ValueError(f"{tag} {target}: not a source lock for this target")
        if f"asm198x-v{lock['version']}" != tag:
            raise ValueError(f"{tag} {target}: lock names version {lock['version']}")
        commits.add(lock["source_commit"])
        targets[target] = {
            "archive": lock["archive"],
            "archive_sha256": lock["archive_sha256"],
            "executable_sha256": lock["executable_sha256"],
        }
    if len(commits) != 1:
        raise ValueError(
            f"{tag}: targets were built from different commits {sorted(commits)}"
        )
    table[tag] = {"source_commit": commits.pop(), "targets": targets}
    RELEASES.write_text(json.dumps(dict(sorted(table.items())), indent=2) + "\n")


def main() -> None:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("fetch", help="download and verify a pinned release").add_argument(
        "pin"
    )
    sub.add_parser("add-release", help="record a release's digests").add_argument("tag")
    args = parser.parse_args()
    if args.command == "fetch":
        print(assembler(args.pin))
    else:
        add_release(args.tag)
        print(f"Recorded {args.tag} in {RELEASES.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
