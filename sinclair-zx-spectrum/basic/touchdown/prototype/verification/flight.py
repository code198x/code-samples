"""Exercise actual ROM flight with independent and combined keyboard events."""
import argparse,json,hashlib
from pathlib import Path
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output);checks=[]
def key(k,down):m.call('input',events=[{'Key':{'name':k,'pressed':down}}])
from state import variables as read_variables
def variables():return read_variables(m)
def wait(text,limit=6000):
 for _ in range(limit//5):
  if any(text in r for r in m.screen()):return
  m.frames(5)
 raise AssertionError((text,m.screen()))
def edit(lines):
 for l in lines:m.statement(l)
def quit():
 m.frames(60)
 key('q',True);m.frames(40);key('q',False);m.frames(50);wait('9 STOP');m.frames(100)
def launch():
 m.statement('RUN');wait('S launches');key('s',True);m.frames(5);key('s',False);wait('FUEL')
def check(name):checks.append(name);print('PASS',name,flush=True)
def save():
 m.statement('SAVE "touchdown"');m.enter();m.frames(10000);wait('0 OK');m.call('save_tape',path=str(a.output/'touchdown.tap'))
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape));m.statement('LOAD "touchdown"');m.call('media_transport',slot='tape-1',transport='start');m.frames(10000);wait('0 OK')
 # Update the side-contact guard through ordinary ROM editing.
 source={int(l.split()[0]):l for l in (ROOT/'steps/step-06.bas').read_text().splitlines()}
 edit([source[n] for n in [310,320,340,345,720,730]])
 launch();history=[];last=None;held=set()
 for frame in range(9000):
  m.frames(1);v=variables()
  if 'x' not in v:continue
  state=tuple(v.get(k) for k in ['x','y','v','fuel'])
  if state!=last:history.append({'frame':frame,**{k:v.get(k) for k in ['x','y','v','fuel']}});last=state
  if any('R retries' in r for r in m.screen()):break
  desired={'p'} if v['x']<24 else set()
  if v['x']<24:
   thrust=v['v']>=0
  else:
   thrust=(v['y']+max(0,v['v'])**2/8>=1820 and v['v']>=8)
  if thrust:desired.add('space')
  for k in held-desired:key(k,False)
  for k in desired-held:key(k,True)
  held=desired
 else:raise AssertionError(('autopilot timeout',m.screen()))
 for k in held:key(k,False)
 print('END',variables(),flush=True);print('\n'.join(m.screen()),flush=True)
 assert any('Safe landing!' in r for r in m.screen()),m.screen()
 check('safe-landing-from-fixed-start-with-combined-steering-and-thrust')
 m.call('save_screenshot',path=str(a.output/'safe-landing.png'))
 (a.output/'flight-history.json').write_text(json.dumps(history,indent=2)+'\n')
 m.frames(60)
 key('r',True);m.frames(40);assert any('R retries' in r for r in m.screen());key('r',False)
 for _ in range(500):
  m.frames(5)
  if variables().get('x')==6:break
 wait('FUEL')
 v=variables();assert v['fuel']==45 and v['x']==6,v
 check('held-retry-waits-for-release-and-resets-state')
 wait('Terrain collision.');check('uncontrolled-terrain-crash');quit()
 # Controlled initial conditions isolate contacts and resource limits in the actual program.
 cases=[('hard-pad',24,1890,40,45,'Too fast'),('safe-pad-left-edge',23,1899,0,45,'Safe landing'),('safe-pad-right-edge',26,1899,0,45,'Safe landing'),('off-pad',22,1899,0,45,'Terrain collision'),('empty-tank-coast',24,1899,0,0,'Safe landing'),('fast-fall',24,1850,60,0,'Too fast')]
 for name,x,y,speed,fuel,expected in cases:
  edit([f'130 LET x={x}: LET y={y}: LET v={speed}: LET fuel={fuel}: LET r=INT (y/100): LET burn=0'])
  launch()
  if fuel==0:key('space',True)
  wait(expected)
  if fuel==0:
   key('space',False);assert variables()['fuel']==0
  check(name);quit()
 edit([source[130]])
 # Sustained combined controls: top/left clamps and fuel cannot go negative.
 launch();key('o',True);key('space',True);m.frames(850)
 v=variables();print('HELD',v,flush=True);assert v['x']==1 and v['y']>=300 and v['fuel']>=0,v
 key('o',False);key('space',False);wait('Terrain collision.');check('held-left-and-thrust-clamps');quit()
 edit([source[130]])
 # The flat-pad and uneven-terrain intermediate sources must run too.
 previous=source
 for stage in [4,5,6]:
  current={int(l.split()[0]):l for l in (ROOT/f'steps/step-{stage:02}.bas').read_text().splitlines()}
  edit([str(n) for n in previous.keys()-current.keys()])
  edit([line for n,line in current.items() if previous.get(n)!=line])
  launch();wait('Terrain collision.');check(f'checkpoint-{stage}-launch-contact-retry-menu');quit();previous=current
 save()
 (a.output/'results.json').write_text(json.dumps({'checks':checks,'source_sha256':hashlib.sha256((ROOT/'steps/step-06.bas').read_bytes()).hexdigest(),'configuration':'Emu198x Spectrum 0.22.1; 48K PAL ROM; MCP keyboard events; no game-state writes','limits':'Scripted controls and declared test-only starting conditions; subjective play and original hardware remain separate.'},indent=2)+'\n')
finally:m.close()
