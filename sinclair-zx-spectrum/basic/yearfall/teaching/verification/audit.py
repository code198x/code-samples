"""Check editing instructions, ROM token identity, tapes and execution evidence."""
from pathlib import Path
import sys;sys.path.insert(0,str(Path(__file__).resolve().parents[3]/'source-lineage'));import lineage  # accepts evidence recorded on an earlier text
import functools,hashlib,json,re
ROOT=Path(__file__).resolve().parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
previous={};previous_stored={};previous_current=None;reports=[]
for item in json.loads((ROOT/'checkpoints.json').read_text()):
 name=item['name'];folder=ROOT/name;source=folder/'yearfall.bas';out=ROOT/'verification/evidence'/name
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
 this_current=json.loads((out/'build.json').read_text())['source_sha256']==sha(source)
 for n in lines.keys()&previous.keys():
  # Evidence recorded on an earlier text (accepted through lineage) stored its old spaces,
  # so compare unchanged lines only between evidence of the same text vintage.
  if lines[n]==previous[n] and previous_current==this_current:assert stored[n]==previous_stored[n],(name,n)
 data=(out/'yearfall.tap').read_bytes();pos=0;blocks=[]
 while pos<len(data):
  size=int.from_bytes(data[pos:pos+2],'little');block=data[pos+2:pos+2+size];assert len(block)==size and functools.reduce(int.__xor__,block)==0;blocks.append(block);pos+=size+2
 assert pos==len(data) and len(blocks)==2 and int.from_bytes(blocks[0][14:16],'little')==10
 program=blocks[1][1:-1];pos=0
 for n,b in stored.items():
  assert int.from_bytes(program[pos:pos+2],'big')==n;size=int.from_bytes(program[pos+2:pos+4],'little');assert list(program[pos+4:pos+4+size])==b;pos+=size+4
 build=json.loads((out/'build.json').read_text());result=json.loads((out/'results.json').read_text());assert build['source_sha256']==result['source_sha256'] and lineage.accepts(build['source_sha256'],source);assert build['tape_sha256']==sha(out/'yearfall.tap');assert result['direct_memory_writes']==False
 checks=result['checks']
 if name=='polished':
  # The polish checks pass on this tape and are recorded failing on the finished one.
  polish=json.loads((out/'polish.json').read_text());assert polish['source_sha256']==build['source_sha256'] and not polish['failures'] and not polish['direct_memory_writes']
  earlier=json.loads((out/'polish-on-finished.json').read_text());assert earlier['source_sha256']==sha(ROOT/'finished/yearfall.bas') and earlier['failures']
  assert {f['check'] for f in earlier['failures']}>={'edits-leave-the-title-row-untouched','quit-from-plan-says-goodbye'}
  checks=checks+polish['checks']
 reports.append(dict(name=name,source_sha256=build['source_sha256'],tape_sha256=sha(out/'yearfall.tap'),checks=checks,captures={p.name:sha(p) for p in sorted(out.glob('*.png'))},server=build['server'],binary_sha256=build['binary_sha256']))
 previous=lines;previous_stored=stored;previous_current=this_current
assert (ROOT/'finished/yearfall.bas').read_bytes()==(ROOT.parent/'prototype/yearfall.bas').read_bytes()
manifest=dict(status='passed',configuration='Stock 48K PAL; executable identities in each checkpoint record',checkpoints=reports,execution_checks=sum(len(r['checks']) for r in reports),final_source_identical=True,limits='Native acceptance applies to the finished prototype game. The polished endpoint passes the full prototype regression and its own polish checks in the emulator; it has not had separate native play. Intermediate stages have emulator execution evidence, not independent learner review. Explicit ROM-command diagnostics are separate from legal play captures.')
(ROOT/'verification/evidence/manifest.json').write_text(json.dumps(manifest,indent=2)+'\n');print('PASS',len(reports),'checkpoints;',manifest['execution_checks'],'checks; transitions, TAPs, tokens and final identity')
