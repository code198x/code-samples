#!/usr/bin/env python3
"""Ordinary-frame controls, timing and original captures. No instruction stepping."""
import argparse,json,statistics
from pathlib import Path
from PIL import Image
from check import Review,state,line,sha,ROOT,unpack,route
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve());captures=[]
def capture(name):
 target=r.out/(name+'.png')
 for attempt in range(80):
  r.m.frames(2);r.m.call('save_screenshot',path=str(target));im=Image.open(target).convert('RGB')
  ram=[]
  for addr in range(16384,23296,128):ram+=r.m.call('memory_read',addr=addr,len=min(128,23296-addr))['bytes']
  ok=True
  for y in range(176):
   for x in range(256):
    attr=ram[6144+(y//8)*32+x//8];bit=ram[((y&192)<<5)|((y&7)<<8)|((y&56)<<2)|(x>>3)]&(128>>(x&7));col=(attr&7) if bit else ((attr>>3)&7)
    actual=im.getpixel((48+x,48+y));expected=tuple(bool(col&b) for b in (2,4,1))
    if tuple(c>0 for c in actual)!=expected:ok=False;break
   if not ok:break
  if ok:break
 else:raise AssertionError(('capture/RAM mismatch',name))
 captures.append(dict(name=name,sha256=sha(target),settling_frames=2*(attempt+1),method='Original emitted PNG; top 176 rows checked against RAM bitmap and colour attributes; no image editing.'))
 print('CAPTURE',name,flush=True)
def until(test,limit=10000):
 for frames in range(limit):
  r.m.frames(1)
  try:
   if test():return frames+1
  except (AssertionError,IndexError):
   # A video frame can stop halfway through the ROM rewriting a variable.
   # Let it finish before decoding that read-only observation.
   continue
 raise AssertionError(('timeout',line(r.m),state(r.m),r.m.screen()))
def reset():
 r.event('r',True);until(lambda:line(r.m)==100);r.event('r',False)
 until(lambda:line(r.m)==200 and state(r.m).get('steps')==0)
 return state(r.m)
def step(key=''):
 before=state(r.m)['steps']
 if key:r.m.call('press_key',key=key,hold_frames=4)
 def finished():
  at=line(r.m)
  # Observe the counter itself: a busy update may pass line 200 between frames.
  return (4020<=at<=4060) or state(r.m)['steps']>before
 until(finished)
 s=state(r.m)
 print('FRAME STEP',key,unpack(s),s['steps'],line(r.m),flush=True)
 return s

try:
 r.load();r.m.frames(60);capture('instructions');r.m.call('press_key',key='s',hold_frames=4)
 until(lambda:line(r.m)==200 and 'steps' in state(r.m));capture('arena')
 # Measure the actual commits while resting, including busy and quiet beats.
 observations=[];previous=state(r.m)['steps']
 for f in range(1200):
  r.m.frames(1)
  # 470 is the stable end of a successful beat; sample only when nearby.
  at=line(r.m)
  if at in (440,450,460,470,200):
   try:s=state(r.m)
   except (AssertionError,IndexError):continue
   if s['steps']!=previous:previous=s['steps'];observations.append(dict(frame=f,step=previous))
 assert all(b['step']==a['step']+1 for a,b in zip(observations,observations[1:])), observations
 periods=[b['frame']-a['frame'] for a,b in zip(observations,observations[1:])];assert len(periods)>8
 r.record('ordinary-frame-safe-wait-and-measured-cadence')
 reset();r.event('j',True);r.m.frames(750);r.event('j',False);r.m.frames(120);assert state(r.m)['x']==0;r.record('held-left-repeats-and-clamps')
 # A short press during rendering must survive in the ROM latch until polling resumes.
 reset();until(lambda:line(r.m)==350);r.m.call('press_key',key='j',hold_frames=4)
 until(lambda:line(r.m)==200 and state(r.m)['steps']>=2);assert state(r.m)['x']==6,(state(r.m),line(r.m));r.record('four-frame-tap-during-update-is-retained')
 reset()
 path=route(unpack(state(r.m)));print('NORMAL ROUTE',path,flush=True)
 for key in path:
  step(key)
  if 4020<=line(r.m)<=4060:break
 r.wait('Across!');r.m.frames(40);capture('across');r.record('ordinary-frame-complete-crossing')
 frozen=unpack(state(r.m));r.m.frames(100);assert unpack(state(r.m))==frozen
 reset();r.record('ordinary-frame-retry-after-win')
 # Hold up until a collision or win; a deliberate collision is chosen from a safe strip.
 while True:
  from check import advance
  if advance(unpack(state(r.m)),'i')[1]=='blocked':step('i');break
  step()
 r.wait('not clear.');r.m.frames(40);capture('caught');r.record('ordinary-frame-collision')
 r.m.call('press_key',key='q',hold_frames=40);r.wait('Finished. RUN');r.record('ordinary-frame-result-quit')
 r.m.close();r.m=__import__('entry').Spectrum(a.emulator,r.out);r.load();r.m.call('press_key',key='q',hold_frames=40);r.wait('Finished. RUN');r.record('title-quit')
 r.m.close();r.m=__import__('entry').Spectrum(a.emulator,r.out);r.load();r.m.call('press_key',key='s',hold_frames=4);until(lambda:line(r.m)==200 and 'steps' in state(r.m));r.m.call('press_key',key='q',hold_frames=40);r.wait('Finished. RUN');r.record('active-game-quit')
 result=dict(status='passed',source_sha256=sha(ROOT/'quickstep.bas'),tape_sha256=sha(r.out/'quickstep.tap'),method='Ordinary run_frames and physical key events; read-only RAM observation; no instruction stepping or injected state',checks=r.checks,timing=dict(median=statistics.median(periods),minimum=min(periods),maximum=max(periods),samples=len(periods)),observations=observations,captures=captures)
 (r.out/'frames.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result['timing']),flush=True)
finally:r.m.close()
