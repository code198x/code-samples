"""Execute the first three maintained falling/thrust/fuel checkpoints through the ROM."""
import argparse,json,hashlib
from pathlib import Path
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output);previous={};checks=[]
try:
 for n in [1,2,3]:
  source=ROOT/f'steps/step-{n:02}.bas';current={int(l.split()[0]):l for l in source.read_text().splitlines()}
  for line in previous.keys()-current.keys():m.statement(str(line))
  for k,line in current.items():
   if previous.get(k)!=line:m.statement(line)
  previous=current;m.statement('RUN');m.frames(2500);rows=m.screen()
  expected='Contact.' if n==1 else 'Too fast!'
  for _ in range(100):
   if any(expected in r for r in rows):break
   m.frames(50);rows=m.screen()
  if not any(expected in r for r in rows):
   m.call('save_screenshot',path=str(a.output/'failure.png'))
   m.key('caps','space');m.frames(100)
   ptr=m.call('memory_read',addr=23627,len=10)['bytes'];start=ptr[8]+256*ptr[9];end=ptr[0]+256*ptr[1];data=[]
   for addr in range(start,end,128):data+=m.call('memory_read',addr=addr,len=min(128,end-addr))['bytes']
   (a.output/'program-bytes.json').write_text(json.dumps(data))
  assert any(expected in r for r in rows),(n,rows)
  m.call('save_screenshot',path=str(a.output/f'step-{n:02}.png'))
  checks.append({'stage':n,'result':expected,'sha256':hashlib.sha256(source.read_bytes()).hexdigest()});print('PASS',n,expected,flush=True)
 (a.output/'opening-results.json').write_text(json.dumps(checks,indent=2)+'\n')
finally:m.close()
