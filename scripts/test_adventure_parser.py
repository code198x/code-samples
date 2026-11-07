"""Configuration safety and independent contract-oracle checks."""

import copy
import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FOLDER = ROOT / "sinclair-zx-spectrum/patterns/assembly/input/two-word-parser"


def load(name, path):
    s = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(s)
    s.loader.exec_module(m)
    return m


V = load("vocabulary", FOLDER / "generate_vocabulary.py")
O = load("oracle", ROOT / "scripts/verify-adventure-parser.py")
E = load("evidence", ROOT / "scripts/check-pattern-evidence.py")


class ParserConfigurationTests(unittest.TestCase):
    def setUp(self):
        self.data = {
            "verbs": [{"word": "TAKE", "id": 3, "noun_policy": 1}],
            "nouns": [{"word": "LAMP", "id": 1}],
        }

    def test_explicit_aliases_and_exact_matches(self):
        for value in ["GET LIGHT", "get light", "  gEt  LiGhT "]:
            self.assertEqual(O.oracle(value), (0, 3, 1))
        self.assertEqual(O.oracle("GETTER LIGHT"), (5, 0, 0))
        self.assertEqual(O.oracle("GET LAM"), (6, 0, 0))
        self.assertEqual(
            O.oracle("TAKE ROCK"), (0, 3, 6)
        )  # presence is the game's decision

    def test_arity_error_precedence_and_bounds(self):
        for value, expected in [
            ("TAKE", 7),
            ("LOOK LAMP", 8),
            ("SEARCH", 0),
            ("TAKE LAMP EXTRA", 4),
            ("ZEBRA LAMP EXTRA", 4),
            ("LOOK\t", 3),
            (" " * 63, 1),
            (" " * 64, 2),
            ("L" + " " * 62, 0),
            ("N", 5),
        ]:
            self.assertEqual(O.oracle(value)[0], expected)
        self.assertEqual(O.oracle("TAKE " + chr(0)), (3, 0, 0))

    def test_bad_configuration_cannot_be_compiled(self):
        variants = []
        for section in ["verbs", "nouns"]:
            for field, value in [
                ("word", ""),
                ("word", "lower"),
                ("word", "A B"),
                ("word", "A" * 13),
                ("id", 0),
                ("id", 256),
                ("id", True),
                ("id", 1.5),
            ]:
                v = copy.deepcopy(self.data)
                v[section][0][field] = value
                variants.append(v)
            v = copy.deepcopy(self.data)
            v[section] *= 2
            variants.append(v)
            v = copy.deepcopy(self.data)
            v[section] *= 33
            variants.append(v)
        for arity in [-1, 3, True, 1.5]:
            v = copy.deepcopy(self.data)
            v["verbs"][0]["noun_policy"] = arity
            variants.append(v)
        v = copy.deepcopy(self.data)
        v["verbs"] = [
            {"word": "TAKE", "id": 3, "noun_policy": 1},
            {"word": "GET", "id": 3, "noun_policy": 0},
        ]
        variants.append(v)
        v = copy.deepcopy(self.data)
        v["verbs"][0]["noun_polciy"] = v["verbs"][0].pop("noun_policy")
        variants.append(v)
        variants += [{}, [], {"verbs": [], "nouns": []}]
        for value in variants:
            with self.subTest(value=value), self.assertRaises((ValueError, TypeError)):
                V.compile_tables(value)

    def test_valid_boundary_ids_and_empty_nouns(self):
        data = {
            "verbs": [
                {"word": f"V{i:02d}", "id": 255, "noun_policy": 2} for i in range(32)
            ],
            "nouns": [],
        }
        compiled = V.compile_tables(data)
        self.assertIn("noun_vocab:\n    defb 0", compiled)
        data["verbs"][0]["word"] = "ABCDEFGHIJKL"
        self.assertIn("defb 12,255,2", V.compile_tables(data))

    def test_failed_generation_does_not_replace_a_good_output(self):
        with tempfile.TemporaryDirectory() as d:
            source = Path(d) / "v.json"
            output = Path(d) / "v.inc"
            source.write_text(json.dumps(self.data))
            cmd = [
                sys.executable,
                str(FOLDER / "generate_vocabulary.py"),
                "--source",
                str(source),
                "--output",
                str(output),
            ]
            subprocess.run(cmd, check=True, capture_output=True)
            before = output.read_bytes()
            source.write_text('{"verbs":[],"nouns":[]}')
            result = subprocess.run(cmd, check=False, capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(output.read_bytes(), before)


class ParserEvidenceTests(unittest.TestCase):
    def parser_fixture(self, name: str) -> tuple[dict, dict]:
        selection = json.loads(E.PARSER_SELECTION.read_text())
        fixture = next(f for f in selection if f["name"] == name)
        return fixture, json.loads((ROOT / fixture["record"]).read_text())

    def test_forged_program_is_rebuilt(self):
        """A record claiming other program bytes is caught only by the rebuild."""
        for name in ["parser-basic", "parser-z80", "parser-callers"]:
            fixture, record = self.parser_fixture(name)
            program = next(iter(record["programs"]))
            record["programs"][program] = "0" * 64
            with (
                self.subTest(name=name),
                self.assertRaisesRegex(AssertionError, "^Program bytes differ"),
            ):
                E.require_programs(name, fixture["recorder"], record)

    def test_source_digests_are_provenance(self):
        """Rewritten source and recorder digests leave the programs valid."""
        for name in ["parser-basic", "parser-z80", "parser-callers"]:
            fixture, record = self.parser_fixture(name)
            record["sources"] = dict.fromkeys(record["sources"], "0" * 64)
            record["observer_sha256"] = "0" * 64
            with self.subTest(name=name):
                self.assertGreater(
                    E.require_programs(name, fixture["recorder"], record), 0
                )

    def test_record_set_is_complete_and_current(self):
        selection = json.loads(E.PARSER_SELECTION.read_text())
        result = E.inspect(ROOT, selection, E.PARSER_BINDINGS)
        self.assertEqual(result["failures"], [])
        self.assertEqual(result["bindings_checked"], 0)
        with self.assertRaises(ValueError):
            E.inspect(ROOT, selection[:-1], E.PARSER_BINDINGS)
        # A fixture that names no recorder and binds nothing checks nothing.
        del selection[0]["recorder"]
        self.assertTrue(E.inspect(ROOT, selection, E.PARSER_BINDINGS)["failures"])

    def test_failed_record_requires_requalification(self):
        selection = json.loads(E.PARSER_SELECTION.read_text())
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for item in selection:
                p = root / item["record"]
                p.parent.mkdir(parents=True, exist_ok=True)
                p.write_bytes((ROOT / item["record"]).read_bytes())
            p = root / selection[0]["record"]
            r = json.loads(p.read_text())
            r["status"] = "failed"
            p.write_text(json.dumps(r))
            self.assertTrue(E.inspect(root, selection, E.PARSER_BINDINGS)["failures"])


if __name__ == "__main__":
    unittest.main()
