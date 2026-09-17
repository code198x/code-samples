#!/usr/bin/env python3
"""Normal-frame keyboard trials and original captures, separately from CPU-stepped model checks."""
import argparse,json,sys
from pathlib import Path
from PIL import Image
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from check import sha,state
class Frames:
 def __init__(self,item,exe,out):self.item=item;self.exe=exe;self.out=out/item['name'];self.m=Spectrum(exe,self.out);self.captures=[];self.checks=[]
 def wait(self,text):
  for _ in range(2000):
   if any(text in row for row in self.m.screen()):return
   self.m.frames(20)
  raise AssertionError((text,self.m.screen()))
 def load(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'drift.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start')
  if self.item['kind']=='drawing':self.wait('STOP')
  elif self.item['kind']=='finished':
   self.wait('S starts.')
   if not any(c['name']=='instructions' for c in self.captures):self.capture('instructions')
   self.m.call('press_key',key='s',hold_frames=4);self.m.frames(200)
  else:self.wait('DRIFT');self.m.frames(200)
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
 def capture(self,name):
  target=self.out/(name+'.png')
  for attempt in range(64):
   self.m.frames(10);self.m.call('save_screenshot',path=str(target))
   with Image.open(target) as im:
    assert im.size==(352,296);rgb=im.convert('RGB')
    actual={(x,y) for y in range(176) for x in range(256) if rgb.getpixel((48+x,48+y))!=(0,0,0)}
   memory=[]
   for addr in range(16384,22528,128):memory+=self.m.call('memory_read',addr=addr,len=128)['bytes']
   expected={(x,y) for y in range(176) for x in range(256) if memory[((y&192)<<5)|((y&7)<<8)|((y&56)<<2)|(x>>3)]&(128>>(x&7))}
   if actual==expected:break
  else:raise AssertionError(('capture mismatch',name,len(actual-expected),len(expected-actual),self.m.screen()))
  self.captures.append(dict(name=name,settling_frames=10*(attempt+1),scope='Normal video-frame execution; original PNG top 176 display rows match RAM bitmap; no image editing.'))
  print('CAPTURE',self.item['name'],name,flush=True)
 def until(self,predicate):
  for frames in range(0,12000,2):
   self.m.frames(2);s=state(self.m)
   if predicate(s):return s
  raise AssertionError(('normal-frame flight timeout',s,self.m.screen()))
 def hold_until(self,key,predicate):
  self.m.call('input',events=[{'Key':{'name':key,'pressed':True}}]);s=self.until(predicate)
  self.m.call('input',events=[{'Key':{'name':key,'pressed':False}}]);self.m.frames(2);return s
 def dock(self):
  self.hold_until('space',lambda s:s['vx']>.5 and s['vy']>.5)
  self.until(lambda s:s['y']>=96)
  self.hold_until('o',lambda s:s['h']==6)
  self.hold_until('space',lambda s:abs(s['vx'])<.01 and abs(s['vy'])<.01)
  self.hold_until('o',lambda s:s['h']==1)
  self.hold_until('space',lambda s:s['vx']>.99)
  self.until(lambda s:s['x']>=185)
  self.hold_until('o',lambda s:s['h']==5)
  self.hold_until('space',lambda s:s['vx']**2+s['vy']**2<=.16 and 190<=s['x']<=210 and 94<=s['y']<=114)
  self.wait('Docked.');self.m.frames(40);s=state(self.m)
  assert 190<=s['x']<=210 and 94<=s['y']<=114 and s['vx']**2+s['vy']**2<=.16,s
  self.capture('docked');self.checks.append('normal-frame-two-axis-docking')
  self.m.call('press_key',key='q',hold_frames=80);self.wait('Finished. RUN');self.checks.append('normal-frame-docked-result-quit')
 def run(self):
  self.load();kind=self.item['kind']
  if kind=='drawing':self.capture('drawing');self.checks.append('normal-frame-static-drawing')
  elif kind=='heading':
   self.m.call('press_key',key='o',hold_frames=100);self.m.frames(60);s=state(self.m)
   assert s['steps']>2 and s['x']==48 and s['y']==56
   self.m.call('press_key',key='q',hold_frames=80);self.wait('Finished. RUN');self.capture('heading');self.checks.append('normal-frame-held-turn-and-quit')
  else:
   self.m.call('press_key',key='space',hold_frames=160);self.m.frames(60);s=state(self.m);assert s['vx']>0 and s['vy']>0
   self.m.call('press_key',key='q',hold_frames=100);self.wait('Finished. RUN');self.capture('velocity' if kind!='flight' else 'flight');self.checks.append('normal-frame-thrust-coast-and-flight-quit')
   # A new process rules out stale keyboard, parser or stopped-debugger state.
   self.m.close();self.m=Spectrum(self.exe,self.out);self.load()
   self.m.call('press_key',key='space',hold_frames=3000);self.m.frames(60);self.wait('Hull lost.');self.capture('crash')
   self.m.call('press_key',key='r',hold_frames=80);self.m.frames(200);s=state(self.m)
   assert s['x']==48 and s['y']==56 and s['vx']==s['vy']==0
   self.m.call('press_key',key='q',hold_frames=100);self.wait('Finished. RUN');self.checks.append('normal-frame-crash-retry-and-quit')
  if kind in ('docking','finished'):
   self.m.close();self.m=Spectrum(self.exe,self.out);self.load();self.dock()
  (self.out/'captures.json').write_text(json.dumps(self.captures,indent=2)+'\n')
  (self.out/'frames.json').write_text(json.dumps(dict(status='passed',source_sha256=sha(ROOT/self.item['source']),tape_sha256=sha(self.out/'drift.tap'),checks=self.checks),indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');a=p.parse_args()
 for item in json.loads((ROOT/'checkpoints.json').read_text()):
  if a.only and a.only!=item['name']:continue
  r=Frames(item,a.emulator,a.output.resolve())
  try:r.run()
  finally:r.m.close()
