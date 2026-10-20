"""Prove retained evidence rejects drift, missing observations and rehashed bad data."""

from __future__ import annotations

import contextlib
import hashlib
import importlib.util
import io
import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "drawing_check", ROOT / "scripts/check-drawing-foundations.py"
)
assert spec and spec.loader
C = importlib.util.module_from_spec(spec)
spec.loader.exec_module(C)


class DrawingEvidence(unittest.TestCase):
    def fixture(self, system: str = "spectrum"):
        cfg = next(
            c
            for c in json.loads((C.S / "systems.json").read_text())
            if c["machine_id"] == system
        )
        td = tempfile.TemporaryDirectory()
        self.addCleanup(td.cleanup)
        root = Path(td.name)
        sub = (
            Path(cfg["folder"])
            / "patterns/assembly/rendering"
            / cfg["family"]
            / "verification"
        )
        shutil.copytree(ROOT / sub, root / sub)
        record = json.loads((root / sub / "results.json").read_text())
        for name in record["sources"]:
            (root / name).parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / name, root / name)
        return cfg, root, root / sub, record

    def reject(self, cfg, root):
        with (
            contextlib.redirect_stdout(io.StringIO()),
            self.assertRaises((AssertionError, FileNotFoundError, KeyError)),
        ):
            C.check(cfg, root)

    def test_unknown_system_cannot_pass_without_execution(self):
        result = subprocess.run(
            [
                sys.executable,
                str(ROOT / "scripts/verify-drawing-foundations.py"),
                "--native",
                "/not-used",
                "--assembler",
                "/not-used",
                "--system",
                "does-not-exist",
            ],
            check=False,
            capture_output=True,
            text=True,
            timeout=10,
        )
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("No matching system", result.stderr)

    def test_sources_must_match(self):
        cfg, root, _, record = self.fixture()
        p = root / next(iter(record["sources"]))
        p.write_text(p.read_text() + "\n; drift\n")
        self.reject(cfg, root)

    def test_no_empty_records(self):
        cfg, root, out, _ = self.fixture()
        (out / "results.json").write_text("{}")
        self.reject(cfg, root)

    def test_missing_snapshot(self):
        cfg, root, out, _ = self.fixture()
        (out / "positive-0.dat").unlink()
        self.reject(cfg, root)

    def test_missing_completed_fault(self):
        cfg, root, out, r = self.fixture()
        r["fault"]["fault_mismatches"] = 0
        (out / "results.json").write_text(json.dumps(r))
        self.reject(cfg, root)

    def test_changed_capture(self):
        cfg, root, out, _ = self.fixture()
        (out / "positive-6.png").write_bytes(b"broken")
        self.reject(cfg, root)

    def test_rehashed_bitmap_still_fails_oracle(self):
        cfg, root, out, r = self.fixture()
        name = "positive-0.dat"
        data = bytearray((out / name).read_bytes())
        data[20] ^= 1
        (out / name).write_bytes(data)
        digest = hashlib.sha256(data).hexdigest()
        r["artifacts"][name] = digest
        r["positive"]["cases"][0]["memory_sha256"] = digest
        (out / "results.json").write_text(json.dumps(r))
        self.reject(cfg, root)

    def test_rehashed_glyph_still_fails_oracle(self):
        cfg, root, out, r = self.fixture("game-boy")
        name = "positive-0.dat"
        data = bytearray((out / name).read_bytes())
        data[16:18] = data[16:18][::-1]
        (out / name).write_bytes(data)
        digest = hashlib.sha256(data).hexdigest()
        r["artifacts"][name] = digest
        r["positive"]["cases"][0]["memory_sha256"] = digest
        (out / "results.json").write_text(json.dumps(r))
        self.reject(cfg, root)

    def test_missing_call(self):
        cfg, root, out, r = self.fixture()
        r["positive"]["cases"].pop()
        (out / "results.json").write_text(json.dumps(r))
        self.reject(cfg, root)


if __name__ == "__main__":
    unittest.main()
