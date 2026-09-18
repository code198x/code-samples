"""Audit source targets, ROM-saved tape and verification identities."""
from pathlib import Path
import functools,hashlib,json,re
ROOT=Path(__file__).resolve().parents[1];out=ROOT/'verification/evidence'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
source=ROOT/'cipher.bas';rows=source.read_text().splitlines();numbers=[int(s.split()[0]) for s in rows];assert numbers==sorted(set(numbers))
for target in re.findall(r'(?:GO TO|GO SUB|RESTORE) (\d+)',re.sub(r'"[^"]*"','',source.read_text())):assert int(target) in numbers
stored={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};assert set(stored)==set(numbers)
build=json.loads((out/'build.json').read_text());results=json.loads((out/'results.json').read_text())
assert build['source_sha256']==results['source_sha256']==sha(source)
assert build['binary_sha256']==results['binary_sha256'];assert not results['direct_memory_writes']
tape=out/'cipher.tap';assert build['tape_sha256']==sha(tape)
data=tape.read_bytes();pos=0;blocks=[]
while pos<len(data):
 size=int.from_bytes(data[pos:pos+2],'little');block=data[pos+2:pos+2+size];assert len(block)==size and functools.reduce(int.__xor__,block)==0;blocks.append(block);pos+=size+2
assert pos==len(data) and len(blocks)==2 and int.from_bytes(blocks[0][14:16],'little')==10
program=blocks[1][1:-1];pos=0
for n,b in stored.items():
 assert int.from_bytes(program[pos:pos+2],'big')==n;size=int.from_bytes(program[pos+2:pos+4],'little');assert list(program[pos+4:pos+4+size])==b;pos+=size+4
manifest={'configuration':build['configuration'],'source_sha256':sha(source),'binary_sha256':build['binary_sha256'],'checks':len(results['checks']),'word_fixtures':len(results['fixtures']),'files':{p.name:sha(p) for p in out.iterdir() if p.is_file() and p.name!='manifest.json'},'limits':'Original key-driven emulator captures; read-only memory. Content coverage uses labelled ordinary ROM setup commands. Native acceptance pending.'}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('PASS',manifest['checks'],'execution groups;',manifest['word_fixtures'],'word fixtures; tape and source identities')
