#!/usr/bin/env python3
"""Replay exact source edits and validate evidence identities and tape checksums."""
import argparse,functools,hashlib,json,re,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def listing(p):return {int(s.split()[0]):s for s in p.read_text().splitlines()}
p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();previous={};summary=[]
for item in json.loads((ROOT/'checkpoints.json').read_text()):
 source=ROOT/item['source'];current=listing(source);assert len(current)==len(source.read_text().splitlines())
 edits=json.loads((source.parent/'edits.json').read_text());changes=listing(source.parent/'changes.bas')
 assert edits['add']==sorted(current.keys()-previous.keys())
 assert edits['delete']==sorted(previous.keys()-current.keys())
 assert edits['replace']==sorted(n for n in current.keys()&previous.keys() if current[n]!=previous[n])
 assert set(changes)==set(edits['add']+edits['replace'])
 for n in edits['delete']:del previous[n]
 previous.update(changes);assert previous==current
 for target in re.findall(r'(?:GO TO|GO SUB|RESTORE) (\d+)',source.read_text()):assert int(target) in current,(source,target)
 out=a.evidence/item['name'];build=json.loads((out/'build.json').read_text());result=json.loads((out/'results.json').read_text())
 assert result['status']=='passed'
 captures=json.loads((out/'captures.json').read_text())
 assert all('settling_frames' in c and 'ROM font glyphs' in c['scope'] for c in captures)
 assert {c['name']+'.png' for c in captures}=={p.name for p in out.glob('*.png') if p.name!='failure.png'}
 assert sha(source)==build['source_sha256']==result['source_sha256']
 assert sha(out/'bricks.tap')==build['tape_sha256']==result['tape_sha256']
 tape=(out/'bricks.tap').read_bytes();offset=0;blocks=[]
 while offset<len(tape):
  size=int.from_bytes(tape[offset:offset+2],'little');chunk=tape[offset+2:offset+2+size]
  assert len(chunk)==size and functools.reduce(int.__xor__,chunk)==0
  blocks.append(size);offset+=size+2
 assert offset==len(tape) and len(blocks)==2
 summary.append({'name':item['name'],'source':item['source'],'source_sha256':sha(source),'tape_sha256':sha(out/'bricks.tap'),'checks':result['checks'],'captures':{p.name:sha(p) for p in sorted(out.glob('*.png')) if p.name!='failure.png'}})
assert (ROOT/'unit-09/brick-bash.bas').read_bytes()==(ROOT.parent/'prototype/brick-bash.bas').read_bytes()
controls=json.loads((a.evidence/'unit-09/controls.json').read_text());assert controls['status']=='passed'
assert controls['source_sha256']==summary[-1]['source_sha256'] and controls['tape_sha256']==summary[-1]['tape_sha256']
# Exhaustive host-side arithmetic check, separate from emulator execution.
for x in range(256):
 for y in range(176):
  rectangles=[(r,c) for r in range(1,4) for c in range(1,7) if x+1>=32*c and x<=32*c+23 and y+1>=152-16*r and y<=159-16*r]
  r=1+math.floor((143-y)/16);c=1+math.floor((x+1-32)/32)
  mapped=[(r,c)] if 1<=r<=3 and 1<=c<=6 and y+1>=152-16*r and x<=32*c+23 else []
  assert rectangles==mapped,(x,y)
report={'status':'passed','checkpoint_count':len(summary),'execution_checks':sum(len(r['checks']) for r in summary)+len(controls['checks']),'checkpoints':summary,'final_controls':controls['checks'],'source_transitions':'Exact add/replace/delete replay; literal targets present; final source identical to native prototype.','lookup_arithmetic':'All 45,056 integer positions in the BASIC drawing area agree with independent rectangle scanning; host calculation, not 45,056 emulator probes.'}
(a.evidence/'summary.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS',report['checkpoint_count'],'checkpoints,',report['execution_checks'],'execution groups, exact edits, tape checksums and exhaustive host lookup arithmetic.')
