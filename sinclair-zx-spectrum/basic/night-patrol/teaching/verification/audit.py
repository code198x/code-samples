"""Check editing instructions, ROM token identity, tapes and execution evidence."""
from pathlib import Path
import functools,hashlib,json,re
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
previous={};previous_stored={};reports=[]
for item in json.loads((ROOT/'checkpoints.json').read_text()):
 name=item['name'];folder=ROOT/name;source=folder/'night-patrol.bas';out=ROOT/'verification/evidence'/name
 raw=source.read_text().splitlines();numbers=[int(s.split()[0]) for s in raw];assert numbers==sorted(set(numbers)) and max(numbers)<=9999
 lines=dict(zip(numbers,raw));patched=previous.copy()
 assert item['add']==sorted(lines.keys()-previous.keys())
 assert item['replace']==sorted(n for n in lines.keys()&previous.keys() if lines[n]!=previous[n])
 assert item['delete']==sorted(previous.keys()-lines.keys())
 changes=(folder/'changes.bas').read_text().splitlines()
 assert changes==[lines[n] for n in sorted(item['add']+item['replace'])]
 for n in item['delete']:del patched[n]
 for s in changes:patched[int(s.split()[0])]=s
 assert patched==lines
 for n in re.findall(r'\b(?:GO TO|GO SUB|RESTORE) (\d+)',re.sub(r'"[^"]*"','',source.read_text())):assert int(n) in lines
 stored={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};assert set(stored)==set(lines)
 for n in lines.keys()&previous.keys():
  if lines[n]==previous[n]:assert stored[n]==previous_stored[n],(name,n)
 data=(out/'night-patrol.tap').read_bytes();pos=0;blocks=[]
 while pos<len(data):
  size=int.from_bytes(data[pos:pos+2],'little');block=data[pos+2:pos+2+size];assert len(block)==size and functools.reduce(int.__xor__,block)==0;blocks.append(block);pos+=size+2
 assert pos==len(data) and len(blocks)==2 and int.from_bytes(blocks[0][14:16],'little')==10
 program=blocks[1][1:-1];pos=0
 for n,b in stored.items():
  assert int.from_bytes(program[pos:pos+2],'big')==n;size=int.from_bytes(program[pos+2:pos+4],'little');assert list(program[pos+4:pos+4+size])==b;pos+=size+4
 build=json.loads((out/'build.json').read_text());result=json.loads((out/'results.json').read_text());assert build['source_sha256']==result['source_sha256']==sha(source);assert build['tape_sha256']==result['tape_sha256']==sha(out/'night-patrol.tap');assert result['direct_memory_writes']==False;assert build['binary_sha256']==result['binary_sha256']
 reports.append(dict(name=name,source_sha256=sha(source),tape_sha256=sha(out/'night-patrol.tap'),checks=result['checks'],captures={p.name:sha(p) for p in sorted(out.glob('*.png'))},server=build['server'],binary_sha256=build['binary_sha256']))
 previous=lines;previous_stored=stored
assert (ROOT/'finished/night-patrol.bas').read_bytes()==(ROOT.parent/'prototype/night-patrol.bas').read_bytes()
# Supplied data excerpts must remain exact parts of their runnable sources.
for name,stage,lo,hi in [('patrol-positions','scans',8200,8800),('opening-sight','sight',8900,8900),('sight-changes','finished',8200,8900)]:
 expected=[s for s in (ROOT/stage/'night-patrol.bas').read_text().splitlines() if lo<=int(s.split()[0])<=hi]
 assert (ROOT/'data'/f'{name}.bas').read_text().splitlines()==expected
import sys
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from level import lines as prepared_lines
from model import beam
assert (ROOT/'data/sight-changes.bas').read_text().splitlines()==prepared_lines()
visible=set();records={int(s.split()[0]):list(map(int,s.split(' DATA ')[1].split(','))) for s in prepared_lines()}
for n in [8900]+[8200+10*i for i in range(1,61)]*3+[8200]:
 gx,gy,gd,count,changed,*cells=records[n];assert changed==len(cells)
 for cell in cells:
  if cell>0:visible.add(cell)
  else:visible.discard(-cell)
 assert visible=={32*y+x for x,y in beam(gx,gy,gd)} and len(visible)==count
example=json.loads((ROOT/'data/worked-example.json').read_text());before=beam(*example['before_guard']);after=beam(*example['after_guard'])
assert example['before_cells']==list(map(list,sorted(before))) and example['after_cells']==list(map(list,sorted(after)))
assert example['removed']==list(map(list,sorted(before-after))) and example['added']==list(map(list,sorted(after-before)))
assert example['unchanged']==list(map(list,sorted(before&after)))
assert example['visible_count']==len(after) and example['change_count']==len(before^after)
assert example['record'] in prepared_lines()
manifest=dict(status='passed',configuration='Stock 48K PAL; executable identities in each checkpoint record',checkpoints=reports,execution_checks=sum(len(r['checks']) for r in reports),final_source_identical=True,limits='The final game matches the prototype authorised for teaching. Intermediate stages have emulator execution evidence, not independent learner review. Prepared visibility and edit records are audited; debug-stepped PNGs are not lesson media.')
(ROOT/'verification/evidence/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('PASS',len(reports),'checkpoints;',manifest['execution_checks'],'checks; transitions, TAPs, tokens and final identity')
