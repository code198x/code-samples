"""Check editing instructions, ROM token identity, tapes and execution evidence."""
from pathlib import Path
import sys;sys.path.insert(0,str(Path(__file__).resolve().parents[3]/'source-lineage'));import lineage  # accepts evidence recorded on an earlier text
import functools,hashlib,json,re
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
previous={};previous_stored={};previous_current=None;reports=[]
for item in json.loads((ROOT/'checkpoints.json').read_text()):
 name=item['name'];folder=ROOT/name;source=folder/'three.bas';out=ROOT/'verification/evidence'/name
 raw=source.read_text().splitlines();numbers=[int(s.split()[0]) for s in raw];assert numbers==sorted(set(numbers))
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
 # Unchanged lines must store the same tokens when both records come from the
 # same generation of listings: both from the text as it is now, or both from
 # the earlier text that source lineage links to it, which stored more spaces.
 current=json.loads((out/'build.json').read_text())['source_sha256']==sha(source)
 if current==previous_current:
  for n in lines.keys()&previous.keys():
   if lines[n]==previous[n]:assert stored[n]==previous_stored[n],(name,n)
 data=(out/'three.tap').read_bytes();pos=0;blocks=[]
 while pos<len(data):
  size=int.from_bytes(data[pos:pos+2],'little');block=data[pos+2:pos+2+size];assert len(block)==size and functools.reduce(int.__xor__,block)==0;blocks.append(block);pos+=size+2
 assert pos==len(data) and len(blocks)==2 and int.from_bytes(blocks[0][14:16],'little')==10
 program=blocks[1][1:-1];pos=0
 for n,b in stored.items():
  assert int.from_bytes(program[pos:pos+2],'big')==n;size=int.from_bytes(program[pos+2:pos+4],'little');assert list(program[pos+4:pos+4+size])==b;pos+=size+4
 build=json.loads((out/'build.json').read_text());result=json.loads((out/'results.json').read_text());assert build['source_sha256']==result['source_sha256'] and lineage.accepts(build['source_sha256'],source);assert build['tape_sha256']==sha(out/'three.tap');assert result['direct_memory_writes']==False
 reports.append(dict(name=name,source_sha256=build['source_sha256'],tape_sha256=sha(out/'three.tap'),checks=result['checks'],captures={p.name:sha(p) for p in sorted(out.glob('*.png'))},server=build['server'],binary_sha256=build['binary_sha256']))
 previous=lines;previous_stored=stored;previous_current=current
assert (ROOT/'finished/three.bas').read_bytes()==(ROOT.parent/'prototype/three.bas').read_bytes()
def permanent_colour_lines(path):
 # Lines with a colour statement (INK, PAPER, BRIGHT or FLASH on its own, not
 # an item after PRINT, PLOT or DRAW) change the permanent colours.
 found=[]
 for s in path.read_text().splitlines():
  body=re.sub(r'"[^"]*"','""',s.split(None,1)[1])
  if any(re.match(r'\s*(INK|PAPER|BRIGHT|FLASH)\b',st) for st in body.split(':')):found.append(int(s.split()[0]))
 return found
# Only the setup (10) and the quit (8000) may change the permanent colours.
assert permanent_colour_lines(ROOT/'colours/three.bas')==[10,8000],permanent_colour_lines(ROOT/'colours/three.bas')
assert permanent_colour_lines(ROOT/'finished/three.bas')==[10,1030,2050,2100,6040,8000]
manifest=dict(status='passed',configuration='Stock 48K PAL; executable identities in each checkpoint record',checkpoints=reports,execution_checks=sum(len(r['checks']) for r in reports),finished_matches_prototype=True,final_checkpoint=reports[-1]['name'],limits='Native acceptance applies to the finished checkpoint, which matches the prototype; the colours checkpoint after it changes only how colour is applied, with emulator evidence. Intermediate stages have emulator execution evidence, not independent learner review. Explicit ROM-command diagnostics are separate from legal play captures.')
(ROOT/'verification/evidence/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('PASS',len(reports),'checkpoints;',manifest['execution_checks'],'checks; transitions, TAPs, tokens and finished identity')
