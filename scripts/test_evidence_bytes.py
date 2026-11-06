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
import unittest.mock
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
K = module("gamekit", "check-gamekit.py")
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


class AmigaDisks(unittest.TestCase):
    """A gamekit Amiga caller: Asm198x builds the executable, build198x the ADF."""

    FOLDER = "commodore-amiga/patterns/assembly/rendering/animation-timeline"

    def rebuild(self, change: tuple[str, str] | None) -> None:
        record = json.loads(
            (ROOT / self.FOLDER / "verification/results.json").read_text()
        )
        config = record["configuration"]
        with tempfile.TemporaryDirectory() as temp:
            tree = Path(temp)
            copy(
                tree,
                self.FOLDER,
                "commodore-amiga/patterns/assembly/framework/turn-deadline",
            )
            folder = tree / self.FOLDER
            if change is not None:
                edit(folder / "component.inc", *change)
            K.V.TOPIC = "animation-timeline"
            build = E.make(
                folder,
                K.program("commodore-amiga").outputs,
                build198x=True,
            )
            case = record["cases"]["demo"]
            for output, field in (
                ("build/demo.adf", "program_zlib"),
                ("build/demo", "exe_zlib"),
            ):
                E.require_program(
                    build,
                    output,
                    config["assembler_sha256"],
                    recorded=zlib.decompress(bytes.fromhex(case[field])),
                    build198x=config["build198x_sha256"],
                )

    def test_comment_matches(self) -> None:
        self.rebuild(None)
        self.rebuild(
            ("animation_timeline_step:\n", "animation_timeline_step:\n; A note\n")
        )

    def test_changed_operand_is_stale(self) -> None:
        with self.assertRaisesRegex(AssertionError, "^Program bytes differ"):
            self.rebuild(
                (
                    "    move.b #0,d0\n    move.b d0,FRAME\n",
                    "    move.b #1,d0\n    move.b d0,FRAME\n",
                )
            )


class Assemblers(unittest.TestCase):
    def test_a_relative_tools_folder_is_made_absolute(self) -> None:
        """`make` runs in each pattern's folder, so the path must not be relative."""
        with unittest.mock.patch.dict("os.environ", {"CODE198X_TOOLS": "rel/tools"}):
            self.assertTrue(E.tools_dir().is_absolute())
            self.assertEqual(E.tools_dir(), Path("rel/tools").resolve())

    def test_unknown_pin_is_refused(self) -> None:
        with self.assertRaises(LookupError):
            E.release_for("0" * 64)

    def test_every_release_names_its_targets(self) -> None:
        """Asm198x releases name all four targets; every release names CI's."""
        for tag, release in E.releases().items():
            with self.subTest(tag=tag):
                self.assertLessEqual(set(release["targets"]), set(E.TARGETS))
                self.assertIn(E.CI_TARGET, release["targets"])
                if E.tool_of(tag) == "asm198x":
                    self.assertEqual(set(release["targets"]), set(E.TARGETS))

    def test_pin_must_name_the_right_tool(self) -> None:
        builder = E.releases()["build198x-v0.2.9"]["targets"]["aarch64-apple-darwin"]
        with self.assertRaisesRegex(LookupError, "which is not asm198x"):
            E.assembler(builder["executable_sha256"])

    def test_build198x_adf_pin_names_a_builder(self) -> None:
        """Recorders that write ADFs ran build198x or build198x-adf; both are builders."""
        adf = E.releases()["build198x-adf-v0.2.12"]["targets"][E.CI_TARGET]
        self.assertEqual(
            E.tool_of(E.release_for(adf["executable_sha256"])), "build198x-adf"
        )
        self.assertEqual(E.REPOSITORY["build198x-adf"], "build198x")
        with self.assertRaisesRegex(LookupError, "which is not asm198x"):
            E.assembler(adf["executable_sha256"])
        assembler = next(t for t in E.releases() if E.tool_of(t) == "asm198x")
        with self.assertRaisesRegex(LookupError, "which is not build198x"):
            E.builder(assembler)

    def test_build198x_pin_is_required_exactly_when_used(self) -> None:
        pin = next(t for t in E.releases() if E.tool_of(t) == "asm198x")
        builder = next(t for t in E.releases() if E.tool_of(t) == "build198x")
        with tempfile.TemporaryDirectory() as temp:
            uses = E.make(Path(temp), ("absent.adf",), build198x=True)
            plain = E.make(Path(temp), ("absent.bin",))
            with self.assertRaisesRegex(ValueError, "build198x pin"):
                E.rebuild(uses, pin)
            with self.assertRaisesRegex(ValueError, "build198x pin"):
                E.rebuild(plain, pin, builder)

    def test_typed_text_is_the_program(self) -> None:
        """Rule 2: any change to typed text, a REM included, differs."""
        listing = "10 PRINT 1\n"
        E.require_typed(listing, E.sha256(listing.encode()), "listing")
        for changed in ["10 PRINT 2\n", "10 PRINT 1\n20 REM NOTE\n", "10 PRINT  1\n"]:
            with (
                self.subTest(changed=changed),
                self.assertRaisesRegex(AssertionError, "^Typed program differs"),
            ):
                E.require_typed(changed, E.sha256(listing.encode()), "listing")

    def test_missing_output_fails(self) -> None:
        pin = next(iter(E.releases()))
        with tempfile.TemporaryDirectory() as temp:
            build = E.Build(Path(temp), ("true",), ("absent.bin",))
            with self.assertRaisesRegex(AssertionError, "did not write"):
                E.rebuild(build, pin)

    def test_function_build_calls_the_recorders_function(self) -> None:
        """A function build imports the script and calls it with the pinned tool."""
        pin = next(iter(E.releases()))
        with tempfile.TemporaryDirectory() as temp:
            script = Path(temp) / "build.py"
            script.write_text(
                "from pathlib import Path\n\n\n"
                "def build(assembler, name):\n"
                "    Path(name).write_text(assembler)\n"
            )
            build = E.function(
                script, "build", (E.ASSEMBLER, "out.txt"), Path(temp), ("out.txt",)
            )
            self.assertEqual(
                E.rebuild(build, pin)["out.txt"], str(E.assembler(pin)).encode()
            )


if __name__ == "__main__":
    unittest.main()
