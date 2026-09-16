"""Check edit continuity, source hashes and final source equivalence."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def lines(path):return {int(line.split()[0]):line for line in path.read_text().splitlines()}
roster=json.loads((ROOT/'roster.json').read_text())
for item in roster:
    current=lines(ROOT/item['from']) if item['from'] else {}
    for number in item['delete']:del current[number]
    edits=lines(ROOT/item['edits'])
    assert set(edits)==set(item['add']+item['replace']),item['name']
    current.update(edits)
    assert current==lines(ROOT/item['source']),item['name']
result=json.loads((ROOT/'verification/results.json').read_text())
for source,digest in result['sources'].items():
    assert hashlib.sha256((ROOT/source).read_bytes()).hexdigest()==digest,source
assert (ROOT/'unit-08/steps/step-01.bas').read_bytes()==(ROOT.parent/'prototype/experiments/distance-bands.bas').read_bytes()
print('All eleven edit rosters reconstruct the verified sources; final source equals the accepted game.')
