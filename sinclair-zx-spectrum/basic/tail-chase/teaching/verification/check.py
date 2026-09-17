#!/usr/bin/env python3
"""Replay teaching checkpoints from ROM-loaded tapes, without state injection."""
import argparse,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from verify import state,line,D,body as ring_body,sha

def cells(s,unit):
 if unit<4:return [(s['r'],s['c'])]
 if unit==4:return list(zip(s['a'],s['b']))
 return ring_body(s)
def valid(s,unit):
 c=cells(s,unit);assert len(set(c))==len(c)
 if unit>=4:assert len(c)==s['n']==4+s['eaten']
 if unit>=7:assert s['g']==[int((r,k) in c) for r in range(1,17) for k in range(1,25)]
 return c
class Check:
 def __init__(self,item,exe,out):
  self.item=item;self.u=item['unit'];self.out=out/item['name'];self.m=Spectrum(exe,self.out);self.tests=[];self.trace=[];self.wrapped=False
 def record(self,name):self.tests.append(name);print('PASS',self.item['name'],name,flush=True)
 def snap(self,name):
  self.m.frames(2) # Frozen/stopped captures: let the display complete a scanout.
  self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def wait(self,predicate,limit=30000,stride=1):
  for _ in range(limit//stride):
   if predicate():return
   self.m.frames(stride)
  raise AssertionError((self.item['name'],'timeout',line(self.m),self.m.screen()))
 def load(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'tail.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start')
  if self.u==1:self.wait(lambda:any('9 STOP' in s for s in self.m.screen()),stride=20)
  else:
   self.wait(lambda:line(self.m) in (140,150) and self.initial(),limit=30000)
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
  assert sha(ROOT/self.item['source'])==json.loads((self.out/'build.json').read_text())['source_sha256']
  self.record('fresh-tape-and-ROM-stored-listing')
 def initial(self):
  try:s=state(self.m)
  except (AssertionError,IndexError):return False
  return s.get('steps')==0 and (self.u<6 or 'fc' in s)
 def step(self,key=''):
  old=state(self.m);before=valid(old,self.u);d=(old['dr'],old['dc']);new=D.get(key,d) if self.u>=3 else d
  if new==(-d[0],-d[1]):new=d
  dest=(before[-1][0]+new[0],before[-1][1]+new[1]);grow=self.u>=6 and dest==(old['fr'],old['fc'])
  collision=not(1<=dest[0]<=16 and 1<=dest[1]<=24) or (dest in before and (grow or dest!=before[0]))
  finished=grow and self.item['step']==1
  low0=self.m.call('memory_read',addr=23672,len=1)['bytes'][0]
  if key:self.m.call('input',events=[{'Key':{'name':key,'pressed':True}}])
  for _ in range(350):
   self.m.frames(1);at=line(self.m)
   if (collision or finished) and 4020<=at<=4060:break
   if at==410 or 3000<=at<=3050:
    try:s=state(self.m)
    except (AssertionError,IndexError):continue
    if s.get('steps')==old['steps']+1 and not (collision or finished):
     if grow:continue # diagnostic must disable the consumed food first
     break
   if grow and not finished and at==460:
    s=state(self.m)
    if s.get('steps')==old['steps']+1 and s.get('fr')==0:break
  else:raise AssertionError(('step timeout',key,line(self.m),self.m.screen()))
  if key:self.m.call('input',events=[{'Key':{'name':key,'pressed':False}}])
  s=state(self.m);now=valid(s,self.u)
  low1=self.m.call('memory_read',addr=23672,len=1)['bytes'][0];self.wrapped|=low1<low0
  expected=before if collision else ((before if grow else before[1:])+[dest])
  assert now==expected,(self.item['name'],key,before,expected,now)
  assert s['steps']==old['steps']+(not collision)
  if self.u>=6:assert s['eaten']==old['eaten']+grow
  self.trace.append({'key':key,'body':now,'grow':grow,'collision':collision,'steps':s['steps']})
  return s,collision,finished
 def retry(self):
  self.m.frames(2)
  if 4000<=line(self.m)<=4060:self.wait(lambda:4030<=line(self.m)<=4060,limit=500)
  self.m.call('press_key',key='r',hold_frames=60)
  self.wait(lambda:line(self.m) in (140,150) and self.initial(),limit=2500)
  s=state(self.m);valid(s,self.u);assert cells(s,self.u)==([(8,9)] if self.u<4 else [(8,6),(8,7),(8,8),(8,9)])
  self.record('retry-restores-initial-state')
 def execute(self):
  self.load()
  if self.u==1:
   ptr=self.m.call('memory_read',addr=23675,len=2)['bytes'];addr=ptr[0]+256*ptr[1]
   assert self.m.call('memory_read',addr=addr+16,len=8)['bytes']==[60,126,252,204,204,252,126,60]
   if self.item['step']==2:assert self.m.call('memory_read',addr=addr,len=8)['bytes']==[255,129,129,129,255,129,129,255]
   self.snap('screen');self.record('original-UDG-bytes-and-stopped-display')
  else:
   valid(state(self.m),self.u)
   if self.u<8:
    self.step('j');self.step('x');self.record('reverse-and-irrelevant-input')
   if self.u<6:
    if self.u>=3:
     for key in 'kjil'*12:self.step(key)
     self.record('four-directions-and-repeated-loops')
     if self.u>=4:self.record('departing-tail-entry-and-distinct-body')
     if self.u>=5:self.record('circular-index-wraps')
     assert self.wrapped;self.record('FRAMES-low-byte-wrap-during-movement')
    for _ in range(30):
     _,hit,_=self.step()
     if hit:break
    assert hit;self.record('wall-rejects-without-changing-body');self.snap('wall')
   else:
    # The fixed food is one more step away after the two opening moves.
    if self.u<8:
     s,hit,finished=self.step();assert not hit and s['n']==5 and s['eaten']==1
    else:
     # Steer toward the actual food through real input, avoiding the body.
     from collections import deque
     for _ in range(500):
      s=state(self.m);c=cells(s,self.u);q=deque([(c[-1],(s['dr'],s['dc']),'')]);seen=set();route=None
      while q:
       pos,d,path=q.popleft()
       if pos==(s['fr'],s['fc']):route=path;break
       for key,nd in D.items():
        dest=(pos[0]+nd[0],pos[1]+nd[1])
        if nd==(-d[0],-d[1]) or not(1<=dest[0]<=16 and 1<=dest[1]<=24) or dest in c[1:] or (dest,nd) in seen:continue
        seen.add((dest,nd));q.append((dest,nd,path+key))
      assert route
      s,hit,finished=self.step(route[0]);assert not hit
      if finished:break
     assert finished and s['n']==5
    self.record('growth-keeps-tail-and-adds-one-head')
    if self.item['step']==2:
     for key in 'kji':s,hit,_=self.step(key)
     assert hit;self.record('five-cell-self-collision-preserves-body');self.snap('self-collision')
    else:
     before=cells(s,self.u);self.m.frames(100);assert cells(state(self.m),self.u)==before
     self.record('one-food-completion-freezes-body');self.snap('complete')
   self.retry()
   self.m.call('press_key',key='q',hold_frames=30);self.wait(lambda:any('Finished. RUN' in x for x in self.m.screen()),limit=500)
   self.record('quit')
  result={'status':'passed','checkpoint':self.item,'source_sha256':sha(ROOT/self.item['source']),'tape_sha256':sha(self.out/'tail.tap'),'checks':self.tests,'trace':self.trace,'method':'Fresh 48K ROM tape load; keyboard input; read-only state. Diagnostic steps deliberately continue after their single food.'}
  (self.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');a=p.parse_args()
 for item in json.loads((ROOT/'checkpoints.json').read_text()):
  if item['unit']==9 or (a.only and item['name']!=a.only):continue
  r=Check(item,a.emulator,a.output.resolve())
  try:r.execute()
  except Exception:r.snap('failure');raise
  finally:r.m.close()
