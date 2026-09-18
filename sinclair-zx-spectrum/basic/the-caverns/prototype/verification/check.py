"""Fresh-ROM tape execution. All game actions use keys; memory is read-only."""
import argparse,hashlib,json,sys
from pathlib import Path
from entry import Spectrum,ROOT
from model import START,PATROL,TREASURES,rooms,step
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve();m=Spectrum(a.emulator,out);checks=[];trials=[]
def record(name):checks.append(name);print('PASS',name,flush=True)
def wait(targets):
 for _ in range(2500):
  if line(m) in targets:return state(m)
  m.frames(5)
 raise AssertionError((targets,line(m),m.screen()))
def ready():return wait([310,5090])
def key(k):m.key('space' if k==' ' else k);m.frames(10)
def stopped():
 for _ in range(500):
  if any('9 STOP statement' in r for r in m.screen()):return
  m.frames(5)
 raise AssertionError(m.screen())
def capture(name):m.frames(10);m.call('save_screenshot',path=str(out/(name+'.png')))
def reset():key('r');s=ready();assert s['rm']==1 and s['found']==0 and s['turns']==0 and s['cr']==4;return START
def move(s,k):
 before=ready();nxt,event=step(s,k);key(k);actual=ready();rm,ci,mask=nxt
 assert actual['rm']==rm and actual['ci']==ci+1 and actual['cr']==PATROL[ci],(s,k,event,actual)
 assert actual['found']==3-mask.bit_count()
 assert actual['turns']==before['turns']+(event!='wall')
 assert actual['t']==[int(n in TREASURES and mask&(1<<TREASURES.index(n))!=0) for n in range(1,13)]
 if event in ('pit','caught','win'):assert actual['ending']=={'pit':1,'caught':2,'win':3}[event]
 else:
  screen=m.screen();assert rooms[rm]['name'] in screen[5]
  for j,dest in enumerate(rooms[rm]['exits']):
   row=screen[11+j]
   if not dest:assert '--' in row;continue
   assert 'Open' in row
   if dest==7:assert 'Cold draught' in row
   if dest==PATROL[ci]:assert ('Footsteps' in row or 'Steps + glint' in row)
   if dest in TREASURES and mask&(1<<TREASURES.index(dest)):assert 'glint' in row.lower()
  if event=='arrival':assert 'IT IS HERE' in screen[16]
 trials.append({'key':k,'state':nxt,'event':event});return nxt
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(out/'caverns.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');wait([110])
 assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};capture('title');record('fresh-tape-autostart-and-stored-identity')
 key('a');wait([110]);key('q');stopped();record('title-ignored-key-and-quit')
 m.statement('RUN');wait([110]);key('s');s=ready();assert s['rm']==1;capture('entrance');record('start-safe-entrance')
 for k in ['a','0','enter']:key(k);assert ready()['turns']==0
 record('ignored-keys-cost-no-turn')
 move(START,'n');assert ready()['turns']==0;record('wall-costs-no-turn')
 reset();m.call('input',events=[{'Key':{'name':'s','pressed':True}}]);m.frames(500);assert state(m)['turns']==1 and state(m)['rm']==5
 m.call('input',events=[{'Key':{'name':'s','pressed':False}}]);m.frames(15);ready();record('held-direction-is-one-turn')
 model=json.loads((out/'model.json').read_text())
 for name,path in model['examples'].items():
  s=reset()
  for k in path:s=move(s,k)
  capture(name);record('legal-'+name+'-path-and-directional-clues')
  if name in ('pit','caught','win'):
   before=ready();key('n');after=ready();assert after['turns']==before['turns'] and after['found']==before['found'];record(name+'-result-stable')
 # Waiting after a surprise arrival is fatal; invalid keys still grant no turn.
 s=reset()
 for k in model['examples']['arrival']:s=move(s,k)
 for k in ['a','enter']:key(k);assert ready()['turns']==len(model['examples']['arrival'])
 s=move(s,' ');assert ready()['ending']==2;record('arrival-grace-then-wait-is-caught')
 key('q');stopped();record('quit-result')
 m.statement('RUN');wait([110]);key('s');ready();key('q');stopped();record('quit-play')
 # Uppercase is delivered as a real Spectrum chord.
 m.statement('RUN');wait([110]);m.key('caps','s');ready();m.key('caps','e');s=ready();assert s['rm']==2 and s['turns']==1;record('uppercase-start-and-direction')
 key('r');ready();capture('reset');record('reset-restores-treasures-and-patrol')
 data={'source_sha256':hashlib.sha256((ROOT/'caverns.bas').read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'configuration':'Stock 48K PAL; fresh ROM tape load; ordinary key play','checks':checks,'trials':trials,'direct_memory_writes':False,'server':m.server}
 (out/'results.json').write_text(json.dumps(data,indent=2)+'\n')
finally:m.close()
