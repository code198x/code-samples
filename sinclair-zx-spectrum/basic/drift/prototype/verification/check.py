#!/usr/bin/env python3
"""Fresh ROM tape load; keyboard-only flights and read-only state observations."""
import argparse,sys,json,math
from pathlib import Path
from entry import Spectrum,ROOT
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line,sha
class Review:
 def __init__(self,exe,out):self.exe=exe;self.out=out;self.m=Spectrum(exe,out);self.checks=[];self.trace=[]
 def wait_text(self,text):
  for _ in range(2000):
   if any(text in row for row in self.m.screen()):return
   self.m.frames(20)
  raise AssertionError((text,self.m.screen()))
 def boundary(self,targets):
  for _ in range(2000):
   at=line(self.m)
   if at in targets:return at
   self.m.call('run_until_mem_change',addrs=[23621,23622],max_steps=200000)
  raise AssertionError(('boundary',line(self.m),self.m.screen()))
 def event(self,key,down):
  if key:self.m.call('input',events=[{'Key':{'name':'space' if key==' ' else key,'pressed':down}}])
 def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
 def capture(self,name):self.m.frames(1);self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def reset(self):
  self.event('r',True);self.m.frames(1);self.boundary({100});self.event('r',False);self.m.frames(1);self.boundary({200});s=state(self.m)
  assert all(abs(s[k]-v)<1e-7 for k,v in dict(x=48,y=56,vx=0,vy=0,h=2,steps=0).items()),s
  return s
 def tick(self,key=''):
  self.boundary({200});before=state(self.m)
  self.event(key,True);self.m.frames(1);self.boundary({370,4000,9000});at=line(self.m);self.event(key,False)
  after=state(self.m)
  h=((int(before['h'])-1+({'o':1,'p':-1}.get(key,0)))%8)+1
  vx,vy=before['vx'],before['vy']
  if key==' ':
   theta=(h-1)*math.pi/4;vx+=.2*math.cos(theta);vy+=.2*math.sin(theta)
   speed=math.hypot(vx,vy)
   if speed>3:vx*=3/speed;vy*=3/speed
  nx,ny=before['x']+vx,before['y']+vy
  crash=not(22<=nx<=233 and 30<=ny<=145)
  win=not crash and 190<=nx<=210 and 94<=ny<=114 and vx*vx+vy*vy<=.16
  for name,value in dict(h=h,vx=vx,vy=vy,x=before['x'] if crash else nx,y=before['y'] if crash else ny).items():
   assert abs(after[name]-value)<1e-5,(name,value,after[name],key,before)
  assert (at==4000)==(crash or win),(at,crash,win,after)
  self.trace.append(dict(key=key,x=after['x'],y=after['y'],vx=after['vx'],vy=after['vy'],h=h,crash=crash,win=win))
  self.m.frames(1);self.boundary({4030} if at==4000 else {200})
  return after,crash,win
 def face(self,h):
  while int(state(self.m)['h'])!=h:
   current=int(state(self.m)['h']);key='o' if (h-current)%8<=4 else 'p'
   s,c,w=self.tick(key)
   assert not c and not w
 def execute(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'drift.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.wait_text('S starts.')
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
  self.capture('instructions');self.m.call('press_key',key='s',hold_frames=4);self.boundary({200});self.capture('arena');self.record('fresh-tape-title-and-arena')
  # Capture advances a frame: return to a precise loop entry before driving.
  self.m.frames(1);self.boundary({200})
  for _ in range(8):self.tick('o')
  assert state(self.m)['h']==2;self.record('all-eight-headings-wrap-without-motion')
  for _ in range(4):self.tick(' ')
  old=state(self.m)
  for _ in range(6):self.tick()
  assert abs(state(self.m)['vx']-old['vx'])<1e-8;self.record('released-thrust-preserves-both-velocity-components')
  for _ in range(4):self.tick('o')
  assert abs(state(self.m)['vx']-old['vx'])<1e-8;self.record('rotation-preserves-existing-velocity')
  for _ in range(4):self.tick(' ')
  assert math.hypot(state(self.m)['vx'],state(self.m)['vy'])<1e-6;self.record('opposite-burn-cancels-momentum')
  self.reset();self.record('restart-restores-position-heading-and-velocity')
  self.face(1)
  for _ in range(20):self.tick(' ')
  assert abs(math.hypot(state(self.m)['vx'],state(self.m)['vy'])-3)<1e-6;self.record('repeated-burn-reaches-speed-cap')
  for _ in range(200):
   _,crash,_=self.tick()
   if crash:break
  assert crash;self.capture('crash');self.record('right-wall-crash')
  frozen=state(self.m);self.m.frames(150);assert state(self.m)['x']==frozen['x'];self.record('crash-freezes-position')
  for heading,name in [(3,'top'),(5,'left'),(7,'bottom')]:
   self.reset();self.face(heading)
   for _ in range(250):
    _,crash,_=self.tick(' ')
    if crash:break
   assert crash;self.record(name+'-wall-crash')
  # A low, controllable diagonal transfer followed by an eastward approach.
  self.reset()
  for _ in range(4):self.tick(' ')
  for _ in range(69):self.tick()
  self.face(6)
  for _ in range(4):self.tick(' ')
  s=state(self.m);print('diagonal stop',s['x'],s['y'],flush=True)
  self.face(1)
  for _ in range(5):self.tick(' ')
  for _ in range(200):
   s=state(self.m)
   if s['x']>=185:break
   _,crash,win=self.tick();assert not crash and not win
  self.face(5)
  won=False
  for _ in range(5):
   s,crash,win=self.tick(' ');assert not crash
   if win:won=True;break
  assert won,('no dock',s)
  self.capture('docked');self.record('two-axis-transfer-and-counterthrust-docking')
  old=state(self.m);self.m.frames(150);assert state(self.m)['x']==old['x'];self.record('docking-freezes-position')
  (self.out/'flight-trace.json').write_text(json.dumps(self.trace,indent=2)+'\n')
  result=dict(status='passed',configuration='Stock 48K PAL; ROM-entered source, fresh tape load, keyboard-only play, read-only state',server=self.m.server,source_sha256=sha(ROOT/'drift.bas'),tape_sha256=sha(self.out/'drift.tap'),binary_sha256=sha(Path(self.exe)),native_frame_ticks=self.m.call('query',path='session.native_frame_ticks')['result']['value'],checks=self.checks,trace=self.trace)
  (self.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
 try:r.execute()
 finally:r.m.close()
