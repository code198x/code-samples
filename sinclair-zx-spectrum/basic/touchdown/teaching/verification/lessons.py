"""Check lesson edits, snippets and recorded execution against maintained sources."""
import argparse
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--website', type=Path, help='Optional website checkout for roster comparison')
args = parser.parse_args()
roster = json.loads((ROOT / 'roster.json').read_text())
results = {r['checkpoint']: r for r in json.loads((ROOT / 'verification/checkpoint-results.json').read_text())}
assert len(roster) == 16
assert sorted({r['unit'] for r in roster}) == list(range(1, 12))
previous = {}
for item in roster:
    path = ROOT.parent / item['source']
    raw = path.read_bytes()
    lines = raw.decode().splitlines()
    current = {int(line.split()[0]): line for line in lines}
    assert len(current) == len(lines) and list(current) == sorted(current), path
    added = sorted(current.keys() - previous.keys())
    deleted = sorted(previous.keys() - current.keys())
    replaced = sorted(n for n in current.keys() & previous.keys() if current[n] != previous[n])
    assert (added, replaced, deleted) == (item['added'], item['replaced'], item['deleted']), path
    snippet = path.parent.parent / 'snippets' / path.name
    assert snippet.read_text() == ''.join(current[n] + '\n' for n in sorted(added + replaced)), snippet
    key = f"{item['unit']:02}-{item['step']}"
    assert results[key]['source_sha256'] == hashlib.sha256(raw).hexdigest(), path
    previous = current
assert (ROOT / 'unit-11/steps/step-02.bas').read_bytes() == (ROOT.parent / 'prototype/steps/step-06.bas').read_bytes()
diagnostic = json.loads((ROOT / 'verification/diagnostic-results.json').read_text())
assert diagnostic['source_sha256'] == hashlib.sha256((ROOT / 'unit-07/diagnostic.bas').read_bytes()).hexdigest()
assert len(diagnostic['combinations']) == 8
if args.website:
    assert json.loads((args.website / 'src/drafts/touchdown/roster.json').read_text()) == roster
    for item in roster:
        assert (args.website / f"src/drafts/touchdown/{item['slug']}.mdx").is_file()
print('PASS 16 checkpoints, 11 lesson endpoints, exact edits/snippets, source hashes and diagnostic')
