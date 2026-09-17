#!/usr/bin/env python3
"""Check source transitions, literal targets, snippets and saved execution identities."""
import argparse,hashlib,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def lines(p):return {int(s.split()[0]):s for s in p.read_text().splitlines()}
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,required=True);a=p.parse_args();previous={};summary=[]
 for item in json.loads((ROOT/'checkpoints.json').read_text()):
  source=ROOT/item['source'];current=lines(source);assert len(current)==len(source.read_text().splitlines())
  assert item['add']==sorted(current.keys()-previous.keys())
  assert item['delete']==sorted(previous.keys()-current.keys())
  assert item['replace']==sorted(n for n in current.keys()&previous.keys() if current[n]!=previous[n])
  snippet=source.parent.parent/'snippets'/('step-%02d-edits.bas'%item['step']);changed=lines(snippet)
  assert set(changed)==set(item['add']+item['replace'])
  edited=previous.copy()
  for n in item['delete']:del edited[n]
  edited.update(changed);assert edited==current
  for target in re.findall(r'(?:GO TO|GO SUB|RESTORE) (\d+)',source.read_text()):assert int(target) in current,(source,target)
  out=a.evidence/item['name'];build=json.loads((out/'build.json').read_text());result=json.loads((out/'results.json').read_text())
  assert result['status']=='passed'
  assert sha(source)==build['source_sha256']==result['source_sha256']
  assert sha(out/'tail.tap')==build['tape_sha256']==result['tape_sha256']
  data=(out/'tail.tap').read_bytes();offset=0;blocks=[]
  while offset<len(data):
   size=int.from_bytes(data[offset:offset+2],'little');chunk=data[offset+2:offset+2+size];assert len(chunk)==size
   check=0
   for b in chunk:check^=b
   assert check==0;blocks.append(size);offset+=size+2
  assert len(blocks)==2
  summary.append({'name':item['name'],'source':item['source'],'source_sha256':sha(source),'tape_sha256':sha(out/'tail.tap'),'checks':result['checks']})
  previous=current
 assert (ROOT/'unit-09/steps/step-01.bas').read_bytes()==(ROOT.parent/'prototype/tail-chase.bas').read_bytes()
 controls=json.loads((a.evidence/'eight-foods/controls.json').read_text());assert controls['status']=='passed';assert controls['source_sha256']==summary[-1]['source_sha256']
 report={'status':'passed','checkpoint_count':len(summary),'checks':sum(len(r['checks']) for r in summary)+len(controls['checks']),'checkpoints':summary,'final_controls':controls['checks'],'source_transitions':'Exact additions, replacements, deletions and snippets replayed; literal branch targets present; final source equals accepted prototype.'}
 (a.evidence/'summary.json').write_text(json.dumps(report,indent=2)+'\n');print('PASS',report['checkpoint_count'],'checkpoints;',report['checks'],'execution checks; exact edits, source hashes and two-block tape checksums.')
