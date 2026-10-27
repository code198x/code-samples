"""Challenge native-pixel projection and its publication identities."""

import copy
import importlib.util
import json
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location("capture_export", Path(__file__).with_name("export-blitz-depth-images.py"))
if spec is None or spec.loader is None:
    raise RuntimeError("Missing Blitz image exporter")
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)


class NativeImageTests(unittest.TestCase):
    def test_all_actual_captures(self):
        for topic in E.TOPICS:
            with self.subTest(topic=topic):
                E.check(topic)

    def test_unique_or_incomplete_pixels_rejected(self):
        first, second = bytes((0, 0, 0)), bytes((255, 255, 255))
        self.assertEqual(E.project(4, 1, 3, first * 2 + second * 2), (2, 1, 3, first + second))
        for width, height, channels, pixels in [(4, 1, 3, first + second * 3), (3, 1, 3, first * 3), (4, 0, 3, b""), (4, 1, 3, first * 3)]:
            with self.subTest(width=width, height=height, bytes=len(pixels)), self.assertRaises(AssertionError):
                E.project(width, height, channels, pixels)

    def test_changed_capture_manifest_rejected(self):
        for topic in E.TOPICS:
            original = json.loads((E.folder(topic) / "published-images.json").read_text())
            for field, value in [("raw_sha256", "0" * 64), ("published_sha256", "0" * 64), ("published_size", [1536, 576])]:
                with self.subTest(topic=topic, field=field):
                    record = copy.deepcopy(original)
                    record["working"][field] = value
                    with self.assertRaises(AssertionError):
                        E.check(topic, record)


if __name__ == "__main__":
    unittest.main()
