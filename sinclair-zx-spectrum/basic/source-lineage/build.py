#!/usr/bin/env python3
"""Write or re-verify lineage.json: earlier listing hashes linked to current ones.

Each Spectrum BASIC listing that the listed-form sweep changed gets one link
from its pre-sweep SHA-256 to its SHA-256 in the working tree. A listing that
also had a variable renamed first gets two links: pre-sweep text to renamed
text, then renamed text to the working tree. The hashes come from git
(`git show <commit>:<path>`) and from the files on disk.

Proof for a `space-only` link: both texts are tokenised with the listing
tokeniser, and the new stored bytes must be the old ones with 0x20 bytes
removed, never inside a string or after REM, and with every hidden number
unchanged. Any other difference fails.

Proof for a `renamed-variable` link: the renamed text must be the earlier text
with the named variables replaced as whole lowercase words, and nothing else.

usage:
  build.py --tokeniser <exe>            verify lineage.json (exit 1 on any mismatch)
  build.py --tokeniser <exe> --write    rewrite lineage.json
  [--pre-listing-tokeniser <exe>]       also rerun the check with the tokeniser
                                        from before the listing-form work
                                        (format198x caa48b3), with its INK/TO
                                        allowance; without it the recorded
                                        results are kept

<exe> takes a listing path and writes the stored program bytes to stdout, as
format198x-sinclair-zx-spectrum-bas's `tokenise_listing` example does:
  cargo build --release -p format198x-sinclair-zx-spectrum-bas --example tokenise_listing
  (in format198x at tag format198x-sinclair-zx-spectrum-bas-v0.1.2)
"""
import argparse
import hashlib
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
OUT = HERE / 'lineage.json'
PRE_SWEEP = 'b9594324754ffa177fb03e0e16443d0b80dcd0de'
SWEEP = '01a22769a2349948c310ff821a2185274a21fbc4'
TOKENISER = 'format198x-sinclair-zx-spectrum-bas 0.1.2, examples/tokenise_listing'
PRE_LISTING_TOKENISER = 'format198x-sinclair-zx-spectrum-bas at format198x caa48b3'
RENAMES = [
    ('fe5fe6d135e88cb5947be2f59365c495364408f1', 'sinclair-zx-spectrum/basic/night-patrol/',
     {'paper': 'shade'}),
    ('260ee72177f5d2fc4cbfd663dd8afc0a8fc72262', 'sinclair-zx-spectrum/basic/quickstep/',
     {'ink': 'colour', 'paper': 'shade'}),
]
# ROM boot of each renamed program: a tape of the earlier and of the renamed
# listing (the pre-listing tokeniser for both), genuine 48K ROM SHA1 5ea7c2b8,
# @emu198x/zx-spectrum 0.4.0, 25 s after load and again after pressing S.
# The earlier tape stores the second `ink`/`paper` as the keyword; typed on
# the ROM (as the evidence harnesses do) it is a variable.
BOOT = {
    'night-patrol/prototype/night-patrol.bas': 'title screen RAM identical before and after; no report (line 2080 not reached)',
    'night-patrol/teaching/finished/night-patrol.bas': 'title screen RAM identical before and after; no report (line 2080 not reached)',
    'quickstep/prototype/quickstep.bas': 'before: C Nonsense in BASIC, 1210:1 after S; after: board drawn, no report',
    'quickstep/teaching/finished/quickstep.bas': 'before: C Nonsense in BASIC, 1210:1 after S; after: board drawn, no report',
    'quickstep/teaching/board/quickstep.bas': 'before: C Nonsense in BASIC, 3020:1; after: board drawn, 9 STOP statement, 190:1',
    'quickstep/teaching/walk/quickstep.bas': 'before: C Nonsense in BASIC, 3020:1; after: board drawn, no report',
}
for name in ('mission', 'movement', 'patrol', 'scans', 'sight', 'stealth'):
    BOOT[f'night-patrol/teaching/{name}/night-patrol.bas'] = 'before: C Nonsense in BASIC, 2080:1; after: board drawn, no report'
for name in ('lane', 'clock', 'crossing', 'six-lanes', 'buffered'):
    BOOT[f'quickstep/teaching/{name}/quickstep.bas'] = 'before: C Nonsense in BASIC, 1210:1; after: board drawn, no report'


def git(*args):
    return subprocess.run(['git', '-C', str(REPO), *args], check=True, capture_output=True).stdout


def at(commit, path):
    return git('show', f'{commit}:{path}')


def sha(data):
    return hashlib.sha256(data).hexdigest()


def tokenise(exe, text):
    with tempfile.NamedTemporaryFile('wb', suffix='.bas') as f:
        f.write(text)
        f.flush()
        run = subprocess.run([exe, f.name], capture_output=True)
    if run.returncode != 0:
        raise SystemExit(f'{exe} failed: {run.stderr.decode()}')
    return run.stdout


def lines(program):
    out, i = [], 0
    while i < len(program):
        number = (program[i] << 8) | program[i + 1]
        size = program[i + 2] | (program[i + 3] << 8)
        out.append((number, program[i + 4:i + 4 + size]))
        i += 4 + size
    return out


def removals(old, new, allow_before_token=False):
    """Spaces removed from old to reach new, and spaces the new text adds before
    a keyword token (allowed only for the pre-listing tokeniser). None on any
    other difference."""
    a, b = lines(old), lines(new)
    if [n for n, _ in a] != [n for n, _ in b]:
        return None
    removed = inserted = 0
    for (_, x), (_, y) in zip(a, b):
        i = j = 0
        in_string = in_rem = False
        while i < len(x) or j < len(y):
            if i < len(x) and j < len(y) and x[i] == y[j]:
                c = x[i]
                i += 1
                j += 1
                if in_rem:
                    continue
                if c == 0x22:
                    in_string = not in_string
                elif not in_string and c == 0xEA:
                    in_rem = True
                elif not in_string and c == 0x0E:
                    if x[i:i + 5] != y[j:j + 5]:
                        return None
                    i += 5
                    j += 5
                continue
            if i < len(x) and x[i] == 0x20 and not in_string and not in_rem:
                i += 1
                removed += 1
                continue
            if (allow_before_token and j + 1 < len(y) and y[j] == 0x20 and y[j + 1] >= 0xA5
                    and i < len(x) and x[i] == y[j + 1] and not in_string and not in_rem):
                j += 1
                inserted += 1
                continue
            return None
    return removed, inserted


def code_parts(line):
    """Split a listing line into (is_code, text) parts: string literals and a
    REM tail are not code, so a rename never touches them."""
    parts, i, start, in_string = [], 0, 0, False
    while i < len(line):
        if line[i] == '"':
            if not in_string:
                parts.append((True, line[start:i]))
                start = i
            else:
                parts.append((False, line[start:i + 1]))
                start = i + 1
            in_string = not in_string
        elif not in_string and re.match(r'REM\b', line[i:]):
            parts.append((True, line[start:i + 3]))
            parts.append((False, line[i + 3:]))
            return parts
        i += 1
    parts.append((not in_string, line[start:]))
    return parts


def renamed(old, new, names):
    """True when new is old with each variable renamed as a whole word in code
    only, and no new name was already in use (so two variables never merge)."""
    text = old.decode()
    for b in names.values():
        if re.search(rf'\b{b}\b', text, re.IGNORECASE):
            return False
    out = []
    for line in text.split('\n'):
        pieces = []
        for is_code, part in code_parts(line):
            if is_code:
                for a, b in names.items():
                    part = re.sub(rf'\b{a}\b', b, part)
            pieces.append(part)
        out.append(''.join(pieces))
    return '\n'.join(out).encode() == new


def build(args, recorded):
    changed = git('diff', '--name-only', PRE_SWEEP, SWEEP, '--', '*.bas').decode().split()
    kept = {(l['path'], l['kind']): l for l in recorded.get('links', [])}
    touched = {c: git('diff', '--name-only', f'{c}^', c).decode().split() for c, _, _ in RENAMES}
    links, failures = [], []
    for path in sorted(changed):
        now = (REPO / path).read_bytes()
        start, before = PRE_SWEEP, at(PRE_SWEEP, path)
        for commit, prefix, names in RENAMES:
            if path.startswith(prefix) and path in touched[commit]:
                after = at(commit, path)
                if not renamed(before, after, names):
                    failures.append(f'{path}: {commit[:8]} is not only the rename {names}')
                short = path.removeprefix('sinclair-zx-spectrum/basic/')
                boot = BOOT.get(short)
                if boot is None:
                    whole = short.replace('changes.bas', short.split('/')[0] + '.bas')
                    boot = f'fragment; its lines are part of {whole}: {BOOT[whole]}'
                links.append(dict(path=path, kind='renamed-variable', **{'from': sha(before)}, to=sha(after),
                                  from_commit=start, commit=commit, renames=names, rom_boot=boot))
                start, before = commit, after
        result = removals(tokenise(args.tokeniser, before), tokenise(args.tokeniser, now))
        if result is None or result[1]:
            failures.append(f'{path}: {TOKENISER} finds a change other than removed spaces')
            continue
        link = dict(path=path, kind='space-only', **{'from': sha(before)}, to=sha(now),
                    from_commit=start, commit=SWEEP, spaces_removed=result[0])
        if args.pre_listing_tokeniser:
            pre = removals(tokenise(args.pre_listing_tokeniser, before),
                           tokenise(args.pre_listing_tokeniser, now), allow_before_token=True)
            if pre is None:
                failures.append(f'{path}: {PRE_LISTING_TOKENISER} finds a change the allowance does not cover')
                continue
            link['pre_listing_check'] = dict(spaces_removed=pre[0], display_spaces_before_ink_or_to=pre[1])
        elif (path, 'space-only') in kept and 'pre_listing_check' in kept[(path, 'space-only')]:
            link['pre_listing_check'] = kept[(path, 'space-only')]['pre_listing_check']
        links.append(link)
    return links, failures


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--tokeniser', required=True)
    p.add_argument('--pre-listing-tokeniser')
    p.add_argument('--write', action='store_true')
    args = p.parse_args()
    recorded = json.loads(OUT.read_text()) if OUT.exists() else {}
    links, failures = build(args, recorded)
    data = dict(
        purpose='Links the SHA-256 each audit finds in evidence recorded on an earlier text of a listing '
                'to the listing now on disk, with the proof that the program is unchanged.',
        kinds={
            'space-only': f'Stored spaces removed and nothing else: {TOKENISER} on both texts gives the '
                          'earlier bytes with 0x20 removed, never in a string or after REM, hidden numbers '
                          f'unchanged. pre_listing_check repeats it with {PRE_LISTING_TOKENISER}, which also '
                          'stores a typed space before INK or TO where LIST prints one; those spaces are '
                          'counted, not failed.',
            'renamed-variable': 'The named variables renamed as whole words and nothing else. rom_boot is the '
                                'genuine 48K ROM boot of tapes of both texts.',
        },
        links=links,
    )
    text = json.dumps(data, indent=1) + '\n'
    if failures:
        print('\n'.join(failures))
        sys.exit(1)
    if args.write:
        OUT.write_text(text)
        print(f'wrote {len(links)} links')
    elif OUT.read_text() != text:
        print('lineage.json does not match what the sources and tokeniser give now')
        sys.exit(1)
    else:
        print(f'PASS {len(links)} links: hashes from git and disk, removals-only under {TOKENISER}')


if __name__ == '__main__':
    main()
