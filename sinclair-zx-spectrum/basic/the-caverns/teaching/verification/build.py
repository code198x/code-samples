#!/usr/bin/env python3
"""Enter each standalone checkpoint through a fresh 48K ROM, then save a tape."""
import argparse,concurrent.futures,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def build(item,exe,output):
 out=output/item['name'];out.mkdir(parents=True,exist_ok=True)
 source=ROOT/item['source'];m=Spectrum(exe,out)
 try:
  m.load_source(source);stored=m.program_lines()
  assert set(stored)=={int(s.split()[0]) for s in source.read_text().splitlines()}
  m.statement('SAVE "caverns" LINE 10');m.enter()
  for _ in range(1500):
   if any('0 OK' in x for x in m.screen()):break
   m.frames(20)
  else:raise AssertionError(m.screen())
  tape=out/'caverns.tap';m.call('save_tape',path=str(tape))
  (out/'stored.json').write_text(json.dumps(stored)+'\n')
  record={'name':item['name'],'source':item['source'],'source_sha256':sha(source),'tape_sha256':sha(tape),'binary_sha256':sha(Path(exe)),'server':m.server,'entry':'Fresh 48K ROM keyboard; SAVE "caverns" LINE 10; no injection'}
  (out/'build.json').write_text(json.dumps(record,indent=2)+'\n')
  print('SAVED',item['name'],flush=True);return record
 finally:m.close()
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');p.add_argument('--jobs',type=int,default=1);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
 items=json.loads((ROOT/'checkpoints.json').read_text());items=[i for i in items if not a.only or i['name']==a.only]
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:records=list(pool.map(lambda item:build(item,a.emulator,out),items))
 (out/'builds.json').write_text(json.dumps(records,indent=2)+'\n')
