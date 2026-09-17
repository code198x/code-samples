#!/usr/bin/env python3
"""ROM-loaded Brick Bash: keyboard play and an independent rectangle model."""
import argparse,hashlib,json,sys
from pathlib import Path
from collections import deque
ROOT=Path(__file__).resolve().parents[1]
from entry import Spectrum
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line,sha

def brick_at(x,y,g):
 # Deliberately scan physical rectangles, rather than copying BASIC's mapping.
 for r in range(3):
  for c in range(6):
   if g[6*r+c] and x+1>=32+32*c and x<=55+32*c and y+1>=136-16*r and y<=143-16*r:return 6*r+c
 return None

def advance(s,key='',paddle=True):
 z={k:s[k] for k in ['x','y','dx','dy','p','left','steps']};z['g']=s['g'].copy();events=[]
 z['p']=max(2,min(26,z['p']+({'o':-1,'p':1}.get(key,0))))
 x,y,dx,dy=z['x'],z['y'],z['dx'],z['dy'];nx=x+dx;ny=y+dy
 if nx<16:nx=32-nx;dx=abs(dx);events.append('left-wall')
 if nx>238:nx=476-nx;dx=-abs(dx);events.append('right-wall')
 if ny>149:ny=298-ny;dy=-abs(dy);events.append('top-wall')
 if ny<32:
  if not paddle:return z,'landing',nx,ny
  if nx+1<8*z['p'] or nx>8*z['p']+31:return z,'miss',events
  ny=64-ny;dy=4
  dx=-4 if nx+1<8*z['p']+11 else (4 if nx>8*z['p']+20 else 0)
  events.append('paddle-'+str(dx))
 h=brick_at(nx,y,z['g'])
 if h is not None:dx=-dx;nx=x;z['g'][h]=0;z['left']-=1;events.append('brick-side')
 h=brick_at(nx,ny,z['g'])
 if h is not None:dy=-dy;ny=y;z['g'][h]=0;z['left']-=1;events.append('brick-vertical')
 if z['left']==0:
  # The BASIC result branches before committing the proposed new ball position.
  z.update(dx=dx,dy=dy);return z,'win',events
 z.update(x=nx,y=ny,dx=dx,dy=dy,steps=z['steps']+1)
 assert brick_at(nx,ny,z['g']) is None
 return z,'moving',events

def flight(s,limit=500):
 s={**s,'g':s['g'].copy()}
 for n in range(limit):
  result=advance(s,paddle=False)
  if result[1]=='landing':return result[0],result[2],result[3],n
  s=result[0]
  if result[1]=='win':return s,None,None,n
 raise AssertionError(('no landing',s))

def choose_paddle(s):
 landing,lx,ly,_=flight(s)
 if lx is None:return int(s['p'])
 # Search a few future returns for actual brick removals. No game state is written.
 best=None
 for p in range(2,27):
  if not(8*p-1<=lx<=8*p+31):continue
  dx=-4 if lx+1<8*p+11 else (4 if lx>8*p+20 else 0)
  child={**landing,'p':p,'x':lx,'y':64-ly,'dx':dx,'dy':4}
  queue=deque([(child,0,0)]);seen=set();value=-100000
  while queue:
   node,depth,total=queue.popleft();end,ex,ey,duration=flight(node);cost=total+duration
   gain=s['left']-end['left']
   value=max(value,1000*gain-cost-30*depth)
   if ex is None or depth==2:continue
   for q in range(2,27):
    if not(8*q-1<=ex<=8*q+31):continue
    nd=-4 if ex+1<8*q+11 else (4 if ex>8*q+20 else 0)
    identity=(ex,ey,nd,tuple(end['g']))
    if identity in seen:continue
    seen.add(identity);queue.append(({**end,'p':q,'x':ex,'y':64-ey,'dx':nd,'dy':4},depth+1,cost))
  score=(value,-abs(p-s['p']))
  if best is None or score>best[0]:best=(score,p)
 assert best is not None
 return best[1]

class Review:
 def __init__(self,exe,out):self.exe=exe;self.out=out;self.m=Spectrum(exe,out);self.checks=[];self.trace=[];self.events=set()
 def wait(self,predicate,limit=30000,stride=1):
  for _ in range(limit//stride):
   if predicate():return
   self.m.frames(stride)
  raise AssertionError(('timeout',line(self.m),self.m.screen()))
 def text(self,s):self.wait(lambda:any(s in x for x in self.m.screen()),stride=20)
 def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
 def capture(self,name):self.m.frames(2);self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def ready(self):
  def okay():
   if line(self.m)!=200:return False
   try:s=state(self.m)
   except (AssertionError,IndexError):return False
   return s.get('served')==0 and s.get('steps')==0
  self.wait(okay)
  return state(self.m)
 def reset(self):
  self.m.frames(2)
  if 4000<=line(self.m)<=4060:self.wait(lambda:4030<=line(self.m)<=4060,limit=1000)
  self.m.call('press_key',key='r',hold_frames=40);s=self.ready()
  assert s['g']==[1]*18 and s['left']==18 and s['p']==14 and s['x']==127 and s['y']==40
  return s
 def step(self,key=''):
  old=state(self.m);expected,result,events=advance(old,key)
  if key:self.m.call('input',events=[{'Key':{'name':'space' if key==' ' else key,'pressed':True}}])
  for frames in range(1,501):
   self.m.frames(1);at=line(self.m)
   if result in ['miss','win'] and 4020<=at<=4060:break
   if at==510 or at==3000:
    try:s=state(self.m)
    except (AssertionError,IndexError):continue
    if s.get('steps')==old['steps']+1:break
  else:raise AssertionError(('no next step',key,line(self.m),self.m.screen()))
  if key:self.m.call('input',events=[{'Key':{'name':'space' if key==' ' else key,'pressed':False}}])
  s=state(self.m)
  for name in ['x','y','p','left','steps','g']:
   assert s[name]==expected[name],(name,key,old.get(name),expected[name],s[name],result,line(self.m))
  if result!='miss':assert (s['dx'],s['dy'])==(expected['dx'],expected['dy'])
  assert s['left']==sum(s['g']);assert all(x in (0,1) for x in s['g'])
  self.trace.append({'key':key,'frames':frames,'x':s['x'],'y':s['y'],'p':s['p'],'dx':s['dx'],'dy':s['dy'],'left':s['left'],'events':events,'result':result})
  self.events.update(events)
  return s,result
 def bitmap(self):
  self.m.frames(2);s=state(self.m);pixels=set()
  for y in range(16,153):pixels|={(15,y),(240,y)}
  pixels.update((x,152) for x in range(15,241))
  art=[[127,255,255,255,255,255,255,127],[255]*8,[254,255,255,255,255,255,255,254],[63,127,127,63,0,0,0,0],[255,255,255,255,0,0,0,0],[252,254,254,252,0,0,0,0]]
  def tile(x,top,rows):
   for j,b in enumerate(rows):
    for bit in range(8):
     if b&(128>>bit):pixels.add((x+bit,top-j))
  for r in range(3):
   for c in range(6):
    if s['g'][6*r+c]:
     for k in range(3):tile(32+32*c+8*k,143-16*r,art[k])
  for k,g in enumerate([3,4,4,5]):tile(8*int(s['p'])+8*k,31,art[g])
  pixels.update((int(s['x'])+dx,int(s['y'])+dy) for dx in (0,1) for dy in (0,1))
  memory=[]
  for addr in range(16384,22528,128):memory+=self.m.call('memory_read',addr=addr,len=128)['bytes']
  actual=set()
  for y in range(16,153):
   sy=175-y
   for x in range(15,241):
    off=((sy&192)<<5)|((sy&7)<<8)|((sy&56)<<2)|(x>>3)
    if memory[off]&(128>>(x&7)):actual.add((x,y))
  assert actual==pixels,('bitmap mismatch',len(actual-pixels),len(pixels-actual),list(actual-pixels)[:10],list(pixels-actual)[:10])
 def execute(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'bricks.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.text('S starts.')
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
  self.capture('instructions');self.m.call('press_key',key='s',hold_frames=4);s=self.ready();self.bitmap();self.capture('ready');self.record('fresh-tape-ready-state-and-pixel-art')
  for key,target in [('o',2),('p',26)]:
   self.m.call('input',events=[{'Key':{'name':key,'pressed':True}}])
   self.wait(lambda:line(self.m)==200 and state(self.m).get('p')==target and state(self.m).get('x')==8*target+15,limit=5000)
   self.m.call('input',events=[{'Key':{'name':key,'pressed':False}}])
   assert state(self.m)['served']==0
  self.bitmap();self.record('held-paddle-clamps-and-attached-ball-without-trails');self.reset()
  s,result=self.step(' ')
  for _ in range(500):
   if result!='moving':break
   s,result=self.step('o')
  assert result=='miss';self.bitmap();self.capture('miss');self.record('miss-freezes-valid-state-without-pixel-trails')
  self.reset();self.record('retry-restores-all-eighteen-bricks-and-ready-state')
  s,result=self.step(' ');target=choose_paddle(s);previous_dy=s['dy']
  for count in range(3000):
   if result=='win':break
   if count%20==0 or s['dy']!=previous_dy:target=choose_paddle(s)
   previous_dy=s['dy'];key='o' if s['p']>target else ('p' if s['p']<target else '')
   s,result=self.step(key)
   if count%50==0:print('PLAY',count,'left',s['left'],'ball',s['x'],s['y'],'target',target,flush=True)
   assert result!='miss',('autoplay missed',target,s)
  assert result=='win' and s['left']==0 and s['g']==[0]*18
  self.bitmap();self.capture('complete');self.record('eighteen-brick-clearance-agrees-with-rectangle-model')
  before=state(self.m);self.m.frames(150);after=state(self.m);assert after['steps']==before['steps'] and after['g']==before['g'];self.record('completion-stops-movement')
  self.reset();self.m.call('press_key',key='q',hold_frames=30);self.text('Finished. RUN');self.record('quit-from-ready')
  rom=[]
  for addr in range(0,16384,128):rom+=self.m.call('memory_read',addr=addr,len=128)['bytes']
  record={'status':'passed','configuration':'Emu198x stock 48K PAL; ROM entry and fresh tape load; keyboard input and read-only state','server':self.m.server,'source_sha256':sha(ROOT/'brick-bash.bas'),'tape_sha256':sha(self.out/'bricks.tap'),'binary_sha256':sha(Path(self.exe)),'rom_sha256':hashlib.sha256(bytes(rom)).hexdigest(),'checks':self.checks,'events':sorted(self.events),'trace':self.trace,'limits':'Native play approval and original hardware remain separate. Frame samples measure observation boundaries, not host input latency.'}
  (self.out/'results.json').write_text(json.dumps(record,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
 try:r.execute()
 except Exception:r.capture('failure');raise
 finally:r.m.close()
