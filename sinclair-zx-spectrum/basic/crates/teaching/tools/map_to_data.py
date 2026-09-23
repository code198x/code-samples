#!/usr/bin/env python3
"""Validate one Crates room and write BASIC DATA lines 8000–8070."""
import argparse
import os
from pathlib import Path
import sys
import tempfile

SYMBOLS = '-#.C*P+'


def convert(text):
    # Accept LF or CRLF files and one optional final newline; preserve spaces.
    text = text.replace('\r\n', '\n')
    if text.endswith('\n'):
        text = text[:-1]
    rows = text.split('\n')
    if len(rows) != 8:
        raise ValueError(f'expected 8 rows; found {len(rows)}')
    players = crates = goals = 0
    for row_number, row in enumerate(rows, 1):
        if len(row) != 8:
            raise ValueError(f'row {row_number}: expected 8 symbols; found {len(row)}')
        for column, symbol in enumerate(row, 1):
            if symbol not in SYMBOLS:
                raise ValueError(f'row {row_number}, column {column}: unknown symbol {symbol!r}; use {SYMBOLS}')
            players += symbol in 'P+'
            crates += symbol in 'C*'
            goals += symbol in '.*+'
    if players != 1:
        raise ValueError(f'expected exactly one player (P or +); found {players}')
    if crates == 0:
        raise ValueError('add at least one crate (C or *)')
    if crates != goals:
        raise ValueError(f'match crates and targets; found {crates} crates and {goals} targets')
    return ''.join(f'{8000 + index * 10} DATA "{row}"\n' for index, row in enumerate(rows))


def write_output(path, data):
    # Replace only after validation and a complete write beside the destination.
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode='w', encoding='ascii', newline='\n',
                                         dir=path.parent, delete=False) as stream:
            temporary = Path(stream.name)
            stream.write(data)
        os.replace(temporary, path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('map', type=Path, help='UTF-8 text file: eight rows of eight symbols')
    parser.add_argument('-o', '--output', type=Path, required=True, help='generated BASIC text file')
    args = parser.parse_args()
    try:
        if args.map.resolve() == args.output.resolve() or (args.output.exists() and args.map.samefile(args.output)):
            raise ValueError('input and output must be different files')
        data = convert(args.map.read_bytes().decode('utf-8'))
        write_output(args.output, data)
    except (OSError, UnicodeError, ValueError) as error:
        print(f'Error: {error}', file=sys.stderr)
        return 1
    print(f'Wrote {args.output}: 8 DATA lines. Check this room in the game.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
