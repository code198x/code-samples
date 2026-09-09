#!/usr/bin/env python3
"""Enter maintained Volley checkpoints through the 48K ROM and exercise play."""
import argparse, hashlib, importlib.util, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
from entry import Spectrum
p=argparse.ArgumentParser();p.add_argument('--start-stage',type=int,choices=[1,6],default=1);p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output);previous={};checks=[]
def tick(n=1):m.frames(n)
def key(k,down):m.call('input',events=[{'Key':{'name':k,'pressed':down}}])
def has(s):return any(s in row for row in m.screen())
def wait(s,limit=3000):
 for _ in range(limit):
  if has(s):
   tick(30);return
  tick()
 raise AssertionError((s,m.screen()))
def record(name):
 checks.append({'name':name,'screen':m.screen()});print('PASS',name,flush=True)
 m.call('save_screenshot',path=str(a.output/(name+'.png')))
def stop():
 key('q',True);tick(30);key('q',False);tick(10)
def edit(lines):
 for line in lines:m.statement(line);tick(60)
def run():m.statement('RUN');tick(50)
def serve():key('s',True);tick(8);key('s',False);tick(20)
try:
 for stage in range(a.start_stage,7):
  path=ROOT/f'steps/step-{stage:02}.bas'
  current={int(l.split()[0]):l for l in path.read_text().splitlines()}
  if stage in [3,4]:
   # Stop demonstrations through BREAK (CAPS SHIFT + SPACE).
   m.key('caps','space');tick(30)
  for n in sorted(previous.keys()-current.keys()):edit([str(n)])
  edit([l for n,l in current.items() if previous.get(n)!=l]);previous=current
  run()
  if stage==1:tick(250);assert has('9 STOP');record('stage-01-edge-stop')
  elif stage in [2,3]:
   positions=[]
   for _ in range(150):
    tick(2);positions += [(r,c) for r,row in enumerate(m.screen()) for c,v in enumerate(row) if v=='o']
   assert len(set(positions))>5;record(f'stage-{stage:02}-moving')
  elif stage==4:
   key('a',True);tick(180);key('a',False);tick(10)
   assert all(m.screen()[r][2]=='I' for r in [3,4,5]);record('stage-04-upper-clamp')
   key('z',True);tick(250);key('z',False);tick(10)
   assert all(m.screen()[r][2]=='I' for r in [17,18,19]);record('stage-04-lower-clamp');stop();assert has('9 STOP')
  elif stage==5:wait('Miss.');record('stage-05-miss')
  else:
   wait('S to serve');record('stage-06-ready');serve();wait('Miss.');record('stage-06-miss')
   key('r',True);tick(40);assert has('Miss.');key('r',False);wait('S to serve');record('stage-06-retry');stop();assert has('Finished.')
 # Deterministic ROM edits isolate collision boundaries without memory injection.
 for name,y,paddle,dy,expected in [('centre',9,9,1,1),('top-edge',8,9,1,1),('bottom-edge',10,9,1,1),('above',7,9,1,0),('below',11,9,1,0),('corner',3,3,-1,1)]:
  edit([f'20 LET x=3: LET y={y}: LET dx=-1: LET dy={dy}',f'25 LET p={paddle}: LET score=0: LET missed=0','260 STOP'])
  run();serve();tick(50)
  if expected:assert has('9 STOP') and has('Returns: 1') and not has('Miss.'),(name,m.screen())
  else:wait('Miss.');stop()
  record('boundary-'+name)
 # Restore pristine source before export.
 edit([previous[20],previous[25],'260'])
 m.statement('SAVE "volley"');m.enter();tick(12000);assert has('0 OK')
 tape=a.output/'volley.tap';m.call('save_tape',path=str(tape));record('saved')
 m.close();m=Spectrum(a.emulator,a.output)
 m.call('load_media',slot='tape-1',kind='tape',path=str(tape));m.statement('LOAD "volley"');m.call('media_transport',slot='tape-1',transport='start');tick(12000);assert has('0 OK')
 run();wait('S to serve');serve();wait('Miss.');key('r',True);tick(10);key('r',False);wait('S to serve');stop();assert has('Finished.');record('fresh-load-play-retry-quit')
 (a.output/'results.json').write_text(json.dumps({'status':'passed','start_stage':a.start_stage,'server':m.server,'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/'steps').glob('*.bas') if a.start_stage==1 or p.name=='step-06.bas'},'checks':checks,'limits':'ROM entry and MCP input; no native keyboard, original hardware or independent human playtesting. Silent prototype.'},indent=2)+'\n')
finally:m.close()
