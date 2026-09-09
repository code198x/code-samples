"""Exercise the new practice-pad, fuel and terrain experiments through ROM edits."""
import argparse,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from state import variables
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True);m=Spectrum(a.emulator,a.output);checks=[]
def source(u,s='step-01'):return {int(l.split()[0]):l for l in (ROOT/f'unit-{u:02}/steps/{s}.bas').read_text().splitlines()}
previous=source(11,'step-02')
def key(k,d):m.call('input',events=[{'Key':{'name':k,'pressed':d}}])
def has(s):return any(s in row for row in m.screen())
def wait(s):
 for _ in range(2000):
  if has(s):return
  m.frames(5)
 raise AssertionError((s,m.screen()))
def change(u,s='step-01'):
 global previous
 current=source(u,s)
 for n in sorted(previous.keys()-current.keys()):m.statement(str(n))
 for n,l in sorted(current.items()):
  if previous.get(n)!=l:m.statement(l)
 previous=current
 return current
def launch():
 m.statement('RUN');wait('S launches');key('s',True);m.frames(5);key('s',False);wait('FUEL')
def quit():
 m.frames(100);key('q',True);m.frames(50);key('q',False);wait('9 STOP');m.frames(100)
def record(name):checks.append(name);print('PASS',name,flush=True);(a.output/'case-results.json').write_text(json.dumps(checks,indent=2)+'\n')
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape));m.statement('LOAD "touchdown"');m.call('media_transport',slot='tape-1',transport='start');m.frames(7000);wait('0 OK')
 launch();wait('Terrain collision.');quit();record('fresh-final-teaching-tape-launch-contact-quit')
 current=change(5)
 for fuel,y,expected in [(0,1899,'Safe landing!'),(1,400,'Too fast!')]:
  m.statement(f'130 LET x=24: LET y={y}: LET v=0: LET fuel={fuel}: LET r=INT (y/100): LET burn=0');launch();key('space',True);m.frames(150)
  v=variables(m);assert v['fuel']==0 and v['burn']==0,v
  if y==400:assert v['y']<1900,v
  key('space',False);wait(expected);quit();record(f'fuel-{fuel}-'+expected)
 m.statement(current[130]);current=change(6)
 for x,expected in [(19,'Off the pad.'),(20,'Safe landing!'),(27,'Safe landing!'),(28,'Off the pad.')]:
  m.statement(f'130 LET x={x}: LET y=1899: LET v=0: LET fuel=45: LET r=18: LET burn=0');launch();wait(expected);quit();record(f'practice-pad-column-{x}')
 m.statement(current[130]);current=change(8);m.statement('35 LET h(19)=18');launch();wait('Off the pad.');v=variables(m);assert v['y']==1700 and v['r']==17,v;assert m.screen()[18][18]=='#',m.screen();quit();m.statement('35');record('raised-array-column-drawing-and-contact')
 current=change(9,'step-02');m.statement('130 LET x=18: LET y=1750: LET v=-4: LET fuel=45: LET r=17: LET burn=0');launch();key('p',True);key('space',True);wait('Terrain collision.');key('p',False);key('space',False);v=variables(m);assert v['side']==1 and v['x']==18 and 1700<v['y']<=1750,v;quit();record('single-obstacle-ascending-side-contact')
 m.statement(current[130]);change(11,'step-02');launch();key('q',True);m.frames(80);assert not has('Finished.');key('q',False);wait('9 STOP');record('held-flight-Q-release')
finally:m.close()
