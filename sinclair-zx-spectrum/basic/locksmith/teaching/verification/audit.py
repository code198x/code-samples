#!/usr/bin/env python3
"""Audit exact transitions, saved ROM programs and checkpoint execution evidence."""
from pathlib import Path
import functools,hashlib,json,re
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
previous={};previous_stored={};reports=[]
for item in json.loads((ROOT/'checkpoints.json').read_text()):
 name=item['name'];folder=ROOT/name;source=folder/'locksmith.bas';out=ROOT/'verification/evidence'/name
 lines={int(s.split()[0]):s for s in source.read_text().splitlines()};edits=json.loads((folder/'edits.json').read_text());patched=dict(previous)
 for n in edits['delete']:del patched[n]
 for s in edits['enter']:patched[int(s.split()[0])]=s
 assert patched==lines and sha(source)==item['sha256'];assert len(lines)==item['lines']
 assert edits['add']==sorted(set(lines)-set(previous));assert edits['replace']==sorted(n for n in lines.keys()&previous.keys() if lines[n]!=previous[n])
 for n in re.findall(r'\b(?:GO TO|GO SUB|RESTORE) (\d+)',re.sub(r'"[^"]*"','',source.read_text())):assert int(n) in lines
 if previous:assert (folder/'changes.bas').read_text().splitlines()==edits['enter']+[str(n) for n in edits['delete']]
 stored={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};assert set(stored)==set(lines)
 for n in lines.keys()&previous.keys():
  if lines[n]==previous[n]:assert stored[n]==previous_stored[n],(name,n)
 data=(out/'locksmith.tap').read_bytes();pos=0;blocks=[]
 while pos<len(data):
  size=int.from_bytes(data[pos:pos+2],'little');block=data[pos+2:pos+2+size];assert len(block)==size and functools.reduce(int.__xor__,block)==0;blocks.append(block);pos+=size+2
 assert pos==len(data) and len(blocks)==2 and int.from_bytes(blocks[0][14:16],'little')==10
 program=blocks[1][1:-1];pos=0
 for n,b in stored.items():
  assert int.from_bytes(program[pos:pos+2],'big')==n;size=int.from_bytes(program[pos+2:pos+4],'little');assert list(program[pos+4:pos+4+size])==b;pos+=size+4
 build=json.loads((out/'build.json').read_text());result=json.loads((out/'results.json').read_text());assert build['source_sha256']==result['source_sha256']==sha(source);assert build['tape_sha256']==sha(out/'locksmith.tap');assert result['state_writes']==False
 reports.append(dict(name=name,source_sha256=sha(source),tape_sha256=sha(out/'locksmith.tap'),checks=result['checks'],scored_guesses=len(result['trials']),captures={p.name:sha(p) for p in sorted(out.glob('*.png'))},server=build['server']))
 previous=lines;previous_stored=stored
assert (ROOT/'finished/locksmith.bas').read_bytes()==(ROOT.parent/'prototype/locksmith.bas').read_bytes()
manifest=dict(status='passed',configuration='Stock 48K PAL; Emu198x Spectrum 0.25.0',checkpoints=reports,execution_checks=sum(len(r['checks']) for r in reports),scored_guesses=sum(r['scored_guesses'] for r in reports),final_source_identical=True,limits='Native acceptance applies to the final game. Intermediate programs have keyboard-driven emulator execution evidence, not independent learner review or original-hardware timing.')
(ROOT/'verification/evidence/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('PASS',len(reports),'checkpoints;',manifest['execution_checks'],'checks;',manifest['scored_guesses'],'scored guesses; source transitions, TAPs, stored lines and final identity')
