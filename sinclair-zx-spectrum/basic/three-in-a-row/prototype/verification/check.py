"""Fresh-ROM play with key input and read-only observation; separate ROM fixtures."""
import argparse,json,sys,hashlib
from pathlib import Path
from entry import Spectrum,ROOT
from model import choose,result,LINES
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
class Review:
 def __init__(self,exe,out):self.exe=exe;self.m=Spectrum(exe,out);self.out=out;self.checks=[];self.trials=[]
 def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
 def key(self,k):self.m.key(k);self.m.frames(12)
 def waitline(self,targets):
  for _ in range(2000):
   if line(self.m) in targets:return state(self.m)
   self.m.frames(5)
  raise AssertionError((targets,line(self.m),self.m.screen()))
 def stopped(self):
  for _ in range(200):
   if any('9 STOP statement' in row for row in self.m.screen()):return
   self.m.frames(5)
  raise AssertionError(self.m.screen())
 def ready(self):return self.waitline([260,5080])
 def capture(self,name):self.m.frames(10);self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def run(self):
  if line(self.m) in (260,5080):self.key('q');self.stopped()
  self.m.statement('RUN');self.waitline([110]);self.key('s');return self.ready()
 def move(self,n):
  before=self.ready();b=before['b'].copy();assert b[n-1]==0;b[n-1]=1
  expected_reason=None;expected_mv=None
  if not result(b)[0] and not all(b):
   expected_mv,expected_reason=choose(b);b[expected_mv-1]=2
  self.key(str(n));s=self.ready();assert s['b']==b,(n,b,s)
  assert s['moves']==sum(bool(v) for v in b)
  assert (s['winner'],s['wl'])==result(b)
  for counter,flag in [('wins',s['winner']==1),('losses',s['winner']==2),('draws',s['winner']==0 and all(b))]:
   assert s[counter]==before[counter]+int(flag),(counter,before,s)
  if expected_reason:
   assert s['a$']==expected_reason and s['mv']==expected_mv
   assert ('O chose '+str(expected_mv)+': '+expected_reason) in self.m.screen()[19],self.m.screen()
  self.trials.append({'player':n,'board':b,'computer':expected_mv,'reason':expected_reason,'winner':s['winner']})
  return s
 def execute(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'three.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.waitline([110])
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()}
  self.capture('title');self.record('fresh-ROM-tape-load-source-identity')
  self.key('a');self.waitline([110]);self.key('q');self.stopped();self.record('title-invalid-key-and-quit')
  self.run();self.capture('board')
  for k in ['0','a','enter','space']:self.key(k);assert self.ready()['moves']==0
  self.record('invalid-keys-preserve-empty-board')
  self.m.call('input',events=[{'Key':{'name':'1','pressed':True}}]);self.m.frames(400)
  s=state(self.m);assert s['moves']==2 and s['b']==[1,0,0,0,2,0,0,0,0],s
  self.m.call('input',events=[{'Key':{'name':'1','pressed':False}}]);self.m.frames(10);self.ready();self.record('held-key-across-computer-turn-places-once')
  self.key('1');assert self.ready()['moves']==2;assert 'Taken.' in self.m.screen()[18];self.record('occupied-cell-rejected')
  self.key('r');s=self.ready();assert s['moves']==0 and s['first']==1 and s['wins']==s['losses']==s['draws']==0;self.record('unfinished-reset-preserves-starter-and-score')
  for n in (1,8,7):self.move(n)
  self.capture('fork');s=self.move(4);assert s['winner']==1 and s['wins']==1;self.capture('win');self.record('retained-fork-wins-final-board-visible')
  for k in ['1','enter','s']:self.key(k);assert self.ready()['wins']==1 and self.ready()['moves']==7
  self.record('result-input-does-not-score-twice')
  self.key('r');s=self.ready();assert s['first']==2 and s['b']==[0,0,0,0,2,0,0,0,0] and s['wins']==1
  self.key('r');s=self.ready();assert s['first']==2 and s['moves']==1 and s['wins']==1;self.capture('computer-start');self.record('completed-replay-alternates-unfinished-restart-does-not')
  # Reach every available ending/line/reason fixture through actual legal play.
  model=json.loads((self.out/'model.json').read_text());seen=set()
  for group in model['starters']:
   for name,trace in group['examples'].items():
    seq=tuple(t['cell'] for t in trace if t['mark']==1);key=(group['starter'],seq)
    if key in seen:continue
    seen.add(key);self.run()
    if group['starter']==2:
     for n in (1,8,7,4):self.move(n)
     self.key('r');self.ready()
    for n in seq:self.move(n)
    s=self.ready()
    if name=='draw':assert s['winner']==0 and s['moves']==9;self.capture('draw')
    if name=='O':assert s['winner']==2;self.capture('loss')
    if name=='last-cell-win':assert s['winner']>0 and s['moves']==9;self.capture('last-cell-win')
    self.record('legal-model-path-'+str(group['starter'])+'-'+name)
  self.key('q');self.stopped();self.record('quit-after-play-or-result')
  self.run();self.key('q');self.stopped();self.record('quit-from-play')
  # Explicit diagnostic fixtures typed as ordinary BASIC commands after STOP.
  # These are not represented as playthroughs and do not produce public captures.
  for mark in (1,2):
   for expected,triple in enumerate(LINES,1):
    self.m.statement('DIM b(9)')
    for n in triple:self.m.statement('LET b('+str(n)+') = '+str(mark))
    self.m.statement('GO SUB 3000');s=state(self.m)
    assert s['winner']==mark and s['wl']==expected,(mark,triple,s)
  self.record('sixteen-ROM-command-line-diagnostic-winning-lines')
  self.m.statement('DIM b(9)')
  for n in range(1,10):self.m.statement('LET b('+str(n)+') = '+str(1 if n in (1,3,5,6,9) else 2))
  self.m.statement('LET moves = 9: LET wins = 0: LET draws = 0')
  self.m.statement('GO SUB 3000')
  self.m.statement('GO TO 5000');s=self.ready()
  assert s['winner']==1 and s['wins']==1 and s['draws']==0
  self.record('ROM-diagnostic-last-cell-win-precedes-draw')
  self.key('q');self.stopped();self.record('quit-from-result')
  data={'source_sha256':hashlib.sha256((ROOT/'three.bas').read_bytes()).hexdigest(),'configuration':'Stock 48K PAL','server':self.m.server,'binary_sha256':hashlib.sha256(Path(self.exe).read_bytes()).hexdigest(),'checks':self.checks,'trials':self.trials,'direct_memory_writes':False,'diagnostic_setup':'Sixteen separate winning-line fixtures and one full-board last-cell winning fixture use ROM-entered DIM and LET commands after STOP, then GO SUB 3000. No fixture captures are presented as play.','public_captures':'Fresh tape loading and ordinary legal key-driven rounds only.'}
  (self.out/'results.json').write_text(json.dumps(data,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
 try:r.execute()
 finally:r.m.close()
