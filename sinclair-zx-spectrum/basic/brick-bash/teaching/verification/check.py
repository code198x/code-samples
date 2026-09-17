#!/usr/bin/env python3
"""Execute teaching tapes with real keyboard input and read-only observations."""
import argparse,concurrent.futures,importlib.util,json,sys
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
spec=importlib.util.spec_from_file_location('prototype_checks',ROOT.parent/'prototype/verification/check.py');proto=importlib.util.module_from_spec(spec);spec.loader.exec_module(proto)
state,line,sha=proto.state,proto.line,proto.sha

def normal(s,u):
 s=s.copy()
 if u==2:s['p']=14 # Model placeholder; no paddle variable exists in this checkpoint.
 if u<5:s['g']=[0]*18;s['left']=0
 elif u==5:s['g']=[0]*17+[s['alive']]
 return s

def model(s,key,u):
 z={k:s[k] for k in ['x','y','dx','dy','p','left','steps']};z['g']=s['g'].copy();events=[]
 if u>=3:z['p']=max(2,min(26,z['p']+{'o':-1,'p':1}.get(key,0)))
 x,y,dx,dy=z['x'],z['y'],z['dx'],z['dy'];nx=x+dx;ny=y+dy
 if nx<16:nx=32-nx;dx=abs(dx);events.append('left-wall')
 if nx>238:nx=476-nx;dx=-abs(dx);events.append('right-wall')
 if ny>149:ny=298-ny;dy=-abs(dy);events.append('top-wall')
 if ny<32:
  if u<4 or nx+1<8*z['p'] or nx>8*z['p']+31:return z,'miss',events
  ny=64-ny;dy=4
  if u>=8:dx=-4 if nx+1<8*z['p']+11 else (4 if nx>8*z['p']+20 else 0)
  events.append('paddle-'+str(dx))
 if u>=5:
  h=proto.brick_at(nx,y,z['g'])
  if h is not None:dx=-dx;nx=x;z['g'][h]=0;z['left']-=1;events.append('brick-side')
  h=proto.brick_at(nx,ny,z['g'])
  if h is not None:dy=-dy;ny=y;z['g'][h]=0;z['left']-=1;events.append('brick-vertical')
  if z['left']==0:z.update(dx=dx,dy=dy);return z,'win',events
 z.update(x=nx,y=ny,dx=dx,dy=dy,steps=z['steps']+1)
 assert proto.brick_at(nx,ny,z['g']) is None
 return z,'moving',events

class Check(proto.Review):
 def __init__(self,item,exe,out):
  super().__init__(exe,out/item['name']);self.item=item;self.u=item['unit']
 def capture(self,name):
  if name=='failure':return proto.Review.capture(self,name)
  if name in ('miss','complete'):self.text('Q quits')
  font=[]
  for addr in range(15616,16384,128):font+=self.m.call('memory_read',addr=addr,len=128)['bytes']
  labels=[]
  if name in ('miss','complete'):labels=[(0,2,'BRICK BASH'),(1,2,state(self.m)['e$']),(21,2,'R plays again       Q quits')]
  def readable(actual):
   for row,col,text in labels:
    for n,ch in enumerate(text):
     glyph=font[(ord(ch)-32)*8:(ord(ch)-31)*8]
     for y,bits in enumerate(glyph):
      for x in range(8):
       if (((col+n)*8+x,row*8+y) in actual)!=bool(bits&(128>>x)):return False
   return True
  target=self.out/(name+'.png')
  for attempt in range(64):
   self.m.frames(10);self.m.call('save_screenshot',path=str(target))
   with Image.open(target) as im:
    assert im.size==(352,296)
    rgb=im.convert('RGB');actual={(x,y) for y in range(176) for x in range(256) if rgb.getpixel((48+x,48+y))!=(0,0,0)}
   if not readable(actual):continue
   memory=[]
   for addr in range(16384,22528,128):memory+=self.m.call('memory_read',addr=addr,len=128)['bytes']
   expected=set()
   for sy in range(176):
    for x in range(256):
     off=((sy&192)<<5)|((sy&7)<<8)|((sy&56)<<2)|(x>>3)
     if memory[off]&(128>>(x&7)):expected.add((x,sy))
   if actual==expected:break
  else:raise AssertionError(('no complete rendered capture',name))
  if not hasattr(self,'captures'):self.captures=[]
  self.captures.append({'name':name,'settling_frames':10*(attempt+1),'scope':'Top 176 display rows match RAM; result labels also match ROM font glyphs. Original PNG is inspected, never edited.'})
  (self.out/'captures.json').write_text(json.dumps(self.captures,indent=2)+'\n')
 def current(self):return normal(state(self.m),self.u)
 def initial(self):
  if not 200<=line(self.m)<=320:return False
  try:return state(self.m).get('steps')==0
  except (AssertionError,IndexError):return False
 def load(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'bricks.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start')
  if self.u==1:self.text('9 STOP')
  elif self.u==6:self.text('Ball X')
  elif self.u==2:self.text('Ball reached the bottom.');self.bitmap();self.reset()
  else:self.wait(self.initial)
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
  assert sha(ROOT/self.item['source'])==json.loads((self.out/'build.json').read_text())['source_sha256']
  self.record('fresh-tape-and-ROM-stored-listing')
 def step(self,key=''):
  old=self.current();expected,result,events=model(old,key,self.u)
  if key:self.m.call('input',events=[{'Key':{'name':'space' if key==' ' else key,'pressed':True}}])
  for frames in range(1,501):
   self.m.frames(1);at=line(self.m)
   if result!='moving' and 4020<=at<=4060:break
   if at in (510,3000) and state(self.m).get('steps')==old['steps']+1:break
  else:raise AssertionError(('step timeout',self.u,line(self.m),self.m.screen()))
  if key:self.m.call('input',events=[{'Key':{'name':'space' if key==' ' else key,'pressed':False}}])
  s=self.current()
  for name in ['x','y','p','left','steps','g']:assert s[name]==expected[name],(self.u,name,key,expected[name],s[name],result)
  if result!='miss':assert (s['dx'],s['dy'])==(expected['dx'],expected['dy'])
  assert s['left']==sum(s['g'])
  self.trace.append({'key':key,'frames':frames,**{k:s[k] for k in ['x','y','dx','dy','p','left','steps']},'events':events,'result':result});self.events.update(events)
  return s,result
 def reset(self):
  self.m.frames(2)
  if 4000<=line(self.m)<=4060:self.wait(lambda:4030<=line(self.m)<=4060,limit=1000)
  self.m.call('input',events=[{'Key':{'name':'r','pressed':True}}])
  self.wait(lambda:line(self.m) in (200,3000) and state(self.m).get('steps')==0 and state(self.m).get('p',14)==14 and state(self.m).get('x')==127,limit=3000)
  self.m.call('input',events=[{'Key':{'name':'r','pressed':False}}])
  if self.u>=3:self.wait(self.initial,limit=1500)
  s=self.current();assert (s['x'],s['y'],s['p'],s['dx'],s['dy'])==(127,40,14,4,4)
  assert s['left']==(18 if self.u>=7 else (1 if self.u==5 else 0))
  return s
 def bitmap(self,ball=True):
  self.m.frames(2);s=state(self.m);pixels={(x,152) for x in range(15,241)}
  for y in range(16,153):pixels|={(15,y),(240,y)}
  art=[[127,255,255,255,255,255,255,127],[255]*8,[254,255,255,255,255,255,255,254],[63,127,127,63,0,0,0,0],[255,255,255,255,0,0,0,0],[252,254,254,252,0,0,0,0]]
  def tile(x,top,rows):
   for j,b in enumerate(rows):
    for bit in range(8):
     if b&(128>>bit):pixels.add((x+bit,top-j))
  if self.u>=5:
   g=normal(s,self.u)['g']
   for i,live in enumerate(g):
    if live:
     r,c=divmod(i,6)
     for k in range(3):tile(32+32*c+8*k,143-16*r,art[k])
  if self.u>=3 and self.u!=6:
   for k,glyph in enumerate([3,4,4,5]):tile(8*int(s['p'])+8*k,31,art[glyph])
  if ball:pixels.update((int(s['x'])+dx,int(s['y'])+dy) for dx in (0,1) for dy in (0,1))
  memory=[]
  for addr in range(16384,22528,128):memory+=self.m.call('memory_read',addr=addr,len=128)['bytes']
  actual=set()
  for y in range(16,153):
   sy=175-y
   for x in range(15,241):
    off=((sy&192)<<5)|((sy&7)<<8)|((sy&56)<<2)|(x>>3)
    if memory[off]&(128>>(x&7)):actual.add((x,y))
  assert actual==pixels,('bitmap',self.u,len(actual-pixels),len(pixels-actual),list(actual-pixels)[:8],list(pixels-actual)[:8])
 def inspector(self):
  tests=[(30,136),(31,136),(31,136),(56,136),(32,134),(64,135),(192,104),(215,111),(216,104),(0,0),(255,175),(32,144),(32,120)]
  g=[1]*18
  for x,y in tests:
   self.m.text(str(x));self.m.enter();self.text('Ball Y');self.m.text(str(y));self.m.enter();self.text('Ball X')
   s=state(self.m);h=proto.brick_at(x,y,g)
   assert s['hit']==int(h is not None),(x,y,s['hit'],h)
   if h is not None:g[h]=0
   assert s['g']==g and s['left']==sum(g)
   self.trace.append({'probe':[x,y],'hit':s['hit'],'row':s['br'],'column':s['bc'],'left':s['left']})
  self.bitmap(False);self.capture('inspector');self.record('probe-bounds-gaps-single-pixel-overlap-and-removed-bricks')
  self.m.text('-1');self.m.enter();self.text('Finished. RUN');self.record('inspector-exit')
 def execute(self):
  self.load()
  if self.u==1:
   self.bitmap();self.capture('drawing')
   self.m.statement('GO SUB 3000');self.bitmap(False);self.capture('erased')
   self.m.statement('GO SUB 3000');self.bitmap();self.record('four-distinct-pixels-toggle-off-and-back-without-damage')
  elif self.u==6:self.inspector()
  else:
   if self.u>=3:
    for key,target in [('o',2),('p',26)]:
     self.m.call('input',events=[{'Key':{'name':key,'pressed':True}}])
     self.wait(lambda:line(self.m)==200 and state(self.m).get('p')==target and state(self.m).get('x')==8*target+15,limit=5000)
     self.m.call('input',events=[{'Key':{'name':key,'pressed':False}}])
    self.bitmap();self.record('held-paddle-clamps-and-attached-ball');self.reset()
   if self.u>=5:
    s,result=self.step(' ')
    for _ in range(1600):
     if result=='win':break
     # Find the next landing using the independent geometry, before paddle contact.
     z=s;res="moving"
     for n in range(500):
      if z['y']+z['dy']<32:break
      z,res,_=model(z,'',self.u)
      if res=='win':break
     if res=='win':target=s['p']
     else:
      nx=z['x']+z['dx']
      if nx<16:nx=32-nx
      if nx>238:nx=476-nx
      if self.u>=8:target=proto.choose_paddle(s)
      else:target=max(2,min(26,(nx-15)//8))
     key='o' if s['p']>target else ('p' if s['p']<target else '')
     s,result=self.step(key);assert result!='miss'
    assert result=='win';self.bitmap();self.capture('complete');self.record('clearance-agrees-with-independent-rectangle-model')
    before=self.current();self.m.frames(150);assert self.current()['steps']==before['steps'];self.record('completion-stops-movement');self.reset()
   if self.u==5:
    self.m.call('input',events=[{'Key':{'name':'o','pressed':True}}])
    self.wait(lambda:line(self.m)==200 and state(self.m).get('p')==2 and state(self.m).get('x')==31,limit=5000)
    self.m.call('input',events=[{'Key':{'name':'o','pressed':False}}])
   s,result=self.step(' ' if self.u>=3 else '')
   if self.u==4:
    # Follow several landings before deliberately missing.
    catches=0
    for _ in range(250):
     z=s
     for n in range(100):
      if z['y']+z['dy']<32:break
      z,_,_=model(z,'',self.u)
     target=max(2,min(26,(z['x']+z['dx']-15)//8))
     key='o' if s['p']>target else ('p' if s['p']<target else '')
     s,result=self.step(key);assert result=='moving'
     catches+=any(e.startswith('paddle-') for e in self.trace[-1]['events'])
     if catches>=3:break
    assert catches>=3;self.record('repeated-catches-preserve-horizontal-direction')
   for _ in range(500):
    if result!='moving':break
    s,result=self.step('o' if self.u>=3 else '')
   assert result=='miss';self.bitmap();self.capture('miss');self.record('bottom-or-miss-preserves-last-valid-ball-without-trails')
   self.reset();self.record('retry-restores-stage-state')
   self.m.call('press_key',key='q',hold_frames=20);self.text('Finished. RUN');self.record('quit')
  record={'status':'passed','checkpoint':self.item,'source_sha256':sha(ROOT/self.item['source']),'tape_sha256':sha(self.out/'bricks.tap'),'binary_sha256':sha(Path(self.exe)),'server':self.m.server,'checks':self.checks,'events':sorted(self.events),'trace':self.trace,'method':'Fresh ROM tape load; keyboard only; read-only state and bitmap checks. Inspector coordinates are entered through its INPUT prompts, not injected.'}
  (self.out/'results.json').write_text(json.dumps(record,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');p.add_argument('--jobs',type=int,default=1);a=p.parse_args()
 items=[item for item in json.loads((ROOT/'checkpoints.json').read_text()) if item['unit']!=9 and (not a.only or a.only==item['name'])]
 def run(item):
  r=Check(item,a.emulator,a.output.resolve())
  try:r.execute()
  except Exception:r.capture('failure');raise
  finally:r.m.close()
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:list(pool.map(run,items))
