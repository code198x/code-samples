#!/usr/bin/env python3
"""Verify the completion checkpoints through ROM key entry on Spectrum 48K.

Uses the opening's MCP transport. No BASIC injection or memory writes. Test-only
line replacements (fixed secrets/answers and seeds) are explicit below.
"""
import argparse,hashlib,importlib.util,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('opening',ROOT/'opening/verification/verify.py')
opening=importlib.util.module_from_spec(spec);spec.loader.exec_module(opening)
class Spectrum(opening.Spectrum):
 def text(self,text):
  symbols={'<':'r','>':'t','+':'k','-':'j','.':'m','!':'1',':':'z','*':'b','/':'v','(':'8',')':'9','?':'c'}
  for c in text:
   if c in symbols:self.key('symbol',symbols[c])
   else:super().text(c)
 def statement(self,line):
  normal={'PRINT':'p','LET':'l','RUN':'r','LIST':'k','SAVE':'s','LOAD':'j','INPUT':'i','CLS':'v','IF':'u','GO TO':'g','GO SUB':'h','RETURN':'y','RANDOMIZE':'t','BORDER':'b','FOR':'f','NEXT':'n','PAUSE':'m'}
  symbol={'THEN':'g','<>':'w','STOP':'a','AT':'i','TO':'f'}
  extended={'INT':'r','RND':'t','INKEY$':'n'}
  shifted={'PAPER':'c','INK':'x','BEEP':'z'}
  tokens=sorted([*normal,*symbol,*extended,*shifted],key=len,reverse=True)
  pattern=r'("[^"]*"|'+ '|'.join(re.escape(t) for t in tokens)+')'
  for part in re.split(pattern,line):
   if part in normal:self.key(normal[part])
   elif part in symbol:self.key('symbol',symbol[part])
   elif part in extended:self.key('caps','symbol');self.key(extended[part])
   elif part in shifted:self.key('caps','symbol');self.key('symbol',shifted[part])
   else:self.text(part)
  self.enter()
 def rows(self):return [s.rstrip() for s in self.screen()]
 def guess(self,value):self.text(str(value));self.enter()
 def marker(self,name,cols):
  rows=self.screen();actual=[i for i,c in enumerate(rows[10]) if c=='O']
  assert actual==cols,(name,actual,cols,rows)
  self.check(name,[],capture=True)
 def break_run(self):self.key('caps','space');self.frames(30)
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--emulator',required=True);p.add_argument('--output',required=True,type=Path);p.add_argument('--arc',choices=['lucky-number','oracle','movement']);p.add_argument('--unit',type=int);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
 sources=[s for arc in ['lucky-number','oracle','movement'] if not a.arc or arc==a.arc for s in sorted((ROOT/arc).glob('unit-*/steps/*.bas')) if int(s.parent.parent.name[-2:])>=7 and (not a.unit or int(s.parent.parent.name[-2:])==a.unit)]
 evidence=[]
 for source in sources:
  label=source.parent.parent.name+'-'+source.stem;u=int(source.parent.parent.name[-2:]);step=int(source.stem[-2:]);m=Spectrum(a.emulator,a.output)
  try:
   for line in source.read_text().splitlines():m.statement(line)
   if u<=8:
    # Exercise actual random selection, using exhaustive guesses rather than peeking.
    m.statement('RUN')
    for guess in range(1,11):
     m.guess(guess)
     if 'Correct!' in m.rows():break
    else:raise AssertionError('No secret in promised range')
    m.check(label+'-random-play',['Correct!',f'Guesses: {guess}'])
    if u==8 and step==3:
     # Invalid replay input must not leave the game or scroll the count away.
     for _ in range(24):m.text('x');m.enter()
     m.check(label+'-invalid-replay',['Correct!',f'Guesses: {guess}','Again?'])
     m.text('y');m.enter()
     m.check(label+'-new-round',['Guess a whole number 1 to 10'])
     for guess in range(1,11):
      m.guess(guess)
      if 'Correct!' in m.rows():break
     m.check(label+'-reset-count',['Correct!',f'Guesses: {guess}'])
     m.text('n');m.enter();m.check(label+'-exit',['9 STOP'])
    else:m.break_run()
    # Labelled fixed-secret replacements verify both endpoints and validation.
    for secret in [1,10]:
     m.statement(f'10 LET secret={secret}');m.statement('RUN')
     for g in ['0','11','1.5']:m.guess(g);m.check(label+f'-invalid-{secret}-{g}',['Whole number from 1 to 10'])
     m.guess(secret);m.check(label+f'-endpoint-{secret}',['Correct!','Guesses: 1'])
     if u==8 and step==3:m.text('n');m.enter()
    if u==8 and step>=2:
     m.statement('10 LET secret=7');m.statement('RUN')
     m.call('start_audio_recording',path=str(a.output/(label+'-feedback.wav')))
     for g in [4,9,7]:m.guess(g)
     m.call('stop_audio_recording');m.check(label+'-feedback',['Correct!','Guesses: 3'])
     if step==3:m.text('n');m.enter()
   elif u<=11:
    m.statement('RUN');m.text('Shall we explore');m.enter();m.frames(100)
    m.check(label+'-random',['THE STONE SAYS'])
    replies=['Try a small experiment.','Ask someone to join you.','Take a different route.']
    assert sum(r in m.rows() for r in replies)==1
    for choice in [1,2,3]:
     m.statement(f'70 LET answer={choice}');m.statement('RUN');m.text('A different question');m.enter();m.frames(100)
     m.check(label+f'-answer-{choice}',[replies[choice-1]])
     if u>=10:assert m.rows()[0]=='...',m.rows()
     if u==11 and step==2:assert m.rows()[1:3]==['ORACLE STONE','------------'],m.rows()
    if u==10 and step==3:
     m.statement('RUN');m.call('start_audio_recording',path=str(a.output/(label+'-cue.wav')));m.text('Ready');m.enter();m.frames(100);m.call('stop_audio_recording')
   elif u==12:
    m.statement('RUN');m.marker(label,[5])
    if step==2:
     m.statement('56 LET col=30');m.statement('RUN');m.marker(label+'-column',[30])
     m.statement('55 LET row=2');m.statement('RUN');assert m.screen()[2][30]=='O';m.check(label+'-row',[],capture=True)
   elif u==13:
    m.statement('RUN');m.frames(300)
    m.marker(label,list(range(1,31)) if step==1 else [] if step==2 else [30])
   else:
    m.statement('RUN');m.marker(label+'-start',[15])
    m.call('press_key',key='p',hold_frames=90);m.frames(10)
    m.marker(label+'-held',[30] if u==14 else [16])
    m.call('press_key',key='p',hold_frames=30);m.frames(10)
    m.marker(label+'-second-press',[30] if u==14 else [17])
    m.call('press_key',key='x',hold_frames=30);m.frames(10)
    m.marker(label+'-irrelevant',[30] if u==14 else [17])
    for _ in range(35):m.call('press_key',key='o',hold_frames=10);m.frames(10)
    m.marker(label+'-left-edge',[1])
    for _ in range(35):m.call('press_key',key='p',hold_frames=10);m.frames(10)
    m.marker(label+'-right-edge',[30])
    if u==15:
     m.key('q');m.check(label+'-quit',['9 STOP']+(['Finished. RUN to try again.'] if step==2 else []))
    else:m.break_run();m.check(label+'-break',['BREAK'])
   # Save the unmodified learner listing, then load it in a fresh process.
   if (u,step) in [(8,3),(11,2),(15,2)]:
    for line in source.read_text().splitlines():m.statement(line)
    name={8:'lucky',11:'oracle',15:'marker'}[u]
    m.statement(f'SAVE "{name}"');m.enter();m.frames(2200);m.check(label+'-save',['0 OK'],capture=False)
    tape=a.output/(name+'.tap');m.call('save_tape',path=str(tape));evidence+=m.evidence;m.close();m=Spectrum(a.emulator,a.output)
    m.call('load_media',slot='tape-1',kind='tape',path=str(tape));m.statement(f'LOAD "{name}"');m.call('media_transport',slot='tape-1',transport='start');m.frames(2300);m.check(label+'-load',['0 OK'],capture=False)
    m.statement('RUN')
    if u==8:
     for guess in range(1,11):
      m.guess(guess)
      if 'Correct!' in m.rows():break
     m.check(label+'-loaded-play',['Correct!','Again?'])
    elif u==11:m.text('A saved question');m.enter();m.frames(100);m.check(label+'-loaded-play',['THE STONE SAYS'])
    else:m.key('p');m.marker(label+'-loaded-play',[16]);m.key('q')
   evidence+=m.evidence
   (a.output/'progress.json').write_text(json.dumps(evidence,indent=2)+'\n')
  finally:m.close()
 result={'status':'passed','configuration':'Released Spectrum 48K; ROM key entry via MCP; explicit fixed-secret/answer test edits; fresh-process named tape loads','limits':'No native host events, original hardware or other platforms tested. Audio files captured for separate listening review.','binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'source_sha256':{str(s.relative_to(ROOT)):hashlib.sha256(s.read_bytes()).hexdigest() for s in sources},'checks':evidence}
 (a.output/'results.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
