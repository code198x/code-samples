#!/usr/bin/env python3
"""Compare actual ROM-executed Volley drawing checkpoints, then verify colour restoration."""
import argparse,hashlib,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
from entry import Spectrum
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--baseline-tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output);checks=[];measurements=[]
def tick(n=1):m.frames(n)
def key(k,b):m.call('input',events=[{'Key':{'name':k,'pressed':b}}])
def has(s):return any(s in r for r in m.screen())
def wait(s):
 for _ in range(4000):
  if has(s):tick(30);return
  tick()
 raise AssertionError((s,m.screen()))
def edit(lines):
 for l in lines:m.statement(l);tick(60)
def run():m.statement('RUN');wait('S to serve')
def serve():
 key('s',True);tick(8);key('s',False)
 for _ in range(2000):
  tick();rows=m.screen()
  if 'Returns:' in rows[0] and any('o' in r[3:30] for r in rows[3:20]):return
 raise AssertionError(('serve did not draw a ball',rows))
def quit():
 tick(30);key('q',True)
 for _ in range(100):
  tick()
  if has('Finished.'):break
 key('q',False);tick(30);assert has('9 STOP'),m.screen()
def paper(r,c):return (m.call('memory_read',addr=22528+32*r+c,len=1)['bytes'][0]>>3)&7
def record(name):checks.append(name);print('PASS',name,flush=True)
def source(n):return {int(l.split()[0]):l for l in (ROOT/f'steps/step-{n:02}.bas').read_text().splitlines()}
def measure(stage,held=None):
 run();serve();seen=False;visible=[];positions=[]
 if held:key(held,True)
 for frame in range(2000):
  tick();rows=m.screen()
  if any('Miss.' in r for r in rows):break
  balls=[(r,c) for r in range(3,20) for c in range(3,30) if rows[r][c]=='o']
  if balls:seen=True
  if seen:
   visible.append(bool(balls))
   if balls and (not positions or positions[-1]!=balls[0]):positions.append(balls[0])
 else:raise AssertionError(('no miss',stage,rows))
 if held:key(held,False)
 assert len(positions)>20
 longest=gap=0
 for v in visible:
  gap=0 if v else gap+1;longest=max(longest,gap)
 result={'stage':stage,'held':held,'frames':len(visible),'absent_frames':visible.count(False),'longest_absent_run':longest,'positions':positions}
 measurements.append(result);print('MEASURE',stage,held,len(visible),visible.count(False),longest,flush=True);quit()
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.baseline_tape));m.statement('LOAD "volley"');m.call('media_transport',slot='tape-1',transport='start');tick(6000);assert has('0 OK')
 previous=source(6)
 # Re-enter the baseline too: the supplied tape may predate entry-format changes.
 edit(list(previous.values()))
 measure(6)
 for stage in [7,8]:
  current=source(stage)
  edit([str(n) for n in previous.keys()-current.keys()])
  edit([v for n,v in current.items() if previous.get(n)!=v]);previous=current
  measure(stage);measure(stage,'x')
  # A controlled starting position near the right side gives time to inspect controls.
  edit(['20 LET x=5: LET y=10: LET dx=1: LET dy=1'])
  run();serve();tick(40)
  assert paper(10,15)==1 and paper(2,15)==5 and paper(10,30)==5 and paper(0,19)==0
  key('a',True);tick(140);key('a',False);tick(10)
  assert [paper(r,2) for r in range(3,20)]==[6]*3+[1]*14
  quit();run();serve();tick(40)
  key('z',True);tick(140);key('z',False);tick(10)
  assert [paper(r,2) for r in range(3,20)]==[1]*14+[6]*3
  # Every ball cell retains the uniform playfield's paper colour after movement.
  for r in range(3,20):
   attrs=m.call('memory_read',addr=22528+32*r+3,len=27)['bytes']
   assert all((v>>3)&7==1 for v in attrs),(stage,r,attrs)
  record(f'stage-{stage}-walls-paddle-clamps-and-restored-paper');quit();edit([current[20]])
 # Isolate actual collision edge cases; the main loop returns before retry.
 for name,y,paddle,dy,hit in [('centre',9,9,1,True),('top',8,9,1,True),('bottom',10,9,1,True),('above',7,9,1,False),('below',11,9,1,False),('corner',3,3,-1,True)]:
  edit([f'20 LET x=3: LET y={y}: LET dx=-1: LET dy={dy}',f'25 LET p={paddle}: LET score=0','260 STOP'])
  run();serve();tick(100)
  if hit:assert has('Returns: 1') and has('9 STOP') and paper(0,19)==0
  else:wait('Miss.');quit()
  record('colour-contact-'+name)
 edit([previous[20],previous[25],'260'])
 # Stabilised diagnostic capture: pause at the first drawn frame, then restore pacing.
 edit(['110 PAUSE 0']);run();serve();tick(100)
 m.call('save_screenshot',path=str(a.output/'court.png'))
 m.key('caps','space');tick(30);edit([previous[110]])
 m.statement('SAVE "volley"');m.enter();tick(6000);assert has('0 OK');tape=a.output/'volley.tap';m.call('save_tape',path=str(tape))
 m.close();m=Spectrum(a.emulator,a.output)
 m.call('load_media',slot='tape-1',kind='tape',path=str(tape));m.statement('LOAD "volley"');m.call('media_transport',slot='tape-1',transport='start');tick(6000);assert has('0 OK')
 run();serve();wait('Miss.');key('r',True);tick(40);assert has('Miss.');key('r',False);wait('S to serve');quit();record('fresh-colour-tape-play-retry-quit')
 old=next(x for x in measurements if x['stage']==7 and not x['held']);new=next(x for x in measurements if x['stage']==8 and not x['held'])
 assert old['positions']==new['positions'],(old['positions'],new['positions'])
 assert new['absent_frames']/new['frames']<old['absent_frames']/old['frames']
 result={'status':'passed','server':m.server,'configuration':'Emu198x Spectrum 0.22.1, 48K ROM, PAL, ROM source editing','baseline_tape_sha256':hashlib.sha256(a.baseline_tape.read_bytes()).hexdigest(),'checks':checks,'measurements':measurements,'sources':{f'step-{n:02}.bas':hashlib.sha256((ROOT/f'steps/step-{n:02}.bas').read_bytes()).hexdigest() for n in [6,7,8]},'tape_sha256':hashlib.sha256(tape.read_bytes()).hexdigest(),'limits':'One sample per frame of decoded screen memory, not emitted-video visibility or human flicker perception. Screenshot uses a declared PAUSE 0 experiment; tape restores PAUSE 2. MCP keys, not native host input.'}
 (a.output/'drawing-results.json').write_text(json.dumps(result,indent=2)+'\n')
finally:m.close()
