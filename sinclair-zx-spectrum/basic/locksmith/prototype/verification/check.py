#!/usr/bin/env python3
"""Fresh-ROM keyboard trials; inspect state without changing secrets or results."""
import argparse,json,sys,hashlib
from pathlib import Path
from collections import Counter
from entry import Spectrum,ROOT
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line

def score(code,guess):
 unmatched_code=[];unmatched_guess=[];exact=0
 for a,b in zip(code,guess):
  if a==b:exact+=1
  else:unmatched_code.append(a);unmatched_guess.append(b)
 other=0
 for digit in unmatched_guess:
  if digit in unmatched_code:unmatched_code.remove(digit);other+=1
 return exact,other
class Review:
 def __init__(self,exe,out):self.m=Spectrum(exe,out);self.out=out;self.checks=[];self.trials=[]
 def wait(self,text):
  for _ in range(1500):
   if any(text in s for s in self.m.screen()):
    if text in ('OPEN!','LOCKED.') and not 5250<=line(self.m)<=5280:self.m.frames(10);continue
    self.m.frames(6);return
   self.m.frames(10)
  raise AssertionError((text,self.m.screen()))
 def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
 def key(self,key):self.m.key(key);self.m.frames(40)
 def capture(self,name):self.m.frames(10);self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def load(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'locksmith.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('S starts.')
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()};self.record('fresh-ROM-load-and-stored-source-identity');self.capture('title')
 def guess(self,g):
  before=state(self.m);code=list(map(int,before['c']));t=int(before['t'])
  for d in g:self.key(d)
  self.key('enter')
  for _ in range(200):
   self.m.frames(10);s=state(self.m)
   if s.get('t')==t+1 or any('OPEN!' in r or 'LOCKED.' in r for r in self.m.screen()):break
  else:raise AssertionError(self.m.screen())
  expected=score(code,list(map(int,g)));assert (s['bulls'],s['cows'])==expected,(code,g,s,expected)
  rows=self.m.screen();row=rows[4+t];assert ''.join(row[7:14:2])==g,row;assert row[21]==str(expected[0]) and row[28]==str(expected[1]),row
  self.trials.append({'code':code,'guess':g,'exact':expected[0],'other':expected[1]});return expected
 def execute(self):
  (self.out/'results.json').unlink(missing_ok=True)
  self.load();self.key('s');self.wait('ENTER: check');self.capture('board');s=state(self.m);assert s['g$']=='' and s['t']==1
  self.key('enter');self.wait('Enter four digits');assert state(self.m)['t']==1;self.record('empty-submit-does-not-spend-attempt')
  for k in ['0','7','a','space']:self.key(k)
  assert state(self.m)['g$']=='';self.record('invalid-characters-ignored')
  self.key('1');self.key('2');self.key('enter');assert state(self.m)['t']==1 and state(self.m)['g$']=='12';self.record('short-submit-preserves-edit')
  self.key('d');assert state(self.m)['g$']=='1';self.m.key('caps','0');self.m.frames(40);assert state(self.m)['g$']=='';self.key('d');assert state(self.m)['g$']=='';self.record('D-and-ROM-delete-and-empty-delete')
  self.m.call('press_key',key='3',hold_frames=100);self.m.frames(40);assert state(self.m)['g$']=='3';self.key('d');self.record('held-digit-enters-once')
  for d in '123456':self.key(d)
  assert state(self.m)['g$']=='1234';self.record('fifth-and-sixth-digits-ignored')
  for _ in range(4):self.key('d')
  code=''.join(str(int(x)) for x in state(self.m)['c']);self.guess(code);self.wait('OPEN!');assert 'digits' not in self.m.screen()[18];self.capture('open');self.record('four-exact-win-and-reveal')
  for k in ['1','enter','d']:self.key(k)
  assert any('OPEN!' in r for r in self.m.screen());self.record('result-waits-for-replay-or-quit')
  self.key('r');self.wait('ENTER: check');assert state(self.m)['t']==1 and state(self.m)['g$']=='';self.record('replay-resets-history-and-edit')
  for roundno in range(4):
   code=list(map(int,state(self.m)['c']))
   guesses=['1111','2222','3333','4444','5555','6666','1122','1212','1234','6543']
   for idx,g in enumerate(guesses):
    if list(map(int,g))==code:g=''.join(str(x%6+1) for x in code)
    self.guess(g)
    if roundno==0 and idx==4:self.capture('history')
   self.wait('LOCKED.');assert state(self.m)['t']==10;self.record('ten-guess-model-trial-'+str(roundno+1))
   if roundno==0:self.capture('locked')
   self.key('r');self.wait('ENTER: check')
  self.record('forty-submitted-scores-match-independent-occurrence-model')
  self.key('q');self.wait('9 STOP statement');self.record('quit-from-play')
  self.m.statement('RUN');self.wait('S starts.');self.key('q');self.wait('9 STOP statement');self.record('quit-from-title')
  self.m.statement('RUN');self.wait('S starts.');self.key('s');self.wait('ENTER: check');self.guess(''.join(str(int(x)) for x in state(self.m)['c']));self.wait('OPEN!');self.key('q');self.wait('9 STOP statement');self.record('quit-from-result')
  (self.out/'results.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/'locksmith.bas').read_bytes()).hexdigest(),'configuration':'Emu198x Spectrum 0.25.0, stock 48K PAL','checks':self.checks,'trials':self.trials,'state_writes':False},indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
 try:r.execute()
 finally:r.m.close()
