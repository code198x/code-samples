"""Guard the production record's rules without an emulator or ROMs."""

import copy
import json
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import production  # noqa: E402

FIXTURE = Path(__file__).parent / "fixtures/raster-stripes/proof.manifest.json"


class RecordTests(unittest.TestCase):
    def setUp(self) -> None:
        self.manifest = json.loads(FIXTURE.read_text())

    def problems(self, **changes) -> list[str]:
        manifest = copy.deepcopy(self.manifest) | changes
        return production.validate_production(manifest)

    def test_the_fixture_record_is_valid(self) -> None:
        self.assertEqual(production.validate_production(self.manifest), [])

    def test_evidence_cites_published_works_only(self) -> None:
        library = [{"path": "reference/by-system/x.txt", "sha256": "0" * 64, "claim": "A claim."}]
        self.assertTrue(any("citation of a published work" in p for p in self.problems(evidence=library)))
        quoted = [{"citation": "Read in /Users/someone/library/manual.pdf", "claim": "A claim."}]
        self.assertTrue(any("private path" in p for p in self.problems(evidence=quoted)))

    def test_every_model_needs_an_end_firmware_and_references(self) -> None:
        model = copy.deepcopy(self.manifest["models"][0])
        del model["end"]["within_frames"]
        self.assertTrue(any("end needs" in p for p in self.problems(models=[model])))
        model = copy.deepcopy(self.manifest["models"][0]) | {"firmware": []}
        self.assertTrue(any("firmware must be pinned" in p for p in self.problems(models=[model])))
        model = copy.deepcopy(self.manifest["models"][0])
        model["captures"][0]["png_sha256"] = ""
        self.assertTrue(any("no reference" in p for p in self.problems(models=[model])))
        alone = copy.deepcopy(self.manifest) | {"models": [model], "controls": []}
        self.assertEqual(production.validate_production(alone, recording=True), [])
        model["captures"][0]["frame"] = model["end"]["within_frames"]
        self.assertTrue(any("inside the frame budget" in p for p in self.problems(models=[model])))
        self.assertTrue(any("at least one model" in p for p in self.problems(models=[])))

    def test_a_control_names_only_the_productions_models(self) -> None:
        control = {"id": "x", "program": "stripes.asm", "must_fail_on": ["zx_next"]}
        self.assertTrue(any("models the production doesn't" in p for p in self.problems(controls=[control])))
        control = {"id": "x", "program": "stripes.asm"}
        self.assertTrue(any("needs a program and the models" in p for p in self.problems(controls=[control])))


class ScriptTests(unittest.TestCase):
    def setUp(self) -> None:
        self.manifest = json.loads(FIXTURE.read_text())

    def test_autoload_then_captures_then_the_end_marker(self) -> None:
        model = copy.deepcopy(self.manifest["models"][0])
        model["captures"] = [{"id": "late", "frame": 900}, {"id": "early", "frame": 300}]
        steps = production.model_steps(model, Path("/w"), 1)
        self.assertEqual(steps[0]["action"], "autoload_tape")
        frames = [s["frames"] for s in steps if s["action"] == "run_frames"]
        self.assertEqual(frames, [300, 600, model["end"]["within_frames"] - 900])
        shots = [s["path"] for s in steps if s["action"] == "save_screenshot"]
        self.assertEqual([Path(p).name for p in shots], [f"{model['model']}-run1-early.png", f"{model['model']}-run1-late.png"])
        reads = [s["addr"] for s in steps if s["action"] == "memory_read"]
        self.assertEqual(reads, [model["end"]["address"]] + [r["address"] for r in model["reads"]])

    def test_a_machine_with_a_menu_types_its_way_in_and_starts_the_tape(self) -> None:
        pentagon = next(m for m in self.manifest["models"] if m["model"] == "pentagon_128")
        steps = production.model_steps(pentagon, Path("/w"), 2)
        self.assertNotIn("autoload_tape", [s["action"] for s in steps])
        start = steps.index({"action": "media_transport", "slot": "tape-1", "transport": "start"})
        self.assertEqual(start, len(pentagon["load"]["steps"]))


class JudgeTests(unittest.TestCase):
    def setUp(self) -> None:
        self.model = json.loads(FIXTURE.read_text())["models"][1]
        self.good = {
            "end": self.model["end"]["value"],
            "reads": {"model detected": self.model["reads"][0]["expect"]},
            "captures": {"stripes": self.model["captures"][0]["png_sha256"]},
        }

    def judge(self, first, second=None, recording=False):
        return production.judge_model(self.model, first, second or first, recording=recording)

    def test_a_right_run_passes(self) -> None:
        self.assertEqual(self.judge(self.good), [])

    def test_each_fault_fails(self) -> None:
        other = copy.deepcopy(self.good) | {"end": 0}
        self.assertIn("two runs differ", self.judge(self.good, other))
        self.assertTrue(any("end marker" in f for f in self.judge(other)))
        wrong_model = copy.deepcopy(self.good)
        wrong_model["reads"]["model detected"] = 1
        self.assertTrue(any("model detected is 1" in f for f in self.judge(wrong_model)))
        slanted = copy.deepcopy(self.good)
        slanted["captures"]["stripes"] = "f" * 64
        self.assertTrue(any("differs from the reference" in f for f in self.judge(slanted)))
        # Recording takes new references, so it doesn't compare with the old ones.
        self.assertEqual(self.judge(slanted, recording=True), [])


if __name__ == "__main__":
    unittest.main()
