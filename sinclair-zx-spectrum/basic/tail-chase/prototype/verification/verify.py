#!/usr/bin/env python3
"""Run Tail Chase through ROM keyboard/tape input; observe state without injection."""
import argparse,hashlib,json
from pathlib import Path
from collections import deque
from entry import Spectrum,ROOT

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def number(b):
 if b[0]==0:return b[2]+256*b[3]-(65536 if b[1] else 0)
 return (-1 if b[1]&128 else 1)*(1+(((b[1]&127)<<24)+(b[2]<<16)+(b[3]<<8)+b[4])/2**31)*2**(b[0]-129)
def state(m):
 ptr=m.call('memory_read',addr=23627,len=2)['bytes'];addr=ptr[0]+256*ptr[1];data=[]
 for offset in range(0,4096,128):data+=m.call('memory_read',addr=addr+offset,len=128)['bytes']
 i=0;out={}
 while data[i]!=128:
  tag=data[i]>>5;name=chr((data[i]&31)+96);i+=1
  if tag in [2,4,6]:
   size=data[i]+256*data[i+1];i+=2
   if tag==4:
    dims=data[i];j=i+1+2*dims
    out[name]=[int(number(data[k:k+5])) for k in range(j,i+size,5)]
   elif tag==2:out[name+'$']=''.join(map(chr,data[i:i+size]))
   i+=size
  elif tag in [3,5,7]:
   if tag==5:
    while True:
     ch=data[i];i+=1;name+=chr(ch&127)
     if ch&128:break
   out[name]=number(data[i:i+5]);i+=5
   if tag==7:i+=13
  else:
   raise AssertionError((tag,i,{k:len(v) if isinstance(v,list) else v for k,v in out.items()}))
 return out

def line(m):
 b=m.call('memory_read',addr=23621,len=2)['bytes'];return b[0]+256*b[1]
def body(s):return [(s['a'][(int(s['t'])-1+j)%12],s['b'][(int(s['t'])-1+j)%12]) for j in range(int(s['n']))]
def invariant(s):
 cells=body(s);assert len(set(cells))==s['n'];assert len(s['g'])==384
 expected=[int((r,c) in cells) for r in range(1,17) for c in range(1,25)]
 assert s['g']==expected
 assert cells[-1]==(s['a'][int(s['h'])-1],s['b'][int(s['h'])-1])
 assert s['n']==4+s['eaten']
 if s['eaten']<8:assert (s['fr'],s['fc']) not in cells
 return cells
D={'i':(-1,0),'j':(0,-1),'k':(1,0),'l':(0,1)}
class Review:
 def __init__(self,exe,out):self.exe=exe;self.out=out;self.m=Spectrum(exe,out);self.checks=[];self.trace=[];self.frames=[]
 def wait(self,text,limit=24000):
  for _ in range(limit//20):
   if any(text in s for s in self.m.screen()):return
   self.m.frames(20)
  raise AssertionError((text,self.m.screen()))
 def capture(self,name):self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
 def ready(self):
  for _ in range(5000):
   at=line(self.m)
   if at==140 or at==150:
    try:s=state(self.m)
    except (AssertionError,IndexError):self.m.frames(1);continue
    if 'g' in s and 'fr' in s:return s
   self.m.frames(1)
  raise AssertionError(('not ready',self.m.screen()))
 def step(self,key='',hold=8):
  before=state(self.m);old=body(before);direction=(before['dr'],before['dc']);new=D.get(key.lower(),direction)
  if new==(-direction[0],-direction[1]):new=direction
  dest=(old[-1][0]+new[0],old[-1][1]+new[1]);grow=dest==(before['fr'],before['fc'])
  collision=not(1<=dest[0]<=16 and 1<=dest[1]<=24) or (dest in old and (grow or dest!=old[0]))
  if key:self.m.call('input',events=[{'Key':{'name':key.lower(),'pressed':True}}])
  elapsed=0
  for _ in range(250):
   self.m.frames(1)
   elapsed+=1;at=line(self.m)
   if (collision or before['eaten']+grow==8) and 4020<=at<=4060:break
   ready = (2010<=at<=2030) if grow else (at==410 or 3000<=at<=3050)
   if not collision and ready:
    try:current=state(self.m)
    except (AssertionError,IndexError):continue
    if current.get('steps')==before['steps']+1:
     if not grow or (current['fr'],current['fc']) not in body(current):break
  else:raise AssertionError(('step timeout',key,at,state(self.m),self.m.screen()))
  if key:self.m.call('input',events=[{'Key':{'name':key.lower(),'pressed':False}}])
  s=state(self.m)
  if collision:
   assert body(s)==old and s['g']==before['g'] and s['steps']==before['steps']
  else:
   expected=(old if grow else old[1:])+[dest]
   assert body(s)==expected,(key,old,dest,body(s));invariant(s)
   assert s['eaten']==before['eaten']+grow
  self.trace.append({'key':key,'before_steps':before['steps'],'after_steps':s['steps'],'head':body(s)[-1],'length':s['n'],'food':[s['fr'],s['fc']],'collision':collision,'frames':elapsed})
  if not grow and not collision:self.frames.append({'length':s['n'],'frames':elapsed})
  return s,collision
 def restart(self):
  self.m.frames(2)
  if 4000<=line(self.m)<=4060:
   for _ in range(100):
    if 4030<=line(self.m)<=4060:break
    self.m.frames(1)
  self.m.call('press_key',key='r',hold_frames=60)
  for _ in range(2000):
   s=self.ready()
   if body(s)==[(8,6),(8,7),(8,8),(8,9)] and s['steps']==0 and s['eaten']==0:invariant(s);return s
   self.m.frames(1)
  raise AssertionError(('restart failed',s,self.m.screen()))
 def execute(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'tail.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('S starts.')
  stored=self.m.program_lines();assert stored=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
  self.capture('instructions');self.m.call('press_key',key='x',hold_frames=30);assert any('S starts.' in r for r in self.m.screen())
  self.m.call('press_key',key='s',hold_frames=4);s=self.ready();invariant(s);self.capture('arena');self.record('fresh-tape-title-and-initial-body')
  self.step('j');self.step('x');self.record('reverse-and-invalid-key-preserve-direction')
  for _ in range(30):
   s,hit=self.step()
   if hit:break
  assert hit;self.capture('wall');self.record('continuous-motion-wall-collision-preserves-body')
  self.restart();self.record('retry-clears-body-food-and-progress')
  # A legal loop into the departing tail cell must be allowed when not growing.
  for key in 'ik':self.step(key)
  self.record('reversal-after-turn-rejected')
  self.restart()
  s=state(self.m);route='kji' if (s['fr'],s['fc']) not in [(9,9),(9,8),(8,8)] else 'ijk'
  for key in route:self.step(key)
  self.record('non-growing-head-can-enter-departing-tail-cell')
  self.restart()
  # Drive to each random food through ordinary legal turns. BFS avoids current
  # body cells; it permits the departing tail, without altering the game state.
  collision_checked=False
  for count in range(1500):
   s=state(self.m)
   if s['eaten']==8:break
   cells=body(s);target=(s['fr'],s['fc']);queue=deque([(cells[-1],(s['dr'],s['dc']),'')]);seen=set();blocked=set(cells[1:])
   route=None
   while queue:
    pos,direction,path=queue.popleft()
    if pos==target:route=path;break
    for key,d in D.items():
     if d==(-direction[0],-direction[1]):continue
     dest=(pos[0]+d[0],pos[1]+d[1])
     if not(1<=dest[0]<=16 and 1<=dest[1]<=24) or dest in blocked or dest in seen:continue
     seen.add(dest);queue.append((dest,d,path+key))
   assert route,('no route',s)
   s,hit=self.step(route[0]);assert not hit

   if s['eaten']==1 and not collision_checked:
    # Find a short deliberate self-collision, using the actual current body.
    initial=tuple(body(s));queue=deque([(initial,(s['dr'],s['dc']),'')]);seen={initial};crash=None
    while queue:
     chain,direction,path=queue.popleft()
     if len(path)>8:continue
     for key,d in D.items():
      if d==(-direction[0],-direction[1]):continue
      dest=(chain[-1][0]+d[0],chain[-1][1]+d[1])
      if not(1<=dest[0]<=16 and 1<=dest[1]<=24) or dest==(s['fr'],s['fc']):continue
      if dest in chain[1:]:crash=path+key;break
      nxt=chain[1:]+(dest,)
      if nxt not in seen:seen.add(nxt);queue.append((nxt,d,path+key))
     if crash:break
    assert crash
    for key in crash:s,hit=self.step(key)
    assert hit;self.capture('self-collision');self.record('self-collision-preserves-body');collision_checked=True;self.restart()
  assert s['eaten']==8 and s['n']==12;self.capture('complete');self.record('eight-random-foods-complete-with-independent-body-and-occupancy-checks')
  before=body(s);self.m.call('press_key',key='i',hold_frames=100);self.m.frames(100);assert body(state(self.m))==before;self.record('completion-stops-movement')
  self.restart();self.capture('retry');self.m.call('press_key',key='q',hold_frames=30);self.wait('Finished. RUN');self.record('quit-during-play')
  self.m.close();self.m=Spectrum(self.exe,self.out);self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'tail.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('S starts.');self.m.call('press_key',key='q',hold_frames=8);self.wait('Finished. RUN');self.record('quit-from-title')
  rom=[]
  for addr in range(0,16384,128):rom+=self.m.call('memory_read',addr=addr,len=128)['bytes']
  result={'status':'passed','configuration':'Emu198x Spectrum; stock 48K PAL; ROM keyboard entry and fresh tape loading; read-only observations','server':self.m.server,'binary_sha256':sha(Path(self.exe)),'rom_sha256':hashlib.sha256(bytes(rom)).hexdigest(),'source_sha256':sha(ROOT/'tail-chase.bas'),'tape_sha256':sha(self.out/'tail.tap'),'checks':self.checks,'trace':self.trace,'timing_samples':self.frames,'limits':'Prototype only. Native input and enjoyment require human play. Timing samples observe committed movement during drawing; growth checkpoints wait for a free replacement food position. These are not native host-latency measurements.'}
  (self.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output)
 try:r.execute()
 except Exception:r.capture('failure');raise
 finally:r.m.close()
