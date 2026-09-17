#!/usr/bin/env python3
"""Extra paddle-edge/centre and quit-phase checks through ordinary ROM input."""
import argparse,json
from pathlib import Path
from check import Review,Spectrum,state,line,sha,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
def load(start=True):
 r.m.call('load_media',slot='tape-1',kind='tape',path=str(r.out/'bricks.tap'));r.m.statement('LOAD ""');r.m.call('media_transport',slot='tape-1',transport='start');r.text('S starts.')
 if start:r.m.call('press_key',key='s',hold_frames=4);r.ready()
def aim_first_return(target,expected):
 s,result=r.step(' ')
 for _ in range(200):
  old=s;key='o' if s['p']>target else ('p' if s['p']<target else '')
  s,result=r.step(key);assert result=='moving'
  if old['dy']<0 and old['y']+old['dy']<32:
   assert s['dy']==4 and s['dx']==expected,(target,old,s)
   return old,s
 raise AssertionError('no paddle contact')
try:
 load(False);r.m.call('press_key',key='q',hold_frames=20);r.text('Finished. RUN');r.record('quit-from-title')
 r.m.close();r.m=Spectrum(a.emulator,r.out);load()
 aim_first_return(25,0);r.record('centre-contact-returns-vertically')
 r.reset();r.record('restart-during-flight-restores-ready-state')
 for target,expected,label in [(21,-4,'left'),(17,4,'right')]:
  r.m.call('input',events=[{'Key':{'name':'o','pressed':True}}])
  r.wait(lambda:line(r.m)==200 and state(r.m).get('p')==2 and state(r.m).get('x')==31,limit=5000)
  r.m.call('input',events=[{'Key':{'name':'o','pressed':False}}])
  before,after=aim_first_return(target,expected)
  nx=before['x']+before['dx']
  if label=='left':assert nx+1==8*after['p']
  else:assert nx==8*after['p']+31
  r.record(label+'-paddle-edge-one-pixel-overlap-returns-'+str(expected));r.reset()
 r.step(' ');r.m.call('press_key',key='q',hold_frames=40);r.text('Finished. RUN');r.record('quit-during-flight')
 r.m.close();r.m=Spectrum(a.emulator,r.out);load();s,result=r.step(' ')
 for _ in range(200):
  if result=='miss':break
  s,result=r.step('o')
 assert result=='miss';r.m.frames(5);r.wait(lambda:4030<=line(r.m)<=4060,limit=1000)
 r.m.call('press_key',key='q',hold_frames=40);r.text('Finished. RUN');r.record('quit-from-result')
 (r.out/'controls.json').write_text(json.dumps({'status':'passed','source_sha256':sha(ROOT/'brick-bash.bas'),'tape_sha256':sha(r.out/'bricks.tap'),'checks':r.checks,'trace':r.trace,'method':'Fresh ROM tape loads and ordinary held keyboard input; no altered source or state fixtures.'},indent=2)+'\n')
finally:r.m.close()
