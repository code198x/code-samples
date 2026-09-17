"""Enter readable Drift listings through the Spectrum's ROM keyboard editor."""
import importlib.util
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
donor = ROOT.parents[1] / 'meet-basic/opening/verification/verify.py'
spec = importlib.util.spec_from_file_location('meet_basic_entry', donor)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class Spectrum(module.Spectrum):
    def text(self, text):
        symbols = {'<': 'r', '>': 't', '+': 'k', '-': 'j', '.': 'm',
                   ':': 'z', '*': 'b', '(': '8', ')': '9', '/': 'v',
                   '#': '3', '?': 'c', '!': '1'}
        for character in text:
            if character in symbols:
                self.key('symbol', symbols[character])
            else:
                super().text(character)

    def statement(self, line):
        normal = {'PRINT': 'p', 'LET': 'l', 'RUN': 'r', 'SAVE': 's',
                  'LOAD': 'j', 'INPUT': 'i', 'CLS': 'v', 'IF': 'u',
                  'GO TO': 'g', 'GO SUB': 'h', 'RETURN': 'y', 'BORDER': 'b',
                  'PLOT': 'q', 'DRAW': 'w', 'FOR': 'f', 'NEXT': 'n', 'DIM': 'd', 'RANDOMIZE': 't', 'POKE': 'o'}
        symbol = {'THEN': 'g', '<>': 'w', '>=': 'e', '<=': 'q', 'STOP': 'a', 'AT': 'i',
                  'TO': 'f', 'AND': 'y', 'OR': 'u'}
        extended = {'PI': 'm', 'SIN': 'q', 'COS': 'w', 'SQR': 'h', 'LEN': 'k', 'VAL': 'j', 'STR$': 'y', 'INT': 'r', 'ABS': 'g', 'RND': 't', 'INKEY$': 'n', 'USR': 'l', 'CHR$': 'u', 'PEEK': 'o', 'DATA': 'd', 'READ': 'a', 'RESTORE': 's'}
        shifted = {'PAPER': 'c', 'INK': 'x', 'LINE': '3', 'OVER': 'n'}
        tokens = sorted([*normal, *symbol, *extended, *shifted], key=len, reverse=True)
        pattern = '|'.join(re.escape(token) for token in tokens)
        # Token spaces are supplied by the ROM. Preserve all quoted strings and
        # the maintained source; compact only the stream of keyboard events.
        line = re.sub(r'"[^"\n]*"|(?:' + pattern + r') +',
                      lambda m: m[0] if m[0].startswith('"') else m[0].rstrip(), line)
        for part in re.split(r'("[^"]*"|' + pattern + ')', line):
            if part in normal:
                self.key(normal[part])
            elif part in symbol:
                self.key('symbol', symbol[part])
            elif part in extended:
                self.key('caps', 'symbol')
                self.key(extended[part])
            elif part in shifted:
                self.key('caps', 'symbol')
                self.key('symbol', shifted[part])
            else:
                self.text(part)
        self.enter()
        self.frames(60)

    def program_lines(self):
        """Read stored line numbers; a typed line is not proof of acceptance."""
        pointers = self.call('memory_read', addr=23627, len=10)['bytes']
        start = pointers[8] + 256 * pointers[9]
        end = pointers[0] + 256 * pointers[1]
        data = []
        for address in range(start, end, 128):
            data += self.call('memory_read', addr=address, len=min(128, end-address))['bytes']
        result = {}
        offset = 0
        while offset + 4 <= len(data):
            number = data[offset] * 256 + data[offset + 1]
            size = data[offset + 2] + 256 * data[offset + 3]
            result[number] = data[offset + 4:offset + 4 + size]
            offset += 4 + size
        return result

    def load_source(self, path):
        for line in path.read_text().splitlines():
            self.statement(line)
            number = int(line.split()[0])
            assert number in self.program_lines(), (line, self.screen())
            if number % 100 == 0: print('Entered through', number, flush=True)
        print('ROM entered', path.name, flush=True)
