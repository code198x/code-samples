"""Fresh-tape loading, side contact, opposite controls and bounds in the real ROM."""
import argparse,json
from pathlib import Path
from entry import Spectrum,ROOT
from state import variables
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output);checks=[]
def key(k,d):m.call('input',events=[{'Key':{'name':k,'pressed':d}}])
def wait(text):
 for _ in range(1500):
  if any(text in row for row in m.screen()):return
  m.frames(5)
 raise AssertionError((text,m.screen()))
def launch():
 m.statement('RUN');wait('S launches');m.call('press_key',key='s',hold_frames=3);wait('FUEL')
def quit():
 m.frames(60);key('q',True);m.frames(40);key('q',False);wait('9 STOP');m.frames(100)
def record(name):checks.append(name);print('PASS',name,flush=True)
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape));m.statement('LOAD "touchdown"');m.call('media_transport',slot='tape-1',transport='start');m.frames(7000);wait('0 OK')
 launch();wait('Terrain collision.');quit();record('fresh-final-tape-launch-contact-quit')
 for name,x,y,v,keys,expected in [('ascending-side-contact',10,1490,-4,['p','space'],'Terrain collision.'),('opposing-steering-cancels',24,1899,0,['o','p'],'Safe landing!'),('off-right-pad-edge',27,1899,0,[],'Terrain collision.')]:
  m.statement(f'130 LET x={x}: LET y={y}: LET v={v}: LET fuel=45: LET r=INT (y/100): LET burn=0')
  launch()
  for k in keys:key(k,True)
  wait(expected)
  for k in keys:key(k,False)
  state=variables(m)
  if name=='ascending-side-contact':assert state['side']==1 and state['x']==10 and 1400<state['y']<=1490,state
  if name=='opposing-steering-cancels':assert state['x']==24,state
  m.frames(60)
  if name=='opposing-steering-cancels':m.call('save_screenshot',path=str(a.output/'landing-result.png'))
  record(name);quit()
 m.statement('130 LET x=30: LET y=400: LET v=0: LET fuel=45: LET r=4: LET burn=0')
 launch();key('p',True);key('space',True);history=[]
 for _ in range(70):
  m.frames(5);history.append(variables(m))
 assert all(v['x']==30 and v['y']>=300 and v['fuel']>=0 for v in history),history[-1]
 assert any(v['y']==300 and v['v']==0 for v in history),history[-1]
 for k in ['p','space']:key(k,False)
 record('held-right-clamp-and-upper-boundary');quit()
 # Exhaustion switches off the engine while the craft is still above ground.
 m.statement('130 LET x=24: LET y=400: LET v=0: LET fuel=1: LET r=4: LET burn=0')
 launch();key('space',True);m.frames(130);state=variables(m)
 assert state['fuel']==0 and state['burn']==0 and state['y']<1900,state
 key('space',False);wait('Too fast');record('empty-tank-continues-falling-with-thrust-held');quit()
 (a.output/'edges-results.json').write_text(json.dumps({'checks':checks,'method':'Fresh final tape, ROM test-only line edits, MCP keyboard events and read-only variable inspection. Test edits are never saved.'},indent=2)+'\n')
finally:m.close()
