#!/usr/bin/env python3
"""Audit source edits, ROM lines, tape blocks, execution and capture provenance."""
from pathlib import Path
import json,hashlib,re,functools
ROOT=Path(__file__).resolve().parents[1]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
items=json.loads((ROOT/'checkpoints.json').read_text());previous={};previous_stored={};reports=[];edit_prose=['# Quickstep editing transitions','', 'Begin with the complete board program. Later changes below apply to the immediately preceding checkpoint. Enter additions and replacements from each linked changes listing; delete a BASIC line by entering its number alone.','']
for item in items:
 name=item['name'];folder=ROOT/name;source=folder/'quickstep.bas';lines={int(l.split()[0]):l for l in source.read_text().splitlines()};out=ROOT/'verification/evidence'/name
 edits=json.loads((folder/'edits.json').read_text());patched=dict(previous)
 for n in edits['delete']:del patched[n]
 for line in edits['enter']:patched[int(line.split()[0])]=line
 assert patched==lines
 assert sha(source)==item['sha256']
 for target in re.findall(r'\b(?:GO TO|GO SUB|RESTORE) (\d+)',source.read_text()):assert int(target) in lines
 stored={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};assert set(stored)==set(lines)
 for n in set(lines)&set(previous):
  if lines[n]==previous[n]:assert stored[n]==previous_stored[n],(name,n)
 tape=out/'quickstep.tap';data=tape.read_bytes();offset=0;blocks=[]
 while offset<len(data):
  size=int.from_bytes(data[offset:offset+2],'little');block=data[offset+2:offset+2+size];assert len(block)==size and functools.reduce(int.__xor__,block)==0
  blocks.append(size);offset+=size+2
 assert offset==len(data) and len(blocks)==2
 records={k:json.loads((out/(k+'.json')).read_text()) for k in ['build','results','frames']}
 for record in records.values():assert record['source_sha256']==sha(source) and record['tape_sha256']==sha(tape)
 for k in ['results','frames']:
  assert records[k]['status']=='passed'
  for capture in records[k]['captures']:assert sha(out/(capture['name']+'.png'))==capture['sha256']
 checks=len(records['results']['checks'])+len(records['frames']['checks'])
 reports.append(dict(name=name,source_sha256=sha(source),tape_sha256=sha(tape),checks=checks,tape_blocks=blocks,timing=records['frames']['timing'],model_checks=records['results']['checks'],frame_checks=records['frames']['checks'],captures=records['results']['captures']+records['frames']['captures']))
 if previous:
  (folder/'changes.bas').write_text('\n'.join(edits['enter'])+'\n')
  edit_prose += [f'## {name}', '',f"Add lines: {', '.join(map(str,edits['add'])) or 'none'}.",f"Replace lines: {', '.join(map(str,edits['replace'])) or 'none'}.",f"Delete lines: {', '.join(map(str,edits['delete'])) or 'none'}.",'',f'[Lines to enter]({name}/changes.bas) · [Complete program]({name}/quickstep.bas)','']
 else:edit_prose += ['## board','','Start a new program with the [complete listing](board/quickstep.bas).','']
 previous=lines;previous_stored=stored
assert (ROOT/'finished/quickstep.bas').read_bytes()==(ROOT.parent/'prototype/quickstep.bas').read_bytes()
(ROOT/'edits.md').write_text('\n'.join(edit_prose).rstrip()+'\n')
trial=json.loads((ROOT/'verification/evidence/six-lanes/results.json').read_text());trace=trial['trace']
i=next(i for i,t in enumerate(trace) if t['key']=='' and t['before'][:2]==[9,4] and not t['result'])
j=next(i for i,t in enumerate(trace) if t['result']=='caught')
planning=dict(source_sha256=trial['source_sha256'],safe_wait_then_move=trace[i:i+2],sideways_then_wait=trace[j-1:j+1],method='Extracted from recorded keyboard-driven six-lanes execution; no injected state')
for key in ['safe_wait_then_move','sideways_then_wait']:assert planning[key][0]['after']==planning[key][1]['before']
(ROOT/'verification/evidence/planning.json').write_text(json.dumps(planning,indent=2)+'\n')
manifest=dict(status='passed',configuration='Stock 48K PAL; Emu198x Spectrum 0.25.0',checkpoints=reports,execution_checks=sum(r['checks'] for r in reports),final_source_identical=True,limits='Native acceptance applies to the unchanged final game. Intermediate programs have automated execution evidence, not independent learner review. CPU statement checks are not timing evidence; captures from ordinary frames do not establish original-hardware performance.')
(ROOT/'verification/evidence/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('PASS',len(items),'ROM-entered checkpoints;',manifest['execution_checks'],'execution groups; edits, stored lines, TAP checksums, captures and final identity')
