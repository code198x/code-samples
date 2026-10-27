"""Reject changed native Ace publication identities and decoded pixels."""

import importlib.util
import json
import unittest
from pathlib import Path
from unittest.mock import patch

spec = importlib.util.spec_from_file_location(
    "ace_exports", Path(__file__).with_name("export-ace-depth-images.py")
)
if spec is None or spec.loader is None:
    raise RuntimeError("Missing Ace exporter")
E = importlib.util.module_from_spec(spec)
spec.loader.exec_module(E)


class NativeImages(unittest.TestCase):
    def test_four_native_byte_identical_exports(self):
        for topic in E.TOPICS:
            E.check(topic)

    def test_manifest_controls(self):
        for topic in E.TOPICS:
            for field, value in (
                ("raw_sha256", "0" * 64),
                ("published_sha256", "0" * 64),
                ("published_size", [640, 288]),
            ):
                record = json.loads(
                    (E.folder(topic) / "published-images.json").read_text()
                )
                record["working"][field] = value
                with (
                    self.subTest(topic=topic, field=field),
                    self.assertRaises(AssertionError),
                ):
                    E.check(topic, record)
        with self.assertRaises(AssertionError):
            E.folder("other")

    def test_decode_and_geometry_controls(self):
        original = E.C.P.png
        for topic in E.TOPICS:
            for fault in ("geometry", "pixels"):

                def altered(path: Path, fault=fault):
                    w, h, channels, pixels = original(path)
                    if fault == "geometry":
                        return w - 1, h, channels, pixels
                    if path.name.startswith("published-"):
                        pixels = bytearray(pixels)
                        pixels[(48 * w + 32) * channels] ^= 1
                    return w, h, channels, pixels

                with (
                    self.subTest(topic=topic, fault=fault),
                    patch.object(E.C.P, "png", altered),
                    self.assertRaises(AssertionError),
                ):
                    E.check(topic)


if __name__ == "__main__":
    unittest.main()
