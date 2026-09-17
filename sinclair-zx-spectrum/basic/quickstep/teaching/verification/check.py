#!/usr/bin/env python3
"""Fresh-tape keyboard trials; no writes to program state or screen memory."""
import argparse,json,sys
from pathlib import Path
from collections import deque
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
import check as prototype
from entry import Spectrum
from check import state,line,sha,MOVES
from PIL import Image
class Trial(prototype.Review):
 def __init__(self,exe,out,name):
  super().__init__(exe,out);self.name=name;self.captures=[]
 def load(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'quickstep.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start')
  self.wait('S starts.' if self.name=='finished' else 'QUICKSTEP')
  if self.name=='board':self.wait('STOP')
  elif self.name!='finished':self.boundary({200})
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
 def start(self):
  return super().start() if self.name=='finished' else state(self.m)
 def reset_small(self):
  self.event('r',True);self.m.frames(0);self.boundary({100});self.event('r',False);self.m.frames(0);self.boundary({200})
  s=state(self.m);assert (s['x'],s['y'])==(7,2)
  if self.name!='walk':assert s['p']==10 and s['t']==2
 def manual(self,key,hold=False):
  self.boundary({200});self.event(key,True);self.m.frames(0);self.boundary({210});self.boundary({470})
  s=state(self.m)
  if hold:
   self.m.frames(80);assert state(self.m)['x']==s['x'] and state(self.m)['y']==s['y']
  self.event(key,False);self.m.frames(0);self.boundary({200});return state(self.m)
 def lane_bitmap(self):
  s=state(self.m);phase=int(s['p']);glyphs={};values=[]
  for ln in (ROOT.parent/'prototype/quickstep.bas').read_text().splitlines():
   if 7200<=int(ln.split()[0])<=7270:values+=list(map(int,ln.split('DATA ')[1].split(',')))
  expected=[[0]*30 for _ in range(16)]
  for j in range(3):
   for k in range(4):
    c=(2*phase+10*j+k)%30
    for y in range(8):expected[y][c]=values[8*k+y];expected[y+8][c]=values[8*(k+4)+y]
  for y in range(16):
   sy=32+y;addr=16384+((sy&192)<<5)+((sy&7)<<8)+((sy&56)<<2)+1
   actual=self.m.call('memory_read',addr=addr,len=30)['bytes']
   for c in range(30):
    if s['y']==1 and c in (2*s['x'],2*s['x']+1):continue
    assert actual[c]==expected[y][c],(phase,y,c,actual[c],expected[y][c])
 def small_tick(self,key=''):
  self.boundary({291});before=state(self.m);expected,result=advance_small(unpack_small(before),key,self.name=='crossing')
  self.event(key,True);self.m.frames(0);self.boundary({292});self.event(key,False);self.m.frames(0)
  self.boundary({470,4000});after=state(self.m)
  assert unpack_small(after)==expected,(key,unpack_small(before),expected,unpack_small(after))
  assert (line(self.m)==4000)==bool(result)
  self.trace.append(dict(key=key,before=unpack_small(before),after=unpack_small(after),result=result))
  self.boundary({4030} if result else {200});return after,result
 def capture(self,name):
  target=self.out/(name+'.png')
  for attempt in range(80):
   self.m.frames(2);self.m.call('save_screenshot',path=str(target));im=Image.open(target).convert('RGB');ram=[]
   for addr in range(16384,23296,128):ram+=self.m.call('memory_read',addr=addr,len=min(128,23296-addr))['bytes']
   ok=True
   for y in range(176):
    for x in range(256):
     attr=ram[6144+(y//8)*32+x//8];bit=ram[((y&192)<<5)|((y&7)<<8)|((y&56)<<2)|(x>>3)]&(128>>(x&7));col=(attr&7) if bit else ((attr>>3)&7)
     if tuple(c>0 for c in im.getpixel((48+x,48+y)))!=tuple(bool(col&b) for b in (2,4,1)):ok=False;break
    if not ok:break
   if ok:
    try:observed=state(self.m)
    except (AssertionError,IndexError):continue
    # RAM/image agreement alone can accept a half-drawn reset screen.
    # Also require the complete player at the observed logical position.
    data=[]
    for ln in (ROOT.parent/'prototype/quickstep.bas').read_text().splitlines():
     if 7280<=int(ln.split()[0])<=7310:data+=list(map(int,ln.split('DATA ')[1].split(',')))
    for py in range(16):
     sy=16+16*int(observed['y'])+py
     for px in range(2):
      offset=((sy&192)<<5)|((sy&7)<<8)|((sy&56)<<2)|(1+2*int(observed['x'])+px)
      if ram[offset]!=data[(py//8*2+px)*8+py%8]:ok=False
    if ok:break
  else:raise AssertionError('capture mismatch or incomplete player')
  self.captures.append(dict(name=name,sha256=sha(target),method='Original PNG; top 176 rows compared with bitmap and colour RAM'))
 def execute_small(self):
  self.load();self.record('fresh-tape-and-stored-source-identity');s=state(self.m);assert (s['x'],s['y'])==(7,2)
  self.capture('opening')
  if self.name=='board':
   assert len(s['h$'])==len(s['f$'])==2 and len(s['s$'])==30
   self.record('static-board-player-and-stop')
  elif self.name in ('walk','lane'):
   self.manual('j',True);assert state(self.m)['x']==6;self.record('held-key-makes-only-one-step')
   for _ in range(8):self.manual('j')
   assert state(self.m)['x']==0
   for _ in range(16):self.manual('l')
   assert state(self.m)['x']==14
   for _ in range(3):self.manual('i')
   assert state(self.m)['y']==0
   for _ in range(7):self.manual('j')
   assert state(self.m)['x']==7
   self.manual('l')
   attrs=self.m.call('memory_read',addr=22528+2*32+15,len=2)['bytes'];assert all((v>>3)&7==4 for v in attrs)
   for _ in range(3):self.manual('k')
   assert state(self.m)['y']==2;self.record('all-bounds-and-exit-background-restored')
   self.reset_small();self.record('retry-restores-practice-board')
   if self.name=='lane':
    for i in range(16):
     before=state(self.m);s=self.manual('space');assert s['p']==(before['p']-1)%15;self.lane_bitmap()
    self.record('manual-traffic-completes-wrap')
    self.manual('i');self.manual('space');self.manual('k');self.lane_bitmap();self.record('player-overlay-and-lane-restoration')
   self.event('q',True);self.m.frames(0);self.boundary({9000});self.event('q',False);self.m.frames(0);self.record('inspection-quit')
  else:
   self.reset_small()
   for _ in range(40):s,result=self.small_tick();assert not result
   self.record('countdown-phase-wrap-and-safe-wait')
   if self.name=='clock':
    self.reset_small()
    for _ in range(9):self.small_tick('j')
    assert state(self.m)['x']==0
    for _ in range(16):self.small_tick('l')
    assert state(self.m)['x']==14
    self.record('timed-input-and-bounds-without-collision')
   else:
    self.reset_small();path=route_small(unpack_small(state(self.m)),lambda s:s[:2]==(7,0))
    for key in path:s,result=self.small_tick(key)
    assert result=='win';self.record('one-lane-complete-crossing');frozen=unpack_small(s);self.m.frames(100);assert unpack_small(state(self.m))==frozen
    self.reset_small()
    for _ in range(20):
     if advance_small(unpack_small(state(self.m)),'i',True)[1]=='blocked':self.small_tick('i');break
     self.small_tick()
    else:raise AssertionError('no blocked contact')
    self.record('old-traffic-contact');self.reset_small()
    def swap(s):
     x,y,p,t=s
     return y==1 and t==1 and advance_small(s,'l',True)[1]=='blocked' and x in {(p-1+j)%15 for j in (0,1,5,6,10,11)}
    path=route_small(unpack_small(state(self.m)),swap)
    for key in path:self.small_tick(key)
    s,result=self.small_tick('l');assert result=='blocked';self.record('attempted-player-vehicle-swap-is-rejected');self.reset_small()
    path=route_small(unpack_small(state(self.m)),lambda s:advance_small(s,'',True)[1]=='caught')
    for key in path:self.small_tick(key)
    s,result=self.small_tick();assert result=='caught';frozen=unpack_small(s);self.m.frames(100);assert unpack_small(state(self.m))==frozen;self.record('moving-traffic-contact-and-frozen-result')
   self.reset_small();self.record('reset-restores-phase-and-countdown');self.event('q',True);self.m.frames(0);self.boundary({9000});self.event('q',False);self.m.frames(0);self.record('active-quit')
  self.save()
 def save(self):
  record=dict(status='passed',name=self.name,source_sha256=sha(ROOT/self.name/'quickstep.bas'),tape_sha256=sha(self.out/'quickstep.tap'),checks=self.checks,trace=self.trace,captures=self.captures,method='Fresh ROM tape; keyboard input; read-only state; CPU boundaries are not timing evidence')
  (self.out/'results.json').write_text(json.dumps(record,indent=2)+'\n')
def unpack_small(s):return tuple(int(s[k]) for k in ('x','y','p','t'))
def advance_small(s,key,collide):
 x,y,p,t=s;dx,dy=MOVES[key];nx,ny=x+dx,y+dy
 if not(0<=nx<15 and 0<=ny<3):nx,ny=x,y
 occupied=lambda x,y,p:y==1 and x in {(p+j)%15 for j in (0,1,5,6,10,11)}
 if collide and occupied(nx,ny,p):return s,'blocked'
 t-=1
 if t==0:t=2;p=(p-1)%15
 s=nx,ny,p,t
 return s,('caught' if occupied(nx,ny,p) else ('win' if (nx,ny)==(7,0) else '')) if collide else ''
def route_small(start,goal):
 q=deque([(start,[])]);seen={start}
 while q:
  s,path=q.popleft()
  if goal(s):return path
  for key in MOVES:
   nxt,result=advance_small(s,key,True)
   if result in ('blocked','caught') or nxt in seen:continue
   seen.add(nxt);q.append((nxt,path+[key]))
 raise AssertionError('no route')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only',required=True);a=p.parse_args()
 t=Trial(a.emulator,a.output.resolve()/a.only,a.only)
 try:
  if a.only in ('six-lanes','buffered','finished'):
   prototype.ROOT=ROOT/a.only;t.execute();t.save()
  else:t.execute_small()
 finally:t.m.close()
