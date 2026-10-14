# SPDX-License-Identifier: MIT
"""Check relocation preserves logical data without reusing its copy algorithm."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from itertools import pairwise
from pathlib import Path

from rearrange import rearrange


def fixture() -> bytes:
    image = bytearray(194816)
    image[:34] = b"MV - CPCEMU Disk-File\r\nDisk-Info\r\n"
    image[48:52] = bytes([40, 1, 0, 19])
    raw = bytearray(b"\xe5" * 184320)
    raw[4608:4640] = b"\0DISK       \0\0\0\x02\x02" + bytes(15)
    raw[4640:4672] = b"\0DIAG    BIN\0\0\0\x80" + bytes(range(3, 19))
    raw[4672:4704] = b"\0DIAG    BIN\x01\0\0\x21" + bytes(range(19, 24)) + bytes(11)
    for block in range(2, 24):
        raw[4608 + block * 1024 : 5632 + block * 1024] = bytes([block]) * 1024
    for track in range(40):
        start = 256 + track * 4864
        image[start : start + 12] = b"Track-Info\r\n"
        image[start + 16 : start + 18] = bytes([track, 0])
        image[start + 20 : start + 24] = bytes([2, 9, 82, 229])
        for sector in range(9):
            at = start + 24 + sector * 8
            image[at : at + 8] = bytes([track, 0, sector + 1, 2, 0, 0, 0, 0])
        image[start + 256 : start + 4864] = raw[track * 4608 : (track + 1) * 4608]
    return bytes(image)


def disk_bytes(image: bytes) -> bytes:
    return b"".join(image[512 + t * 4864 : 512 + t * 4864 + 4608] for t in range(40))


class LayoutTests(unittest.TestCase):
    def test_all_layouts_preserve_each_logical_block_and_headers(self) -> None:
        original = fixture()
        for mode in (
            "fragmented",
            "reordered",
            "combined",
            "boundary",
            "full-directory",
        ):
            with self.subTest(mode=mode):
                output, report = rearrange(original, mode)
                self.assertEqual(rearrange(original, mode), (output, report))
                self.assertEqual(original, fixture())
                self.assertNotEqual(output, original)
                self.assertEqual(output[:256], original[:256])
                for track in range(40):
                    at = 256 + track * 4864
                    self.assertEqual(output[at : at + 256], original[at : at + 256])
                raw = disk_bytes(output)
                entries = [
                    raw[i : i + 32] for i in range(4608, 6656, 32) if raw[i] != 229
                ]
                code = sorted(
                    (e for e in entries if e[1:12] == b"DIAG    BIN"),
                    key=lambda e: e[12],
                )
                blocks = list(code[0][16:32]) + list(code[1][16:21])
                body = b"".join(raw[4608 + b * 1024 : 5632 + b * 1024] for b in blocks)
                self.assertEqual(
                    body, b"".join(bytes([b]) * 1024 for b in range(3, 24))
                )
                self.assertEqual(raw[6656:7680], bytes([2]) * 1024)
                slots = [i for i in range(64) if raw[4608 + i * 32] != 229]
                self.assertEqual(
                    slots,
                    list(range(64))
                    if mode == "full-directory"
                    else [0, 1, 63]
                    if mode == "boundary"
                    else [0, 1, 2]
                    if mode == "fragmented"
                    else [0, 2, 17],
                )
                if mode in ("fragmented", "combined"):
                    self.assertTrue(all(abs(a - b) > 1 for a, b in pairwise(blocks)))
                    self.assertTrue(any(a > b for a, b in pairwise(blocks)))
                if mode == "boundary":
                    self.assertEqual(blocks, [*range(3, 22), 174, 23])
                    # Independent physical addresses: both final allocatable
                    # sectors contain the original full block; trailing sector
                    # 9 and all container framing remain untouched.
                    self.assertEqual(raw[182784:183808], bytes([22]) * 1024)
                    self.assertEqual(raw[183808:], disk_bytes(original)[183808:])
                    self.assertEqual(raw[27136:28160], b"\xe5" * 1024)

    def test_full_directory_uses_distinct_files_without_changing_existing_data(
        self,
    ) -> None:
        original = fixture()
        output, report = rearrange(original, "full-directory")
        before, raw = disk_bytes(original), disk_bytes(output)
        self.assertEqual(raw[:4608], before[:4608])
        self.assertEqual(raw[6656:29184], before[6656:29184])
        self.assertEqual(raw[91648:], before[91648:])
        for index in range(61):
            entry = raw[4608 + 32 * index : 4640 + 32 * index]
            self.assertEqual(entry[1:12], f"FILL{index:04}BIN".encode())
            self.assertEqual(entry[12:16], bytes([0, 0, 0, 2]))
            self.assertEqual(entry[16:], bytes([24 + index]) + bytes(15))
            start = 29184 + 1024 * index
            data = raw[start : start + 1024]
            self.assertEqual(int.from_bytes(data[11:15], "little"), 129)
            self.assertEqual(int.from_bytes(data[16:18], "little"), 1)
            self.assertEqual(data[127], sum(data[:127]) % 256)
            self.assertEqual(data[128:256], bytes([index]) + bytes(127))
            self.assertEqual(data[256:], b"\xe5" * 768)
        self.assertEqual(raw[6560:6656], before[4608:4704])
        self.assertEqual(len(report["added_files"]), 61)
        # A destination containing data must not be silently overwritten.
        damaged = bytearray(original)
        damaged[31232] = 0  # Track 6, sector 4: first new allocation block.
        with self.assertRaisesRegex(ValueError, "not unused"):
            rearrange(damaged, "full-directory")

    def test_rejects_truncation_bad_directory_and_unknown_mode(self) -> None:
        original = fixture()
        damaged = bytearray(original)
        damaged[5452] = 2
        for image, mode in (
            (original[:-1], "combined"),
            (damaged, "combined"),
            (original, "unknown"),
        ):
            with self.assertRaises(ValueError):
                rearrange(image, mode)

    def test_cli_never_overwrites_source_or_existing_output(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "source.dsk"
            existing = Path(tmp) / "existing.dsk"
            source.write_bytes(fixture())
            existing.write_bytes(b"keep")
            for destination in (source, existing):
                result = subprocess.run(
                    [
                        sys.executable,
                        str(Path(__file__).with_name("rearrange.py")),
                        "combined",
                        str(source),
                        str(destination),
                    ],
                    capture_output=True,
                    check=False,
                    timeout=10,
                )
                self.assertNotEqual(result.returncode, 0)
            self.assertEqual(source.read_bytes(), fixture())
            self.assertEqual(existing.read_bytes(), b"keep")


if __name__ == "__main__":
    unittest.main()
