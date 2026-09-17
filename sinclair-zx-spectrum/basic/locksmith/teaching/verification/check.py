#!/usr/bin/env python3
"""Fresh tape trials for every teaching program, using keys and read-only state."""
import argparse,concurrent.futures,hashlib,itertools,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'));from entry import Spectrum
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'));from verify import state,line

def score(code,guess):
 exact=0;a=[];b=[]
 for x,y in zip(code,guess):
  if x==y:exact+=1
  else:a.append(x);b.append(y)
 other=0
 for digit in b:
  if digit in a:a.remove(digit);other+=1
 return exact,other
CASES=['1111','2222','2211','1212','1234','1112','3456','2111','1222','1122']
class Review:
 def __init__(self,item,exe,output):
  self.item=item;self.name=item['name'];self.out=output/self.name;self.m=Spectrum(exe,self.out);self.checks=[];self.trials=[]
 def record(self,name):self.checks.append(name);print('PASS',self.name,name,flush=True)
 def wait(self,text):
  for _ in range(1800):
   if any(text in row for row in self.m.screen()):self.m.frames(10);return
   self.m.frames(10)
  raise AssertionError((self.name,text,line(self.m),self.m.screen()))
 def ready(self,result=False):
  for _ in range(600):
   n=line(self.m)
   if (5250<=n<=5280 if result else n==250):return
   self.m.frames(2)
  raise AssertionError((self.name,'not ready',line(self.m),self.m.screen()))
 def key(self,k):self.m.key(k);self.m.frames(40)
 def capture(self,name):self.m.frames(10);self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def submit(self,g,result=False):
  before=state(self.m);assert before['g$']=='';code=list(map(int,before['c']));t=int(before['t'])
  for d in g:self.key(d)
  self.key('enter');self.ready(result)
  after=state(self.m);expected=score(code,list(map(int,g)));assert after['bulls']==expected[0],(self.name,g,after)
  if self.name!='exact':assert after['cows']==expected[1],(self.name,g,after)
  row=self.m.screen()[4+t];assert ''.join(row[7:14:2])==g,row;assert row[21]==str(expected[0]),row
  if self.name!='exact':assert row[28]==str(expected[1]),row
  self.trials.append(dict(code=code,guess=g,exact=expected[0],other=expected[1] if self.name!='exact' else None))
  return after
 def editor_checks(self):
  self.key('enter');self.ready();s=state(self.m);assert s['t']==1 and s['g$']=='';self.record('empty-enter-keeps-attempt')
  for k in ['0','7','a','space']:self.key(k)
  assert state(self.m)['g$']=='';self.record('non-digits-and-out-of-range-ignored')
  self.key('1');self.key('2');self.key('enter');self.ready();assert state(self.m)['g$']=='12' and state(self.m)['t']==1;self.record('short-guess-retained')
  self.key('d');self.m.key('caps','0');self.m.frames(40);self.key('d');assert state(self.m)['g$']=='';self.record('D-ROM-delete-and-empty-delete')
  self.m.call('press_key',key='3',hold_frames=100);self.m.frames(40);assert state(self.m)['g$']=='3';self.key('d');self.record('held-digit-enters-once')
  for d in '123456':self.key(d)
  assert state(self.m)['g$']=='1234';self.record('four-digit-boundary')
  for _ in range(4):self.key('d')
 def run(self):
  (self.out/'results.json').unlink(missing_ok=True)
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'locksmith.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start')
  if self.name=='board':self.wait('9 STOP')
  elif self.name=='finished':self.wait('S starts.');self.capture('title');self.key('s');self.ready()
  else:self.wait('ENTER: check');self.ready()
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()};self.record('fresh-ROM-load-stored-line-identity');self.capture('opening')
  if self.name=='board':
   rows=self.m.screen();assert 'Four spaces' in rows[20] and '_ _ _ _' in rows[17];self.record('static-board-four-empty-cells');return self.save()
  self.editor_checks()
  if self.name=='editor':
   for d in '1122':self.key(d)
   self.key('enter');self.ready();assert state(self.m)['g$']=='1122' and state(self.m)['t']==1;self.wait('Four digits ready');self.record('complete-editable-guess-without-scoring');self.capture('complete')
  elif self.name in ('exact','clues'):
   for g in CASES:
    s=self.submit(g);assert s['t']==1 and s['g$']==g
    for _ in range(4):self.key('d')
   self.record('ten-known-code-score-cases');self.record('practice-replaces-single-row-without-ending');self.capture('scored')
  elif self.name=='history':
   for idx,g in enumerate(CASES):
    # A correct early guess must not end the practice program.
    if idx==3:g='1122'
    s=self.submit(g,result=idx==9)
    if idx<9:assert s['t']==idx+2 and s['g$']==''
    if idx==2:self.capture('deduction')
   self.wait('Ten practice guesses');self.ready(True);assert state(self.m)['t']==10;self.capture('complete');self.record('ten-history-rows-and-practice-ending');self.record('correct-practice-guess-does-not-end-early')
   rows=self.m.screen()
   for idx,trial in enumerate(self.trials):assert ''.join(rows[5+idx][7:14:2])==trial['guess']
   self.record('all-earlier-guesses-retained')
   possible=list(itertools.product(range(1,7),repeat=4));trace=[]
   for trial in self.trials[:3]:
    possible=[c for c in possible if score(c,list(map(int,trial['guess'])))==(trial['exact'],trial['other'])];trace.append(dict(guess=trial['guess'],exact=trial['exact'],other=trial['other'],candidates=len(possible)))
   assert possible==[(1,1,2,2)]
   (self.out/'deduction.json').write_text(json.dumps({'source':'Actual keyboard-driven history trial; visible practice code 1122','trace':trace,'remaining':possible},indent=2)+'\n');self.record('deduction-trace-narrows-to-practice-code')
  else:
   code=''.join(str(int(x)) for x in state(self.m)['c']);self.submit(code,True);self.wait('OPEN!');self.ready(True);self.capture('open');self.record('random-code-exact-win')
   self.key('r');self.ready();s=state(self.m);assert s['t']==1 and s['g$']=='';self.record('result-replay-resets-board')
   code=list(map(int,s['c']));assert all(1<=d<=6 for d in code)
   for idx,g in enumerate(CASES):
    if list(map(int,g))==code:g=''.join(str(x%6+1) for x in code)
    self.submit(g,idx==9)
   self.wait('LOCKED.');self.ready(True);self.capture('locked');self.record('ten-guesses-loss-and-independent-score-model')
   # Result ignores ordinary editing controls.
   for k in ['1','d','enter']:self.key(k)
   self.ready(True);assert state(self.m)['t']==10;self.record('result-freezes-guess-history')
  if self.name in ('history','round','finished'):
   self.key('q');self.wait('9 STOP');self.record('quit-from-result');self.m.statement('RUN')
   if self.name=='finished':self.wait('S starts.');self.key('q');self.wait('9 STOP');self.record('quit-from-title');self.m.statement('RUN');self.wait('S starts.');self.key('s')
   self.ready()
  self.key('r');self.ready();s=state(self.m);assert s['t']==1 and s['g$']=='';self.record('active-reset')
  if self.name in ('exact','clues','history'):assert s['c']==[1,1,2,2];self.record('practice-code-preserved-on-reset')
  self.key('q');self.wait('9 STOP');self.record('quit-from-play');return self.save()
 def save(self):
  result=dict(name=self.name,source_sha256=hashlib.sha256((ROOT/self.item['source']).read_bytes()).hexdigest(),checks=self.checks,trials=self.trials,state_writes=False)
  (self.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');return result

def run(item,exe,out):
 r=Review(item,exe,out)
 try:return r.run()
 finally:r.m.close()
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');p.add_argument('--jobs',type=int,default=1);a=p.parse_args();items=json.loads((ROOT/'checkpoints.json').read_text());items=[i for i in items if not a.only or i['name']==a.only]
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:results=list(pool.map(lambda i:run(i,a.emulator,a.output.resolve()),items))
 print('PASS',sum(len(r['checks']) for r in results),'checkpoint checks')
