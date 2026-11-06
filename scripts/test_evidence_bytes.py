"""Show that a record goes stale when its program's bytes change, and only then.

Each test copies a real pattern's sources into a temporary tree, edits the
copy, rebuilds it with the assembler the record pins, and compares the bytes
with the retained record.
"""

import importlib.util
import json
import shutil
import tempfile
import unittest
import zlib
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


def module(name: str, file: str) -> Any:
    spec = importlib.util.spec_from_file_location(name, Path(__file__).with_name(file))
    if spec is None or spec.loader is None:
        raise RuntimeError(file)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


E = module("evidence_bytes", "evidence_bytes.py")
A = module("additional_pools", "check-additional-object-pools.py")
N = module("native_pools", "check-object-pool.py")
POOL = "patterns/assembly/framework/object-pool"
SHARED = "cross-platform/patterns/framework"


def copy(tree: Path, *folders: str) -> None:
    for folder in folders:
        shutil.copytree(
            ROOT / folder,
            tree / folder,
            ignore=shutil.ignore_patterns("build", "verification", "README.md"),
        )


def edit(path: Path, old: str, new: str) -> None:
    text = path.read_text()
    if old not in text:
        raise AssertionError(f"{old!r} not in {path}")
    path.write_text(text.replace(old, new))


class AdditionalPools(unittest.TestCase):
    """BBC Micro and Atari 800XL pools, built by their shared build.py."""

    def rebuild(self, system: str, change: tuple[str, str] | None) -> None:
        record = json.loads(
            (ROOT / system / POOL / "verification/demo.json").read_text()
        )
        with tempfile.TemporaryDirectory() as temp:
            tree = Path(temp)
            copy(tree, f"{system}/{POOL}", f"{SHARED}/additional-object-pools")
            folder = tree / system / POOL
            if change is not None:
                edit(folder / "caller.inc", *change)
            E.require_program(
                A.program(folder, "demo"),
                "build/demo.bin",
                record["assembler_sha256"],
                recorded_sha256=record["program_sha256"],
            )

    def test_unchanged_sources_match(self) -> None:
        for system in ("bbc-micro", "atari-800xl"):
            with self.subTest(system=system):
                self.rebuild(system, None)

    def test_four_digit_zero_page_pointer_matches(self) -> None:
        """Reverting code198x/code-samples#424 leaves the bytes alone."""
        for system, ptr in (("bbc-micro", "70"), ("atari-800xl", "cb")):
            with self.subTest(system=system):
                self.rebuild(system, (f"ptr=${ptr}\n", f"ptr=$00{ptr}\n"))

    def test_comment_and_rename_match(self) -> None:
        for system in ("bbc-micro", "atari-800xl"):
            with self.subTest(system=system, change="comment"):
                self.rebuild(system, ("start:\n", "; A note for learners\nstart:\n"))
            with self.subTest(system=system, change="rename"):
                self.rebuild(system, ("main_a_done", "main_a_skip"))

    def test_changed_operand_is_stale(self) -> None:
        for system in ("bbc-micro", "atari-800xl"):
            with (
                self.subTest(system=system),
                self.assertRaisesRegex(AssertionError, "^Program bytes differ"),
            ):
                self.rebuild(system, ("lda #239\n", "lda #238\n"))


class NativePools(unittest.TestCase):
    """C64 and NES pools, built by their pattern Makefiles."""

    def rebuild(self, system: str, change: tuple[str, str] | None) -> None:
        record = json.loads(
            (ROOT / system / POOL / "verification/results.json").read_text()
        )
        with tempfile.TemporaryDirectory() as temp:
            tree = Path(temp)
            copy(tree, f"{system}/{POOL}", f"{SHARED}/object-pool")
            if system == "nintendo-entertainment-system":
                copy(tree, f"{system}/patterns/assembly/input/controller-reading")
            folder = tree / system / POOL
            if change is not None:
                edit(folder / "exercise.inc", *change)
            build, ext = N.program(folder, system)
            case = record["cases"]["demo"]
            E.require_program(
                build,
                "build/demo" + ext,
                record["configuration"]["assembler_sha256"],
                recorded=zlib.decompress(bytes.fromhex(case["program_zlib"])),
            )

    def test_comment_matches(self) -> None:
        for system in N.V.SYSTEMS:
            with self.subTest(system=system):
                self.rebuild(system, None)
                self.rebuild(system, ("\n", "\n; A note for learners\n"))

    def test_changed_operand_is_stale(self) -> None:
        for system in N.V.SYSTEMS:
            with (
                self.subTest(system=system),
                self.assertRaisesRegex(AssertionError, "^Program bytes differ"),
            ):
                self.rebuild(system, ("lda #$5a\n", "lda #$5b\n"))


class Assemblers(unittest.TestCase):
    def test_unknown_pin_is_refused(self) -> None:
        with self.assertRaises(LookupError):
            E.release_for("0" * 64)

    def test_every_release_names_every_target(self) -> None:
        for tag, release in E.releases().items():
            with self.subTest(tag=tag):
                self.assertEqual(set(release["targets"]), set(E.TARGETS))

    def test_missing_output_fails(self) -> None:
        pin = next(iter(E.releases()))
        with tempfile.TemporaryDirectory() as temp:
            build = E.Build(Path(temp), ("true",), ("absent.bin",))
            with self.assertRaisesRegex(AssertionError, "did not write"):
                E.rebuild(build, pin)


if __name__ == "__main__":
    unittest.main()
