"""List the labels and constants each checkpoint adds or removes.

A checkpoint may contain only what its unit and the units before it teach, so
every name new at a checkpoint should be taught by the unit that uses it. This
audit reads the progression order from the module README and compares each
checkpoint's source with the previous one. It checks names, not teaching: a
reviewer still matches each new name against its lesson.
"""
import argparse
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
NAME = re.compile(r'^([A-Za-z_]\w*)(?::|\s+equ\b)', re.IGNORECASE)


def progression():
    table = (ROOT / 'README.md').read_text()
    return re.findall(r'^\| \[([\w-]+)\]\(checkpoints/', table, re.MULTILINE)


def names(checkpoint):
    source = (ROOT / 'checkpoints' / checkpoint / 'meteor-storm.asm').read_text()
    return [m[1] for line in source.splitlines() if (m := NAME.match(line))]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--json', action='store_true', help='Print JSON instead of text')
    args = parser.parse_args()
    report = []
    previous = []
    for checkpoint in progression():
        current = names(checkpoint)
        lines = len((ROOT / 'checkpoints' / checkpoint / 'meteor-storm.asm').read_text().splitlines())
        report.append({'checkpoint': checkpoint, 'lines': lines,
                       'new': [n for n in current if n not in previous],
                       'removed': [n for n in previous if n not in current]})
        previous = current
    if args.json:
        print(json.dumps(report, indent=2))
        return
    for entry in report:
        print(f"{entry['checkpoint']} ({entry['lines']} lines)")
        print('  new:     ' + (', '.join(entry['new']) or '-'))
        if entry['removed']:
            print('  removed: ' + ', '.join(entry['removed']))


if __name__ == '__main__':
    main()
