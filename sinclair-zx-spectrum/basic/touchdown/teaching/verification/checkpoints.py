"""Enter and exercise all teaching checkpoints through the configured 48K ROM."""
import argparse,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from state import variables
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output);previous={};checks=[]
def key(k,d):m.call('input',events=[{'Key':{'name':k,'pressed':d}}])
def has(s):return any(s in r for r in m.screen())
def wait(s):
 for _ in range(2000):
  if has(s):return
  m.frames(5)
 raise AssertionError((s,m.screen()))
def launch(unit):
 m.statement('RUN')
 if unit>=4:
  wait('S launches');key('s',True);m.frames(5);key('s',False)
  wait('FUEL' if unit>=5 else 'SPEED')
def finish(unit):
 if unit>=4:
  wait('R retries');m.frames(80);key('q',True);m.frames(50);key('q',False)
 wait('9 STOP');m.frames(100)
def stored_lines():
 ptr=m.call('memory_read',addr=23627,len=10)['bytes'];start=ptr[8]+256*ptr[9];end=ptr[0]+256*ptr[1];b=[]
 for addr in range(start,end,128):b+=m.call('memory_read',addr=addr,len=min(128,end-addr))['bytes']
 result=[];i=0
 while i<len(b):result.append(b[i]*256+b[i+1]);i+=4+b[i+2]+256*b[i+3]
 assert i==len(b)
 return result
def pilot(unit):
 held=set();frames=0;lowest=45
 for _ in range(3500):
  m.frames(2);frames+=2
  v=variables(m)
  if has('Safe landing!') or has('Too fast') or has('Off the pad.') or has('Terrain collision.'):break
  desired=set();x=v.get('x',24)
  if unit>=6 and x<24:desired.add('p')
  if unit>=7 and x<24:thrust=v['v']>=0
  else:thrust=v['y']+max(0,v['v'])**2/8>=1820 and v['v']>=8
  if unit==6 and x<24:thrust=False
  if thrust:desired.add('space')
  for k in held-desired:key(k,False)
  for k in desired-held:key(k,True)
  held=desired;lowest=min(lowest,v.get('fuel',45))
 else:raise AssertionError(('pilot timeout',unit,m.screen()))
 for k in held:key(k,False)
 assert has('Safe landing!'),(unit,m.screen(),variables(m))
 m.frames(80)
 state=variables(m);assert state.get('fuel',0)>=0
 return {'frames_to_result':frames,'landing_speed':state['v'],'fuel_remaining':state.get('fuel'),'minimum_fuel':lowest}
try:
 for item in json.loads((ROOT/'roster.json').read_text()):
  path=ROOT.parent/item['source'];current={int(l.split()[0]):l for l in path.read_text().splitlines()}
  for n in sorted(previous.keys()-current.keys()):m.statement(str(n))
  for n,line in sorted(current.items()):
   if previous.get(n)!=line:m.statement(line)
  assert stored_lines()==sorted(current),(item,stored_lines())
  previous=current;unit=item['unit'];label=f'{unit:02}-{item["step"]}'
  launch(unit);wait('Contact.' if unit<3 else ('9 STOP' if unit==3 else 'R retries'));finish(unit)
  result={'checkpoint':label,'source_sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'checks':['ROM line admission','uncontrolled contact','stop or release-gated quit']}
  if unit>=3:
   launch(unit);result['safe_approach']=pilot(unit);result['checks'].append('safe approach using keyboard events only')
   m.call('save_screenshot',path=str(a.output/f'{label}-landed.png'));finish(unit)
  checks.append(result);(a.output/'checkpoint-results.json').write_text(json.dumps(checks,indent=2)+'\n');print('PASS',label,result.get('safe_approach','constant/gravity fall'),flush=True)
 m.statement('SAVE "touchdown"');m.enter();m.frames(8000);wait('0 OK');m.call('save_tape',path=str(a.output/'touchdown.tap'))
 print('PASS saved final teaching tape',flush=True)
finally:m.close()
