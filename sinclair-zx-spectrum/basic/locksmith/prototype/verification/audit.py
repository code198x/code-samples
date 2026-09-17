#!/usr/bin/env python3
"""Audit retained source, ROM-stored lines, tape checksums and evidence hashes."""
import json,hashlib,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];out=ROOT/'verification/evidence'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
source=ROOT/'locksmith.bas';lines=source.read_text().splitlines();numbers=[int(s.split()[0]) for s in lines];assert numbers==sorted(set(numbers))
for s in lines:
 for target in re.findall(r'(?:GO TO|GO SUB|RESTORE) (\d+)',re.sub(r'"[^"]*"','',s)):assert int(target) in numbers,(s,target)
stored={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};assert set(stored)==set(numbers)
build=json.loads((out/'build.json').read_text());assert build['source_sha256']==sha(source);assert build['tape_sha256']==sha(out/'locksmith.tap')
data=(out/'locksmith.tap').read_bytes();pos=0;blocks=[]
while pos<len(data):
 size=int.from_bytes(data[pos:pos+2],'little');block=data[pos+2:pos+2+size];assert len(block)==size;checksum=0
 for b in block:checksum^=b
 assert checksum==0;blocks.append(block);pos+=size+2
assert pos==len(data) and len(blocks)==2
assert int.from_bytes(blocks[0][14:16],'little')==10
program=blocks[1][1:-1];pos=0
for n,b in stored.items():
 assert int.from_bytes(program[pos:pos+2],'big')==n;size=int.from_bytes(program[pos+2:pos+4],'little');assert list(program[pos+4:pos+4+size])==b;pos+=4+size
results=json.loads((out/'results.json').read_text());assert results['source_sha256']==sha(source);assert not results['state_writes'];assert len(results['trials'])==42
assert all(0<=t['exact']<=4 and 0<=t['other']<=4-t['exact'] for t in results['trials'])
manifest={'configuration':build['configuration'],'server':build['server'],'passed_checks':len(results['checks']),'scored_guesses':len(results['trials']),'source_sha256':sha(source),'files':{p.name:sha(p) for p in sorted(out.iterdir()) if p.is_file() and p.name!='manifest.json'},'limits':'Keyboard-driven emulator execution; native play review pending. No original-hardware timing claim.'}
(out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('PASS source, branch targets, ROM line identities, TAP blocks, autostart and evidence hashes')
