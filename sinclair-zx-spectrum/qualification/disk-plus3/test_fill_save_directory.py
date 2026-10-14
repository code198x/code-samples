# SPDX-License-Identifier: MIT
from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from fill_save_directory import prepare
from rearrange import replace_sector_bytes, sector_bytes
from test_rearrange import fixture


def roundtrip_disk() -> bytes:
    image = fixture()
    raw = bytearray(sector_bytes(image))
    raw[4608:6656] = b"\xe5" * 2048
    raw[4608:4640] = b"\0DISK       \0\0\0\x03\x02" + bytes(15)
    raw[4640:4672] = b"\0DIAG    BIN\0\0\0\x03\x03" + bytes(15)
    raw[8704:] = b"\xe5" * (184320 - 8704)
    header = bytearray(128)
    header[:11] = b"PLUS3DOS\x1a\x01\0"
    header[11:22] = bytes.fromhex("0801000003880000800000")
    header[127] = sum(header[:127]) % 256
    raw[7680:7808] = header
    return replace_sector_bytes(image, raw)


class SaveDirectoryTests(unittest.TestCase):
    def test_full_directory_and_free_slot_preserve_existing_files_and_free_space(
        self,
    ) -> None:
        source = roundtrip_disk()
        original = sector_bytes(source)
        for free, count in ((False, 62), (True, 61)):
            output, report = prepare(source, free_slot=free)
            self.assertEqual(prepare(source, free_slot=free), (output, report))
            self.assertEqual(source, roundtrip_disk())
            data = sector_bytes(output)
            self.assertEqual(data[:4608], original[:4608])
            self.assertEqual(data[4608:4672], original[4608:4672])
            self.assertEqual(data[6656:8704], original[6656:8704])
            allocations = []
            for i in range(count):
                entry = data[4672 + i * 32 : 4704 + i * 32]
                self.assertEqual(entry[1:12], f"FILL{i:04}BIN".encode())
                self.assertEqual(entry[12:16], b"\0\0\0\2")
                block = entry[16]
                allocations.append(block)
                self.assertEqual(entry[17:], bytes(15))
                file = data[4608 + block * 1024 : 5632 + block * 1024]
                self.assertEqual(int.from_bytes(file[11:15], "little"), 129)
                self.assertEqual(sum(file[:127]) % 256, file[127])
                self.assertEqual(file[128], i)
                self.assertEqual(file[129:256], bytes(127))
                self.assertEqual(file[256:], b"\xe5" * 768)
            self.assertEqual(allocations, list(range(4, count + 4)))
            self.assertEqual(
                data[4672 + count * 32 : 6656], b"\xe5" * (32 * (62 - count))
            )
            self.assertEqual(
                data[4608 + (count + 4) * 1024 :], original[4608 + (count + 4) * 1024 :]
            )
            self.assertEqual(
                report["free_file_blocks"], 173 - len(set(allocations + [2, 3]))
            )
            self.assertEqual(report["directory_entries"], count + 2)

    def test_rejects_used_destination_bad_header_and_unexpected_directory(self) -> None:
        source = roundtrip_disk()
        for offset in (48, 256 + 24, 512 + 4864 + 64, 512 + 4864 + 4096):
            bad = bytearray(source)
            bad[offset] ^= 1
            with self.subTest(offset=offset), self.assertRaises(ValueError):
                prepare(bytes(bad))
        with self.assertRaises(ValueError):
            prepare(source[:-1])

    def test_cli_refuses_overwrite(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "disk.dsk"
            path.write_bytes(roundtrip_disk())
            proc = subprocess.run(
                [
                    sys.executable,
                    str(Path(__file__).with_name("fill_save_directory.py")),
                    str(path),
                    str(path),
                ],
                check=False,
                capture_output=True,
                timeout=10,
            )
            self.assertNotEqual(proc.returncode, 0)
            self.assertEqual(path.read_bytes(), roundtrip_disk())
