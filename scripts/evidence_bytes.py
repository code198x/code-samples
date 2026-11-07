"""Rebuild a record's program with the tools it pins and compare bytes.

A record is stale when its program's bytes change, not when the text of a
source or a script changes. A checker describes how its family builds each
program (the family's own Makefile or build.py, with the assembler passed in
`ASM198X` and build198x in `BUILD198X` as its recorder passes them), and this
module rebuilds that program with the Asm198x (and build198x) release the
record pins and compares the bytes with the record. The build198x a record
pins may be the main `build198x` binary or the separate `build198x-adf` one
the same repository releases; `{build198x}` names whichever it is. See
plans/2026-11-06-evidence-byte-check.md.

The record pins each tool by the digest of the binary it ran, usually a
macOS one. `evidence-assemblers.json` maps each Asm198x and build198x release
to every published target's archive and binary digests, taken from the
release's own source locks, or, for a release that publishes none, from its
`.sha256` files and the extracted binary. So the same release can be fetched
and verified on any host. A fetched binary is never run until both digests
match the table.

Command line:
  python3 scripts/evidence_bytes.py fetch <binary-sha256-or-tag>
  python3 scripts/evidence_bytes.py add-release asm198x-v0.0.74
  python3 scripts/evidence_bytes.py add-release build198x-v0.2.9
  python3 scripts/evidence_bytes.py add-release build198x-adf-v0.2.12
  python3 scripts/evidence_bytes.py call <script.py> <function> [args...]
"""

import argparse
import hashlib
import importlib.util
import json
import os
import platform
import shutil
import subprocess
import sys
import tarfile
import tempfile
import time
import urllib.error
import urllib.request
from collections.abc import Callable
from dataclasses import dataclass, field
from functools import cache
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RELEASES = Path(__file__).with_name("evidence-assemblers.json")
ASSEMBLER = "{asm198x}"
BUILDER = "{build198x}"
TOOLS = ("asm198x", "build198x", "build198x-adf")
BUILDERS = ("build198x", "build198x-adf")
# Each tool's GitHub organisation and repository; build198x-adf is released
# from the build198x repository.
REPOSITORY = {
    "asm198x": "asm198x",
    "build198x": "build198x",
    "build198x-adf": "build198x",
}
DOWNLOAD = "https://github.com/{repo}/{repo}/releases/download/{tag}/{name}"
CI_TARGET = "x86_64-unknown-linux-gnu"
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
    pinned assembler's path, and `{build198x}`, replaced with the pinned
    build198x's path. `outputs` are relative to `cwd`; each is deleted
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


def tool_of(tag: str) -> str:
    """The tool a release tag belongs to: `asm198x-v0.0.74` is Asm198x's."""
    name = tag.rpartition("-v")[0]
    if name not in TOOLS:
        raise LookupError(
            f"{tag} is not an Asm198x, build198x or build198x-adf release"
        )
    return name


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
    """Where downloaded tools are kept, as an absolute path.

    Builds run `make` in each pattern's folder, so a relative
    `CODE198X_TOOLS` would name a different place there.
    """
    return Path(
        os.environ.get("CODE198X_TOOLS", Path.home() / ".cache/code198x/tools")
    ).resolve()


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


def assembler(pin: str) -> Path:
    """Return a verified local binary of the Asm198x release this record pins."""
    return fetch("asm198x", pin)


def builder(pin: str) -> Path:
    """Return a verified local binary of the build198x release this record pins.

    The pin may name a `build198x` or a `build198x-adf` release; recorders
    that write Amiga ADFs have run either.
    """
    tool = tool_of(release_for(pin))
    if tool not in BUILDERS:
        raise LookupError(f"{pin} names {release_for(pin)}, which is not build198x")
    return fetch(tool, pin)


@cache
def fetch(tool: str, pin: str) -> Path:
    """Return a verified local binary of the `tool` release this pin names."""
    tag = release_for(pin)
    if tool_of(tag) != tool:
        raise LookupError(f"{pin} names {tag}, which is not {tool}")
    target = host_target()
    entry = releases()[tag]["targets"].get(target)
    if entry is None:
        raise LookupError(f"{tag} has no {target} binary in {RELEASES.name}")
    binary = tools_dir() / tag / target / tool
    if not binary.is_file():
        binary.parent.mkdir(parents=True, exist_ok=True)
        work = Path(tempfile.mkdtemp(dir=binary.parent))
        try:
            archive = work / entry["archive"]
            download(
                DOWNLOAD.format(repo=REPOSITORY[tool], tag=tag, name=entry["archive"]),
                archive,
            )
            if sha256(archive.read_bytes()) != entry["archive_sha256"]:
                raise AssertionError(
                    f"Downloaded {entry['archive']} for {tag} has the wrong digest"
                )
            with tarfile.open(archive) as tar:
                member = next(
                    m
                    for m in tar.getmembers()
                    if m.isfile() and Path(m.name).name == tool
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


def _uses(build: Build, placeholder: str) -> bool:
    return any(placeholder in part for part in build.command) or any(
        placeholder in value for _, value in build.env
    )


@cache
def rebuild(
    build: Build, pin: str | None, build198x: str | None = None
) -> dict[str, bytes]:
    """Run the build with the pinned tools and return each output's bytes.

    `pin` names the assembler, and may be None only for a build that runs
    no assembler (a BASIC program build198x tokenises); `build198x` names
    the build198x release, and is required exactly when the build uses
    `{build198x}`.

    Results are kept for the life of the process, so a checker that checks
    many records (and many altered copies of them) builds each program once.
    Tests that change a source must build from a copy in another folder.
    """
    if _uses(build, BUILDER) != (build198x is not None):
        raise ValueError("Pass a build198x pin exactly when the build runs {build198x}")
    if pin is None and _uses(build, ASSEMBLER):
        raise ValueError("Pass an assembler pin when the build runs {asm198x}")
    tools = {} if pin is None else {ASSEMBLER: str(assembler(pin))}
    if build198x is not None:
        tools[BUILDER] = str(builder(build198x))

    def fill(value: str) -> str:
        for placeholder, path in tools.items():
            value = value.replace(placeholder, path)
        return value

    for name in build.outputs:
        (build.cwd / name).unlink(missing_ok=True)
    result = subprocess.run(
        [fill(part) for part in build.command],
        check=False,
        cwd=build.cwd,
        env=os.environ | {k: fill(v) for k, v in build.env},
        capture_output=True,
        text=True,
        timeout=120,
    )
    if result.returncode != 0:
        raise AssertionError(
            f"Program no longer builds with the pinned tools in {build.cwd}:\n"
            + (result.stdout + result.stderr).strip()[-2000:]
        )
    missing = [name for name in build.outputs if not (build.cwd / name).is_file()]
    if missing:
        raise AssertionError(f"Build in {build.cwd} did not write {', '.join(missing)}")
    return {name: (build.cwd / name).read_bytes() for name in build.outputs}


def require_program(
    build: Build,
    output: str,
    pin: str | None,
    *,
    recorded_sha256: str | None = None,
    recorded: bytes | None = None,
    build198x: str | None = None,
    extract: Callable[[bytes], bytes] | None = None,
) -> bytes:
    """Rebuild `output` and require its bytes to match the record.

    Pass the recorded program bytes when the record keeps them, so a failure
    names the first differing offset; otherwise pass the recorded digest.
    Pass `build198x` when the build runs build198x (an Amiga ADF, say).
    Pass `extract` when the record keeps only part of the output, such as
    the block a tape loads, and compare that part.
    """
    if (recorded_sha256 is None) == (recorded is None):
        raise ValueError("Pass exactly one of recorded_sha256 and recorded")
    data = rebuild(build, pin, build198x)[output]
    label = (
        str((build.cwd / output).relative_to(ROOT))
        if build.cwd.is_relative_to(ROOT)
        else output
    )
    if extract is not None:
        data = extract(data)
        label += " (loaded block)"
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


def require_typed(text: str | bytes, recorded_sha256: str, label: str) -> None:
    """Require typed-in program text to match the record's digest (rule 2).

    The machine is given this text, BASIC or FORTH typed in at its prompt,
    so the text is the program: any change to it, a comment or REM
    included, makes the record stale. Pass the text as the recorder
    generates it, not a copy of the record's.
    """
    data = text.encode() if isinstance(text, str) else text
    if sha256(data) != recorded_sha256:
        raise AssertionError(
            f"Typed program differs from the record: {label} is now "
            f"{sha256(data)}, the record has {recorded_sha256}"
        )


def tap_block(index: int) -> Callable[[bytes], bytes]:
    """An `extract` for one ZX Spectrum TAP block's data, without flag or checksum.

    Asm198x names a TAP's CODE header after the path it was given, so a
    whole TAP built from absolute paths differs by checkout. The block a
    record keeps (the code the machine loads) does not.
    """

    def extract(data: bytes) -> bytes:
        blocks = []
        at = 0
        while at < len(data):
            length = int.from_bytes(data[at : at + 2], "little")
            blocks.append(data[at + 2 : at + 2 + length])
            at += 2 + length
        return blocks[index][1:-1]

    return extract


def make(folder: Path, outputs: tuple[str, ...], *, build198x: bool = False) -> Build:
    """A pattern Makefile run as its recorder runs it, always rebuilding.

    With `build198x`, the Makefile is also given `BUILD198X`, as recorders
    that write Amiga ADFs pass it.
    """
    command = ("make", "-B", "--no-print-directory", f"ASM198X={ASSEMBLER}")
    if build198x:
        command += (f"BUILD198X={BUILDER}",)
    return Build(folder, command, outputs)


def function(
    script: Path, name: str, args: tuple[str, ...], cwd: Path, outputs: tuple[str, ...]
) -> Build:
    """A build function in a Python file, called as its recorder calls it.

    The recorder imports `script` and calls `name(*args)`; this runs the same
    call in a fresh interpreter (`evidence_bytes.py call`), with `{asm198x}`
    in `args` replaced by the pinned assembler. `outputs` are relative to
    `cwd`, as for any build.
    """
    return Build(
        cwd,
        (
            sys.executable,
            str(Path(__file__).resolve()),
            "call",
            str(script),
            name,
            *args,
        ),
        outputs,
    )


def call(script: Path, name: str, args: list[str]) -> None:
    """Import `script` and call `name(*args)`, as `function()` builds run it."""
    spec = importlib.util.spec_from_file_location("evidence_build_script", script)
    if spec is None or spec.loader is None:
        raise ImportError(script)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    getattr(module, name)(*args)


def _fetch_text(url: str) -> str | None:
    """The asset's text, or None when the release does not publish it."""
    try:
        with urllib.request.urlopen(url, timeout=60) as response:
            return response.read().decode()
    except urllib.error.HTTPError as error:
        if error.code == 404:
            return None
        raise


def _emulator_version(path: str) -> tuple[str, str] | None:
    """The (name, version) an Emu198x emulator reports when it starts over MCP,
    or None when it does not answer (some builds need firmware to start)."""
    request = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "protocolVersion": "2025-06-18",
            "capabilities": {},
            "clientInfo": {"name": "evidence-bytes", "version": "1"},
        },
    }
    with subprocess.Popen(
        [path, "--mcp"],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
        text=True,
    ) as process:
        assert process.stdin and process.stdout
        try:
            process.stdin.write(json.dumps(request) + "\n")
            process.stdin.flush()
            reply = json.loads(process.stdout.readline())
            info = reply["result"]["serverInfo"]
        except (BrokenPipeError, json.JSONDecodeError, KeyError):
            return None
        finally:
            process.stdin.close()
            process.wait(timeout=30)
    return info["name"], info["version"]


def _emulator_release_by_digest(name: str, digest: str, target: str) -> str | None:
    """Search Emu198x releases' source locks for this binary; return the version."""
    for page in range(1, 4):
        listing = _fetch_text(
            "https://api.github.com/repos/emu198x/emu198x/releases"
            f"?per_page=100&page={page}"
        )
        releases = json.loads(listing) if listing else []
        for release in releases:
            version = release["tag_name"].removeprefix("v")
            if digest in _emulator_release_digests(name, version, target):
                return version
        if len(releases) < 100:
            break
    return None


def _emulator_release_digests(name: str, version: str, target: str) -> set[str]:
    """The executable digest an Emu198x release publishes for this target:
    from its source lock, or, for releases before source locks, by hashing
    the binary in its archive after checking the archive's `.sha256`."""
    base = f"https://github.com/emu198x/emu198x/releases/download/v{version}/"
    lock = _fetch_text(f"{base}{name}-{target}-source-lock.json")
    if lock is not None:
        return {json.loads(lock)["executable_sha256"]}
    archive = f"{name}-{target}.tar.gz"
    listed = _fetch_text(base + archive + ".sha256")
    if listed is None:
        return set()
    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        download(base + archive, work / archive)
        if sha256((work / archive).read_bytes()) != listed.split()[0]:
            raise ValueError(f"{name} {version}: archive does not match its .sha256")
        with tarfile.open(work / archive) as tar:
            member = next(
                m for m in tar.getmembers() if m.isfile() and Path(m.name).name == name
            )
            tar.extract(member, work / "x", filter="data")
        return {sha256((work / "x" / member.name).read_bytes())}


def tool_identity(path: str | Path) -> dict[str, str]:
    """Name a tool for a record by release identity, never by a local path.

    Asm198x and build198x come from the release table. An Emu198x emulator
    reports its version over MCP, and its digest is matched against that
    release's source lock; a build that matches no release says so. Any
    other tool, such as an oracle assembler, is named by the banner it prints
    and its digest.
    """
    found = shutil.which(str(path)) or str(path)
    digest = sha256(Path(found).read_bytes())
    identity = {"executable_sha256": digest}
    try:
        tag = release_for(digest)
    except LookupError:
        tag = None
    if tag:
        tool = tool_of(tag)
        target = next(
            t
            for t, entry in releases()[tag]["targets"].items()
            if entry["executable_sha256"] == digest
        )
        return {
            "tool": tool,
            "version": tag.removeprefix(f"{tool}-v"),
            "release": f"https://github.com/{REPOSITORY[tool]}/{REPOSITORY[tool]}/releases/tag/{tag}",
            "target": target,
            **identity,
        }
    name = Path(found).name
    if name.startswith("emu198x-"):
        target = host_target()
        reported = _emulator_version(found)
        if reported:
            name, version = reported
            released = digest in _emulator_release_digests(name, version, target)
        else:
            found_version = _emulator_release_by_digest(name, digest, target)
            version = found_version or "unknown"
            released = found_version is not None
        return {
            "tool": name,
            "version": version,
            "release": (
                f"https://github.com/emu198x/emu198x/releases/tag/v{version}"
                if released
                else "none: digest matches no published source lock"
            ),
            "target": target,
            **identity,
        }
    banner = subprocess.run(
        [found], capture_output=True, text=True, timeout=30, check=False
    )
    first = (banner.stdout or banner.stderr).splitlines()[:1]
    words = first[0].split() if first else []
    if len(words) >= 2 and words[1].startswith("v"):
        return {"tool": words[0], "version": words[1][1:], **identity}
    return {"tool": name, **identity}


def _unlocked_target(tool: str, tag: str, target: str) -> dict[str, str] | None:
    """Digests for a target of a release that publishes no source lock.

    The archive digest comes from the release's own `.sha256` file; the
    binary digest from hashing the binary extracted from that archive.
    """
    archive = f"{tool}-{target}.tar.xz"
    listed = _fetch_text(
        DOWNLOAD.format(repo=REPOSITORY[tool], tag=tag, name=archive + ".sha256")
    )
    if listed is None:
        return None
    archive_sha256 = listed.split()[0]
    with tempfile.TemporaryDirectory() as temp:
        work = Path(temp)
        download(
            DOWNLOAD.format(repo=REPOSITORY[tool], tag=tag, name=archive),
            work / archive,
        )
        if sha256((work / archive).read_bytes()) != archive_sha256:
            raise ValueError(f"{tag} {target}: archive does not match its .sha256")
        with tarfile.open(work / archive) as tar:
            member = next(
                m for m in tar.getmembers() if m.isfile() and Path(m.name).name == tool
            )
            tar.extract(member, work / "x", filter="data")
        executable = sha256((work / "x" / member.name).read_bytes())
    return {
        "archive": archive,
        "archive_sha256": archive_sha256,
        "executable_sha256": executable,
    }


def add_release(tag: str) -> None:
    """Add a release's per-target digests to the table.

    Digests come from the release's source locks; a release that publishes
    none (Asm198x before 0.0.67, build198x before 0.2.13) is read from its
    `.sha256` files and extracted binaries instead. A target the release does
    not publish is left out, but the CI target must be there.
    """
    tool = tool_of(tag)
    table = releases() if RELEASES.exists() else {}
    targets = {}
    commits = set()
    locked = 0
    for target in TARGETS:
        text = _fetch_text(
            DOWNLOAD.format(
                repo=REPOSITORY[tool], tag=tag, name=f"{tool}-{target}-source-lock.json"
            )
        )
        if text is None:
            unlocked = _unlocked_target(tool, tag, target)
            if unlocked is not None:
                targets[target] = unlocked
            continue
        lock = json.loads(text)
        if lock.get("kind") != "producer-source-lock" or lock.get("target") != target:
            raise ValueError(f"{tag} {target}: not a source lock for this target")
        if f"{tool}-v{lock['version']}" != tag:
            raise ValueError(f"{tag} {target}: lock names version {lock['version']}")
        commits.add(lock["source_commit"])
        locked += 1
        targets[target] = {
            "archive": lock["archive"],
            "archive_sha256": lock["archive_sha256"],
            "executable_sha256": lock["executable_sha256"],
        }
    if CI_TARGET not in targets:
        raise ValueError(f"{tag}: no {CI_TARGET} binary, so CI could not check it")
    if len(commits) > 1:
        raise ValueError(
            f"{tag}: targets were built from different commits {sorted(commits)}"
        )
    if commits and locked != len(targets):
        raise ValueError(f"{tag}: only some targets publish a source lock")
    table[tag] = {
        "source_commit": commits.pop() if commits else None,
        "targets": targets,
    }
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
    run = sub.add_parser("call", help="call a build function in a Python file")
    run.add_argument("script", type=Path)
    run.add_argument("function")
    run.add_argument("args", nargs="*")
    args = parser.parse_args()
    if args.command == "fetch":
        print(assembler(args.pin))
    elif args.command == "call":
        call(args.script, args.function, args.args)
    else:
        add_release(args.tag)
        print(f"Recorded {args.tag} in {RELEASES.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
