"""Small meaningful checks: format, combined symbols and failed-file safety."""
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

from map_to_data import convert

HERE = Path(__file__).resolve().parent
VALID = (HERE / 'room.txt').read_text()


class ConverterTests(unittest.TestCase):
    def test_matches_unchanged_loader_data(self):
        source = (HERE.parent / 'unit-08/steps/step-01.bas').read_text()
        expected = ''.join(line + '\n' for line in source.splitlines()
                           if 8000 <= int(line.split()[0]) <= 8070)
        self.assertEqual(convert(VALID), expected)
        self.assertEqual(convert(VALID.rstrip('\n')), expected)
        self.assertEqual(convert(VALID.replace('\n', '\r\n')), expected)

    def test_faults(self):
        cases = [
            (VALID.replace('#------#', '#-----#', 1), 'row 2: expected 8 symbols; found 7'),
            (VALID.replace('#------#', '#--X---#', 1), 'row 2, column 4: unknown symbol'),
            (VALID.replace('#------#', '#-- ---#', 1), 'row 2, column 4: unknown symbol'),
            (VALID + '\n', 'expected 8 rows; found 9'),
            (VALID.replace('P', '-'), 'expected exactly one player'),
            (VALID.replace('#------#', '#P-----#', 1), 'expected exactly one player'),
            (VALID.replace('C', '-'), 'add at least one crate'),
            (VALID.replace('.', '-'), 'match crates and targets'),
        ]
        for text, message in cases:
            with self.subTest(message=message):
                with self.assertRaises(ValueError) as error:
                    convert(text)
                self.assertIn(message, str(error.exception))

    def test_combined_symbols(self):
        # Already-delivered room is valid; player-on-target adds another goal.
        self.assertIn('*', convert(VALID.replace('.', '*').replace('C', '-')))
        self.assertIn('+', convert(VALID.replace('P', '+').replace('.', '-')))
        with self.assertRaisesRegex(ValueError, 'match crates and targets'):
            convert(VALID.replace('P', '+'))

    def test_cli_preserves_output_and_input_on_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / 'room.txt'
            output = Path(directory) / 'room.bas'
            source.write_text(VALID)
            def run(destination):
                return subprocess.run([sys.executable, str(HERE / 'map_to_data.py'),
                                       str(source), '-o', str(destination)], capture_output=True, text=True)
            self.assertEqual(run(output).returncode, 0)
            previous = output.read_bytes()
            source.write_text(VALID.replace('C', 'X'))
            failure = run(output)
            self.assertNotEqual(failure.returncode, 0)
            self.assertIn('row 5, column 4', failure.stderr)
            self.assertEqual(output.read_bytes(), previous)
            fresh = Path(directory) / 'fresh.bas'
            self.assertNotEqual(run(fresh).returncode, 0)
            self.assertFalse(fresh.exists())
            self.assertNotEqual(run(source).returncode, 0)
            self.assertIn('X', source.read_text())
            self.assertEqual(sorted(p.name for p in Path(directory).iterdir()), ['room.bas', 'room.txt'])


if __name__ == '__main__':
    unittest.main()
