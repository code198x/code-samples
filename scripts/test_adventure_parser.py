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
    def test_record_set_is_complete_and_current(self):
        selection = json.loads(E.PARSER_SELECTION.read_text())
        result = E.inspect(ROOT, selection, E.PARSER_BINDINGS)
        self.assertEqual(result["failures"], [])
        self.assertEqual(result["bindings_checked"], 27)
        with self.assertRaises(ValueError):
            E.inspect(ROOT, selection[:-1], E.PARSER_BINDINGS)
        selection[0]["bindings"].pop()
        self.assertTrue(E.inspect(ROOT, selection, E.PARSER_BINDINGS)["failures"])

    def test_changed_source_observer_and_failed_record_require_requalification(self):
        selection = json.loads(E.PARSER_SELECTION.read_text())
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            for item in selection:
                for name in [item["record"], *[b["path"] for b in item["bindings"]]]:
                    p = root / name
                    p.parent.mkdir(parents=True, exist_ok=True)
                    p.write_bytes((ROOT / name).read_bytes())
            for name in [
                selection[0]["bindings"][0]["path"],
                selection[0]["bindings"][-1]["path"],
            ]:
                p = root / name
                before = p.read_bytes()
                p.write_bytes(before + b"\nchanged\n")
                self.assertTrue(
                    E.inspect(root, selection, E.PARSER_BINDINGS)["failures"]
                )
                p.write_bytes(before)
            p = root / selection[0]["record"]
            r = json.loads(p.read_text())
            r["status"] = "failed"
            p.write_text(json.dumps(r))
            self.assertTrue(E.inspect(root, selection, E.PARSER_BINDINGS)["failures"])


if __name__ == "__main__":
    unittest.main()
