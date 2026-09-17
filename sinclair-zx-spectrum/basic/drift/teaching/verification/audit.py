#!/usr/bin/env python3
"""Audit exact source transitions, fresh-load evidence, original captures and tape checksums."""
import argparse,functools,json,re,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def listing(p):return {int(s.split()[0]):s for s in p.read_text().splitlines()}
p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();previous={};records=[]
for item in json.loads((ROOT/'checkpoints.json').read_text()):
 source=ROOT/item['source'];current=listing(source);assert len(current)==len(source.read_text().splitlines());assert list(current)==sorted(current)
 edits=json.loads((source.parent/'edits.json').read_text());changes=listing(source.parent/'changes.bas')
 assert edits['add']==sorted(current.keys()-previous.keys())
 assert edits['delete']==sorted(previous.keys()-current.keys())
 assert edits['replace']==sorted(n for n in current.keys()&previous.keys() if current[n]!=previous[n])
 assert set(changes)==set(edits['add']+edits['replace'])
 for n in edits['delete']:del previous[n]
 previous.update(changes);assert previous==current
 for target in re.findall(r'(?:GO TO|GO SUB) (\d+)',source.read_text()):assert int(target) in current,(source,target)
 out=a.evidence/item['name'];build=json.loads((out/'build.json').read_text());result=json.loads((out/'results.json').read_text());frames=json.loads((out/'frames.json').read_text())
 assert set(map(int,json.loads((out/'stored.json').read_text())))==set(current)
 assert result['status']==frames['status']=='passed'
 assert sha(source)==build['source_sha256']==result['source_sha256']==frames['source_sha256']
 assert sha(out/'drift.tap')==build['tape_sha256']==result['tape_sha256']==frames['tape_sha256']
 tape=(out/'drift.tap').read_bytes();offset=0;blocks=[]
 while offset<len(tape):
  n=int.from_bytes(tape[offset:offset+2],'little');block=tape[offset+2:offset+2+n]
  assert len(block)==n and functools.reduce(int.__xor__,block)==0
  blocks.append(n);offset+=n+2
 assert offset==len(tape) and len(blocks)==2
 captures=json.loads((out/'captures.json').read_text());assert len(captures)==len({c['name'] for c in captures})
 assert all('match RAM' in c['scope'] and c['settling_frames']>=10 for c in captures)
 assert {c['name']+'.png' for c in captures}=={p.name for p in out.glob('*.png')}
 records.append(dict(name=item['name'],lessons=item['lessons'],source=item['source'],source_sha256=sha(source),tape_sha256=sha(out/'drift.tap'),tape_blocks=blocks,model_checks=result['checks'],normal_frame_checks=frames['checks'],captures={p.name:sha(p) for p in sorted(out.glob('*.png'))}))
assert (ROOT/'finished/drift.bas').read_bytes()==(ROOT.parent/'prototype/drift.bas').read_bytes()
extra={}
for name in ['controls','timing']:
 result=json.loads((a.evidence/'finished'/f'{name}.json').read_text());assert result['status']=='passed';assert result['source_sha256']==records[-1]['source_sha256'];assert result['tape_sha256']==records[-1]['tape_sha256'];extra[name]=result['checks']
summary=dict(status='passed',checkpoint_count=len(records),lesson_count=8,execution_checks=sum(len(r['model_checks'])+len(r['normal_frame_checks']) for r in records)+sum(map(len,extra.values())),checkpoints=records,endpoint_checks=extra,source_transitions='Exact add/replace/delete replay; all literal branch targets exist; final listing byte-identical to the accepted native prototype.',method='Independent ROM keyboard entry and tape save per checkpoint; fresh tape loads; keyboard-only input; read-only state/bitmap checks; separate ordinary-frame controls and original captures. CPU-stepped state comparisons are not performance measurements.')
(a.evidence/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(f"PASS {len(records)} checkpoints, {summary['execution_checks']} check groups, exact edits and checksum-valid tapes")
