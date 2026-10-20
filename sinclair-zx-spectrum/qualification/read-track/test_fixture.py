# SPDX-License-Identifier: MIT
from __future__ import annotations

import unittest
from pathlib import Path

from fixture import (
    cases,
    command,
    make,
    missing_entry_case,
    n0_dtl_cases,
    n2_dtl_cases,
    reverse_size_case,
)


class FixtureTests(unittest.TestCase):
    def test_converts_boot_lengths_without_changing_payloads(self) -> None:
        base = bytearray(194816)
        base[:8] = b"MV - CPC"
        for i in range(39):
            start = 256 + i * 4864
            base[start : start + 12] = b"Track-Info\r\n"
            base[start + 256 : start + 4864] = bytes([i]) * 4608
        for case in cases():
            with self.subTest(case=case["id"]):
                image = make(bytes(base), case)
                self.assertEqual(len(command(case)), 9)
                self.assertEqual(image[48:50], base[48:50])
                for i in range(39):
                    start = 256 + i * 4864
                    self.assertEqual(
                        image[start + 256 : start + 4864],
                        base[start + 256 : start + 4864],
                    )
                    for s in range(9):
                        self.assertEqual(
                            image[start + 30 + s * 8 : start + 32 + s * 8],
                            bytes([0, 2]),
                        )
                self.assertEqual(len(image), 256 + sum(image[52:92]) * 256)

    def test_standalone_default_matches_first_case(self) -> None:
        source = Path(__file__).parent / "case.inc"
        values = list(
            map(int, source.read_text().strip().removeprefix("db ").split(","))
        )
        self.assertEqual(values, command(cases()[0]))

    def test_missing_entry_is_zero_table_and_no_track_block(self) -> None:
        base = bytearray(194816)
        base[:8] = b"MV - CPC"
        image = make(bytes(base), missing_entry_case())
        self.assertEqual(image[48:50], base[48:50])
        self.assertEqual(image[52:91], bytes([19]) * 39)
        self.assertEqual(image[91:256], bytes(165))
        self.assertEqual(len(image), 256 + 39 * 4864)
        for cylinder in range(39):
            start = 256 + cylinder * 4864
            self.assertEqual(
                image[start + 256 : start + 4864], base[start + 256 : start + 4864]
            )

    def test_command_and_native_sector_size_are_independent(self) -> None:
        base = bytearray(194816)
        base[:8] = b"MV - CPC"
        case = reverse_size_case()
        image = make(bytes(base), case)
        start = 256 + 39 * 4864
        self.assertEqual(command(case)[5], 2)
        self.assertEqual(
            image[start + 24 : start + 32], bytes([39, 0, 1, 0, 0, 0, 128, 0])
        )
        self.assertEqual(image[start + 256 : start + 384], bytes([33]) * 128)
        self.assertEqual(len(image), 256 + 39 * 4864 + 512)

    def test_nonzero_n_dtl_changes_only_the_last_command_byte(self) -> None:
        base = bytearray(194816)
        base[:8] = b"MV - CPC"
        standard, short = n2_dtl_cases()
        self.assertEqual(command(standard)[:-1], command(short)[:-1])
        self.assertEqual((command(standard)[-1], command(short)[-1]), (255, 1))
        image = make(bytes(base), standard)
        self.assertEqual(image, make(bytes(base), short))
        start = 256 + 39 * 4864
        self.assertEqual(
            image[start + 24 : start + 32], bytes([39, 0, 1, 2, 0, 0, 0, 2])
        )
        self.assertEqual(image[start + 256 : start + 768], bytes([33]) * 512)

    def test_all_five_n0_dtl_values_share_the_same_sector(self) -> None:
        base = bytearray(194816)
        base[:8] = b"MV - CPC"
        variants = [*cases()[:2], *n0_dtl_cases()]
        self.assertEqual(
            sorted(command(case)[-1] for case in variants), [0, 1, 127, 128, 255]
        )
        reference = variants[0]
        for case in variants:
            self.assertEqual(command(case)[:-1], command(reference)[:-1])
            image = make(bytes(base), case)
            self.assertEqual(image, make(bytes(base), reference))
            start = 256 + 39 * 4864
            self.assertEqual(
                image[start + 24 : start + 32], bytes([39, 0, 1, 0, 0, 0, 128, 0])
            )
            self.assertEqual(image[start + 256 : start + 384], bytes([33]) * 128)

    def test_wrong_base_rejected(self) -> None:
        for value in (b"", bytes(194816), b"MV - CPC"):
            with self.assertRaises(ValueError):
                make(value, cases()[0])


if __name__ == "__main__":
    unittest.main()
