#!/usr/bin/env python3
"""ROM tape load and keyboard-driven trials, checked against a separate grid model."""
import argparse,sys,json,hashlib
from pathlib import Path
from collections import deque
from entry import Spectrum,ROOT
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line,sha
MOVES={'':(0,0),'i':(0,-1),'k':(0,1),'j':(-1,0),'l':(1,0)}
def occupied(x,y,p):
 if y in (0,4,8):return False
 start=p[y-1 if y<4 else y-2]
 return x in {(start+j)%15 for j in (0,1,5,6,10,11)}
def advance(s,key):
 x,y,p,t=s;p=list(p);t=list(t);dx,dy=MOVES[key];nx,ny=x+dx,y+dy
 if not(0<=nx<15 and 0<=ny<9):nx,ny=x,y
 if occupied(nx,ny,p):return s,'blocked'
 for j in range(6):
  t[j]-=1
  if not t[j]:t[j]=(3,4,2,3,4,2)[j];p[j]=(p[j]+(1,-1,1,-1,1,-1)[j])%15
 s=(nx,ny,tuple(p),tuple(t))
 return s,'caught' if occupied(nx,ny,p) else ('win' if (nx,ny)==(7,0) else '')
def unpack(s):return (int(s['x']),int(s['y']),tuple(s['p']),tuple(s['t']))
def route(start,goal=lambda s:s[:2]==(7,0)):
 queue=deque([(start,[])]);seen={start}
 while queue:
  s,path=queue.popleft()
  if goal(s):return path
  for key in MOVES:
   nxt,result=advance(s,key)
   if result in ('blocked','caught') or nxt in seen:continue
   seen.add(nxt);queue.append((nxt,path+[key]))
 raise AssertionError('No route')
class Review:
 def __init__(self,exe,out):self.exe=exe;self.out=out;self.m=Spectrum(exe,out);self.checks=[];self.trace=[]
 def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
 def wait(self,text):
  for _ in range(2000):
   if any(text in row for row in self.m.screen()):return
   self.m.frames(20)
  raise AssertionError((text,self.m.screen()))
 def boundary(self,targets):
  for _ in range(3000):
   at=line(self.m)
   if at in targets:return at
   self.m.call('run_until_mem_change',addrs=[23621,23622],max_steps=200000)
  raise AssertionError(('boundary',targets,line(self.m),self.m.screen()))
 def event(self,key,down):
  if key:self.m.call('input',events=[{'Key':{'name':key,'pressed':down}}])
 def load(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'quickstep.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('S starts.')
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
 def start(self):
  self.m.call('press_key',key='s',hold_frames=4);self.boundary({200});return state(self.m)
 def reset(self):
  self.event('r',True);self.m.frames(1);self.boundary({100});self.event('r',False);self.m.frames(1);self.boundary({200});s=state(self.m)
  assert s['x']==7 and s['y']==8 and s['steps']==0 and s['p']==[0,9,11,7,1,10] and s['t']==[3,4,2,3,4,2]
  return s
 def tick(self,key=''):
  self.boundary({291});before=state(self.m);expected,result=advance(unpack(before),key)
  # Flush keyboard events with a zero-frame run. CPU-only debug stepping does
  # not drain the session's queued host input by itself.
  self.event(key,True);self.m.frames(0);self.boundary({292})
  self.event(key,False);self.m.frames(0)
  self.boundary({470,4000});after=state(self.m);assert unpack(after)==expected,(key,unpack(before),expected,unpack(after),result,line(self.m))
  assert (line(self.m)==4000)==bool(result),(result,line(self.m))
  assert after['steps']==before['steps']+(result!='blocked')
  self.trace.append(dict(key=key,before=unpack(before),after=unpack(after),result=result))
  self.boundary({4030} if result else {200})
  return after,result
 def execute(self):
  self.load();self.start();self.record('fresh-ROM-tape-load-and-stored-source-identity')
  for _ in range(90):s,result=self.tick();assert not result and s['x']==7 and s['y']==8
  self.record('safe-wait-and-both-direction-wraps-over-90-beats')
  self.reset()
  for _ in range(8):self.tick('j')
  assert state(self.m)['x']==0
  for _ in range(15):self.tick('l')
  assert state(self.m)['x']==14
  self.tick('k');assert state(self.m)['y']==8;self.record('horizontal-and-bottom-bounds')
  self.reset();path=route(unpack(state(self.m)));print('WIN ROUTE',path,flush=True)
  for key in path:s,result=self.tick(key)
  assert result=='win';self.record('complete-crossing-agrees-with-independent-grid-model')
  frozen=unpack(s);self.m.frames(180);assert unpack(state(self.m))==frozen;self.record('win-freezes-world')
  self.reset();self.record('retry-restores-player-phases-and-counters')
  for key in route(unpack(state(self.m)),lambda s:s[:2]==(4,0)):self.tick(key)
  s,result=self.tick('i');assert s['y']==0 and s['x']==4 and not result
  self.record('top-boundary-and-exit-requires-centre-cell')
  self.reset()
  # Deliberately choose an occupied destination, exercising old-position contact.
  found=False
  for _ in range(100):
   current=unpack(state(self.m))
   if advance(current,'i')[1]=='blocked':s,result=self.tick('i');found=True;break
   self.tick()
  assert found;self.record('stepping-into-current-hazard-fails')
  self.reset()
  # Find a reachable state where a waiting player is hit on the next advance.
  path=route(unpack(state(self.m)),lambda s:advance(s,'')[1]=='caught')
  for key in path:self.tick(key)
  s,result=self.tick();assert result=='caught';self.record('advancing-hazard-hits-waiting-player')
  frozen=unpack(s);self.m.frames(120);assert unpack(state(self.m))==frozen;self.record('loss-freezes-world')
  self.event('q',True);self.m.frames(0);self.boundary({9000});self.event('q',False);self.m.frames(0);self.record('quit-from-result-control-flow')
  result=dict(status='passed',configuration='48K PAL ROM; independently entered source; fresh tape; keyboard input; read-only state',server=self.m.server,source_sha256=sha(ROOT/'quickstep.bas'),tape_sha256=sha(self.out/'quickstep.tap'),binary_sha256=sha(Path(self.exe)),checks=self.checks,trace=self.trace)
  (self.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
 try:r.execute()
 finally:r.m.close()
