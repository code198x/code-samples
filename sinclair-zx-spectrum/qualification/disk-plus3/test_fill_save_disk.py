# SPDX-License-Identifier: MIT
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from fill_save_disk import prepare
from rearrange import sector_bytes
from test_fill_save_directory import roundtrip_disk


class SaveDiskTests(unittest.TestCase):
    def test_allocation_exhaustion_leaves_directory_space(self) -> None:
        source = roundtrip_disk()
        original = sector_bytes(source)
        for free in (False, True):
            image, report = prepare(source, free_space=free)
            self.assertEqual(prepare(source, free_space=free), (image, report))
            data = sector_bytes(image)
            self.assertEqual(data[:4672], original[:4672])
            self.assertEqual(data[6656:8704], original[6656:8704])
            entries = [data[n : n + 32] for n in range(4608, 6656, 32)]
            occupied = [e for e in entries if e[0] != 229]
            self.assertEqual(len(occupied), 13)
            self.assertEqual(data[5024:6656], b"\xe5" * 1632)
            allocations = []
            for i, entry in enumerate(occupied[2:]):
                self.assertEqual(
                    entry[:15], b"\0" + f"FILL{i:04}BIN".encode() + bytes(3)
                )
                blocks = [b for b in entry[16:] if b]
                allocations.extend(blocks)
                self.assertEqual(entry[15] * 128, len(blocks) * 1024)
                content = b"".join(
                    data[4608 + b * 1024 : 5632 + b * 1024] for b in blocks
                )
                self.assertEqual(content[:11], b"PLUS3DOS\x1a\x01\0")
                self.assertEqual(int.from_bytes(content[11:15], "little"), len(content))
                self.assertEqual(
                    int.from_bytes(content[16:18], "little"), len(content) - 128
                )
                self.assertEqual(sum(content[:127]) % 256, content[127])
                self.assertEqual(content[128:], bytes([i]) * (len(content) - 128))
            end = 173 if free else 175
            self.assertEqual(allocations, list(range(4, end)))
            self.assertEqual(
                report["free_file_blocks"], 175 - len(set([0, 1, 2, 3] + allocations))
            )
            self.assertEqual(report["free_directory_slots"], 64 - len(occupied))
            self.assertEqual(data[4608 + end * 1024 :], original[4608 + end * 1024 :])
            self.assertEqual(source, roundtrip_disk())

    def test_rejects_unexpected_source_and_refuses_overwrite(self) -> None:
        source = roundtrip_disk()
        for offset in (48, 280, 5376 + 64, 5376 + 4096):
            bad = bytearray(source)
            bad[offset] ^= 1
            with self.subTest(offset=offset), self.assertRaises(ValueError):
                prepare(bytes(bad))
        with self.assertRaises(ValueError):
            prepare(source[:-1])
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "disk.dsk"
            path.write_bytes(source)
            proc = subprocess.run(
                [
                    sys.executable,
                    str(Path(__file__).with_name("fill_save_disk.py")),
                    str(path),
                    str(path),
                ],
                capture_output=True,
                check=False,
                timeout=10,
            )
            self.assertNotEqual(proc.returncode, 0)
            self.assertEqual(path.read_bytes(), source)
