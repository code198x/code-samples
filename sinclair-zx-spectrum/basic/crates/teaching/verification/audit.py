"""Check edit continuity, accepted map identities and graphics provenance."""
import hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from verify import initial
roster=json.loads((ROOT/'roster.json').read_text())
read=lambda p:{int(l.split()[0]):l for l in p.read_text().splitlines()}
previous={};prev=None
for item in roster:
    assert item['from']==prev
    source=ROOT/item['source'];program=read(source)
    assert hashlib.sha256(source.read_bytes()).hexdigest()==item['sha256']
    assert item['add']==sorted(program.keys()-previous.keys())
    assert item['replace']==sorted(n for n in program.keys()&previous.keys() if program[n]!=previous[n])
    assert item['delete']==sorted(previous.keys()-program.keys())
    edits=read(ROOT/item['edits']);assert set(edits)==set(item['add']+item['replace'])
    rebuilt={n:l for n,l in previous.items() if n not in item['delete']};rebuilt.update(edits)
    assert rebuilt==program
    previous=program;prev=item['source']
prototype=read(ROOT.parent/'prototype/crates.bas')
assert {n:l for n,l in previous.items() if 7000<=n<8000}=={n:l for n,l in prototype.items() if 7000<=n<8000}
for room in [1,2,3]:
    grid=[];players=[]
    for r in range(8):
        row=previous[8000+100*(room-1)+10*r].split('"')[1];assert len(row)==8
        for c,ch in enumerate(row):
            grid.append({'-':0,'#':1,'.':2,'C':3,'*':4,'P':0,'+':2}[ch])
            if ch in 'P+':players.append((r+1,c+1))
    expected=initial(room);assert grid==expected['grid'] and players==[(expected['pr'],expected['pc'])]
assert hashlib.sha256((ROOT.parent/'prototype/crates.bas').read_bytes()).hexdigest()==json.loads((ROOT.parent/'prototype/verification/results.json').read_text())['source_sha256']
print(f'{len(roster)} edit transitions reconstruct exactly; all three maps and the tile bank match the accepted prototype.')
