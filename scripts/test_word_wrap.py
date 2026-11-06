"""Corruption controls for retained layout records, including rehashed bad data."""

from __future__ import annotations

import hashlib
import importlib.util
import json
import shutil
import tempfile
import unittest
import zlib
from collections.abc import Callable
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "layout_check", ROOT / "scripts/check-word-wrap.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class TextLayout(unittest.TestCase):
    def fixture(self) -> tuple[dict, Path, dict]:
        c = json.loads((C.S / "systems.json").read_text())[0]
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        folder = Path(tmp.name) / "verification"
        shutil.copytree(
            ROOT / c["folder"] / "patterns/assembly/rendering/word-wrap/verification",
            folder,
        )
        return c, folder, json.loads((folder / "results.json").read_text())

    def reject(self, c: dict, folder: Path, result: dict) -> None:
        (folder / "results.json").write_text(json.dumps(result))
        with self.assertRaises((AssertionError, KeyError, FileNotFoundError)):
            C.check(c, folder)

    def test_word_policy_examples(self) -> None:
        c = json.loads((C.S / "systems.json").read_text())[0]
        examples = [
            (b"ONE THREE FIVE", 7, 3, 40, 4),
            (b"ONE TWO", 7, 1, 56, 7),
            (b"ONE TWO", 3, 2, 24, 3),
            (b"ABCDE", 2, 3, 16, 1),
            (b"A\n\nB\n", 7, 3, 8, 1),
            (b"  A", 3, 1, 24, 3),
            (b"A   B", 3, 2, 24, 1),
            (b"   ", 1, 2, 8, 1),
        ]
        for text, columns, lines, width, last in examples:
            with self.subTest(text=text, columns=columns):
                grid = [bytearray(c["width"]) for _ in range(c["height"])]
                out = C.M.evaluate(
                    c,
                    grid,
                    {
                        "kind": "block",
                        "bytes": list(text),
                        "source_ptr": c["data"],
                        "font_ptr": 1024,
                        "rect": [0, 0, columns * 8, c["height"]],
                        "pitch": 8,
                        "align": 0,
                    },
                )
                self.assertTrue(out["accepted"])
                self.assertEqual(
                    (out["lines"], out["measured"], out["last_count"]),
                    (lines, width, last),
                )
                self.assertEqual(out["consumed"], len(text))

    def test_real_records(self) -> None:
        for c in json.loads((C.S / "systems.json").read_text()):
            self.assertGreater(C.check(c), 40)

    def test_missing_variant(self) -> None:
        c, f, r = self.fixture()
        r["variants"].pop("origin-fixed")
        self.reject(c, f, r)

    def test_rehashed_word_fault_cannot_be_good(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["break-fault"]["cases"][0]
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        C.M.evaluate(c, grid, o["request"])
        name = o["memory"]
        (f / name).write_bytes(zlib.compress(C.M.TEXT.P.packed(c, grid)))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_empty_cases(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"] = []
        self.reject(c, f, r)

    def retained(
        self, change: Callable[[dict[str, Any]], None], rejection: str | None = None
    ) -> None:
        """Check every machine's record after `change`, in a copy of its folder.

        With `rejection`, each check must fail with a message matching it.
        """
        for c in json.loads((C.V.S / "systems.json").read_text()):
            original = (
                ROOT
                / c["folder"]
                / "patterns/assembly/rendering/word-wrap/verification"
            )
            with (
                self.subTest(system=c["machine_id"]),
                tempfile.TemporaryDirectory() as name,
            ):
                folder = Path(name)
                shutil.copytree(original, folder, dirs_exist_ok=True)
                result = json.loads((folder / "results.json").read_text())
                change(result)
                (folder / "results.json").write_text(json.dumps(result))
                if rejection is None:
                    C.check(c, folder)
                else:
                    with self.assertRaisesRegex(AssertionError, rejection):
                        C.check(c, folder)

    def test_forged_program_is_rebuilt(self) -> None:
        """A consistent claim of other bytes is caught only by the rebuild."""

        def forge(r: dict[str, Any]) -> None:
            r["variants"]["customise"]["fixture_sha256"] = "0" * 64

        self.retained(forge, "^Program bytes differ")

    def test_source_digests_are_provenance(self) -> None:
        """Changed, added or removed source text alone does not make a record stale."""

        def rewrite(r: dict[str, Any]) -> None:
            r["sources"] = dict.fromkeys(list(r["sources"])[1:], "0" * 64)

        self.retained(rewrite)

    def test_incomplete_call(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"][0]["mailbox"] = "0400"
        self.reject(c, f, r)

    def test_missing_capture_even_when_manifest_removed(self) -> None:
        c, f, r = self.fixture()
        name = r["variants"]["positive"]["startup"].pop("capture")
        r["artifacts"].pop(name)
        self.reject(c, f, r)

    def test_rehashed_bitmap(self) -> None:
        c, f, r = self.fixture()
        name = r["variants"]["positive"]["cases"][0]["memory"]
        data = bytearray(zlib.decompress((f / name).read_bytes()))
        data[0] ^= 1
        (f / name).write_bytes(zlib.compress(data))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_fake_measurement(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["positive"]["cases"][0]
        data = bytearray.fromhex(o["context"])
        data[18] ^= 8
        o["context"] = data.hex()
        self.reject(c, f, r)

    def test_rehashed_fault_cannot_be_good_picture(self) -> None:
        c, f, r = self.fixture()
        o = r["variants"]["origin-fault"]["cases"][0]
        grid = [bytearray(c["width"]) for _ in range(c["height"])]
        C.M.evaluate(c, grid, o["request"])
        name = o["memory"]
        (f / name).write_bytes(zlib.compress(C.M.TEXT.P.packed(c, grid)))
        r["artifacts"][name] = hashlib.sha256((f / name).read_bytes()).hexdigest()
        self.reject(c, f, r)

    def test_font_changed(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["positive"]["cases"][0]["rom_font"] = "00" * 512
        self.reject(c, f, r)

    def test_repair_hash_changed(self) -> None:
        c, f, r = self.fixture()
        r["variants"]["width-fixed"]["fixture_sha256"] = "00" * 32
        self.reject(c, f, r)


if __name__ == "__main__":
    unittest.main()
