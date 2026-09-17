#!/usr/bin/env python3
"""Ordinary-frame teaching trials, including input before/after buffering."""
import argparse,json,sys,importlib.util,statistics
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('teaching_trial',HERE/'check.py');module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
Trial=module.Trial;state=module.state;line=module.line;ROOT=module.ROOT;sha=module.sha
from check import advance,unpack,route
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only',required=True);a=p.parse_args();r=Trial(a.emulator,a.output.resolve()/a.only,a.only);name=a.only
small=name in ('clock','crossing');simulation=module.advance_small if small else advance
unpack_state=module.unpack_small if small else unpack
checks=[];observations=[];traces=[]
def record(text):checks.append(text);print('PASS',name,text,flush=True)
def until(test,limit=16000):
 for f in range(limit):
  r.m.frames(1)
  try:
   if test():return f+1
  except (AssertionError,IndexError):continue
 raise AssertionError(('timeout',line(r.m),r.m.screen()))
def reset():
 r.event('r',True);until(lambda:line(r.m)==100);r.event('r',False)
 until(lambda:line(r.m)==200 and state(r.m).get('steps')==0)
 return state(r.m)
def tick(key=''):
 before=state(r.m);s0=unpack_state(before)
 expected,result=simulation(s0,key,True) if small else simulation(s0,key)
 if key and name in ('buffered','finished'):r.m.call('press_key',key=key,hold_frames=4)
 else:r.event(key,True)
 until(lambda:4020<=line(r.m)<=4060 or state(r.m)['steps']>before['steps'])
 r.event(key,False);r.m.frames(0);after=state(r.m)
 assert unpack_state(after)==expected,(key,s0,expected,unpack_state(after))
 traces.append(dict(key=key,before=s0,after=unpack_state(after),result=result))
 return after,result
try:
 r.m.call('load_media',slot='tape-1',kind='tape',path=str(r.out/'quickstep.tap'));r.m.statement('LOAD ""');r.m.call('media_transport',slot='tape-1',transport='start')
 r.wait('S starts.' if name=='finished' else 'QUICKSTEP')
 if name=='board':
  r.wait('STOP');r.capture('frame-board');record('fresh-load-draws-and-stops')
 else:
  if name=='finished':r.m.call('press_key',key='s',hold_frames=4)
  until(lambda:line(r.m)==200 and 'steps' in state(r.m))
  if name in ('walk','lane'):
   r.event('j',True);r.m.frames(200);assert state(r.m)['x']==6;r.event('j',False);r.m.frames(10);record('held-key-is-a-single-step')
   if name=='lane':
    r.event('space',True);r.m.frames(200);assert state(r.m)['p']==9;r.event('space',False);r.m.frames(10);r.lane_bitmap();record('space-advances-one-lane-step')
   reset();r.capture('frame-board');record('ordinary-reset')
  else:
   reset();previous=0;lastclock=None;wraps=0
   for f in range(700):
    r.m.frames(1)
    currentclock=r.m.call('memory_read',addr=23672,len=1)['bytes'][0]
    if lastclock is not None and currentclock<lastclock:wraps+=1
    lastclock=currentclock
    try:s=state(r.m)
    except (AssertionError,IndexError):continue
    if s['steps']!=previous:
     assert s['steps']==previous+1;previous=s['steps'];observations.append(dict(frame=f,step=previous))
   assert wraps>=2 and len(observations)>=6;record('ordinary-safe-wait-across-frame-byte-wraps')
   reset();until(lambda:line(r.m)==370);before=state(r.m)['steps'];r.m.call('press_key',key='j',hold_frames=4)
   until(lambda:state(r.m)['steps']>=before+2)
   expected_x=6 if name in ('buffered','finished') else 7
   assert state(r.m)['x']==expected_x,(name,state(r.m));record('short-tap-retained' if expected_x==6 else 'polling-only-short-tap-is-missed')
   reset();r.event('j',True);r.m.frames(950);r.event('j',False);r.m.frames(100);assert state(r.m)['x']==0;record('held-left-repeats-and-clamps')
   reset();r.capture('frame-board');reset()
   if name!='clock':
    path=module.route_small(unpack_state(state(r.m)),lambda s:s[:2]==(7,0)) if small else route(unpack_state(state(r.m)))
    for key in path:s,result=tick(key)
    assert result=='win';r.wait('Across!');r.m.frames(40);r.capture('frame-across');record('ordinary-complete-crossing-agrees-with-model')
    reset();record('ordinary-retry-after-win')
  r.m.call('press_key',key='q',hold_frames=40);r.wait('Finished. RUN');record('ordinary-active-quit')
 periods=[b['frame']-a['frame'] for a,b in zip(observations,observations[1:])]
 data=dict(status='passed',name=name,source_sha256=sha(ROOT/name/'quickstep.bas'),tape_sha256=sha(r.out/'quickstep.tap'),checks=checks,trace=traces,captures=r.captures,observations=observations,timing=dict(median=statistics.median(periods),minimum=min(periods),maximum=max(periods),samples=len(periods)) if periods else None,method='Ordinary run_frames and physical keys; no CPU stepping or injected state')
 (r.out/'frames.json').write_text(json.dumps(data,indent=2)+'\n')
finally:r.m.close()
