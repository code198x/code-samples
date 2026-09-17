#!/usr/bin/env python3
"""Fresh tapes, keyboard-driven teaching stages, independent vectors and bitmap checks."""
import argparse,json,math,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
import check as endpoint
from entry import Spectrum
from check import state,line,sha
class Review(endpoint.Review):
 def __init__(self,item,exe,output):
  super().__init__(exe,output/item['name']);self.item=item;self.kind=item['kind']
 def memory_pixels(self):
  raw=[]
  for addr in range(16384,22528,128):raw+=self.m.call('memory_read',addr=addr,len=128)['bytes']
  return {(x,y) for y in range(176) for x in range(256) if raw[((y&192)<<5)|((y&7)<<8)|((y&56)<<2)|(x>>3)]&(128>>(x&7))}
 def playfield(self):return {(x,175-y) for x,y in self.memory_pixels() if 24<=175-y<=152}
 def hud(self,s):
  if self.kind not in ('readout','docking','finished'):return
  rows=self.m.screen();rounded=lambda v:format(int(abs(v)*10+.5)/10,'g')
  assert 'SPEED '+rounded(math.hypot(s['vx'],s['vy'])) in rows[1],rows[1]
  slow=s['vx']**2+s['vy']**2<=.16
  cue=('SLOW' if self.kind=='readout' else 'DOCK OK') if slow else 'TOO FAST'
  assert cue in rows[1],(cue,rows[1])
  for value,plus,minus in [(s['vx'],'E','W'),(s['vy'],'N','S')]:
   direction=plus if value>.001 else (minus if value<-.001 else '-')
   assert direction+' '+rounded(value) in rows[20],rows[20]
 def tick(self,key=''):
  self.boundary({200});old=state(self.m);self.event(key,True);self.m.frames(1);self.boundary({370,4000});at=line(self.m);self.event(key,False);s=state(self.m)
  h=(int(old['h'])-1+{'o':1,'p':-1}.get(key,0))%8+1
  vx,vy=old.get('vx',0),old.get('vy',0)
  if self.kind!='heading' and key==' ':
   theta=(h-1)*math.pi/4;vx+=.2*math.cos(theta);vy+=.2*math.sin(theta)
   speed=math.hypot(vx,vy)
   if speed>3:vx*=3/speed;vy*=3/speed
  nx,ny=old['x']+vx,old['y']+vy
  crash=not(22<=nx<=233 and 30<=ny<=145)
  win=self.kind in ('docking','finished') and not crash and 190<=nx<=210 and 94<=ny<=114 and vx*vx+vy*vy<=.16
  expected=dict(h=h,x=old['x'] if crash else nx,y=old['y'] if crash else ny,steps=old['steps']+(not crash))
  if self.kind!='heading':expected.update(vx=vx,vy=vy)
  for name,value in expected.items():assert abs(s[name]-value)<1e-5,(name,s[name],value,key)
  assert (at==4000)==bool(crash or win),(at,crash,win,s)
  if at==370:self.hud(s)
  self.trace.append(dict(key=key,**{k:s[k] for k in expected},crash=crash,win=win))
  self.m.frames(1);self.boundary({4030} if at==4000 else {200})
  return s,crash,win
 def reset(self):
  self.event('r',True);self.m.frames(1);self.boundary({100});self.event('r',False);self.m.frames(1);self.boundary({200});s=state(self.m)
  assert all(abs(s[k]-v)<1e-7 for k,v in dict(x=48,y=56,h=2,steps=0).items())
  if self.kind!='heading':assert s['vx']==s['vy']==0
  self.hud(s);return s
 def load(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'drift.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start')
  if self.kind=='drawing':self.wait_text('STOP')
  elif self.kind=='finished':self.wait_text('S starts.');self.m.call('press_key',key='s',hold_frames=4);self.boundary({200})
  else:
   # Loading is frame-driven until program state exists, then find a loop entry.
   for _ in range(1500):
    if 200<=line(self.m)<=370:break
    self.m.frames(20)
   else:raise AssertionError(self.m.screen())
   self.boundary({200})
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
  self.record('fresh-ROM-tape-load-and-stored-lines')
 def run(self):
  self.load()
  if self.kind=='drawing':
   full=self.playfield();self.m.statement('GO SUB 3000');empty=self.playfield()
   walls={(x,y) for x in range(15,241) for y in [24,152]}|{(x,y) for x in [15,240] for y in range(24,153)}
   assert empty==walls,(len(empty-walls),len(walls-empty))
   ship=full-empty;assert len(ship)>10 and all(45<=x<=53 and 53<=y<=59 for x,y in ship)
   self.m.statement('GO SUB 3000');assert self.playfield()==full;self.record('triangle-toggles-off-and-back-without-damaging-arena')
  elif self.kind=='heading':
   initial=self.playfield()
   for _ in range(8):self.tick('o')
   assert state(self.m)['h']==2 and self.playfield()==initial;self.record('eight-headings-return-to-identical-bitmap')
   for _ in range(8):self.tick('p')
   assert self.playfield()==initial;self.record('clockwise-wrap-and-erasure')
   self.tick(' ');self.tick('x');assert state(self.m)['x']==48 and state(self.m)['y']==56;self.record('heading-and-unused-keys-do-not-move-position')
   self.reset();self.record('heading-restart')
  else:
   for _ in range(4):self.tick(' ')
   old=state(self.m)
   for _ in range(6):self.tick()
   assert abs(state(self.m)['vx']-old['vx'])<1e-8;self.record('thrust-and-coasting-in-two-components')
   for _ in range(4):self.tick('o')
   assert abs(state(self.m)['vx']-old['vx'])<1e-8;self.record('turning-does-not-turn-velocity')
   for _ in range(4):self.tick(' ')
   assert math.hypot(state(self.m)['vx'],state(self.m)['vy'])<1e-6;self.record('counterthrust-cancels-equal-burn')
   self.reset();self.record('retry-restores-all-motion-state')
   self.face(1)
   for _ in range(20):self.tick(' ')
   assert abs(math.hypot(state(self.m)['vx'],state(self.m)['vy'])-3)<1e-6;self.record('resultant-speed-cap')
   for _ in range(200):
    _,crash,_=self.tick()
    if crash:break
   assert crash;self.record('right-wall-freezes-last-valid-position')
   for h,name in [(3,'top'),(5,'left'),(7,'bottom')]:
    self.reset();self.face(h)
    for _ in range(250):
     _,crash,_=self.tick(' ')
     if crash:break
    assert crash;self.record(name+'-wall')
   self.reset()
   for _ in range(4):self.tick(' ')
   for _ in range(69):self.tick()
   self.face(6)
   for _ in range(4):self.tick(' ')
   self.face(1)
   for _ in range(5):self.tick(' ')
   while state(self.m)['x']<185:self.tick()
   self.face(5)
   won=False
   for _ in range(5):
    s,c,w=self.tick(' ');assert not c
    if w:won=True;break
   if self.kind in ('docking','finished'):
    assert won;self.record('two-axis-transfer-and-low-speed-docking')
   else:
    assert not won and 190<=s['x']<=210 and 94<=s['y']<=114
    self.record('slow-target-region-remains-free-flight')
   if self.kind in ('readout','docking','finished'):self.record('readout-values-direction-and-unrounded-speed-cue')
   self.reset()
   for _ in range(4):self.tick(' ')
   self.record('retry-after-transfer')
  result=dict(status='passed',checkpoint=self.item,source_sha256=sha(ROOT/self.item['source']),tape_sha256=sha(self.out/'drift.tap'),binary_sha256=sha(Path(self.exe)),server=self.m.server,checks=self.checks,trace=self.trace,method='Fresh ROM-saved tape; keyboard input; read-only state and bitmap comparisons; host vector model.')
  (self.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');a=p.parse_args()
 for item in json.loads((ROOT/'checkpoints.json').read_text()):
  if a.only and a.only!=item['name']:continue
  r=Review(item,a.emulator,a.output.resolve())
  try:r.run()
  finally:r.m.close()
