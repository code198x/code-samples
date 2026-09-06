#!/usr/bin/env python3
"""ROM-key-entry checks for Bright Spark's board-and-cue prototype."""
import argparse,hashlib,importlib.util,json,re
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('opening',ROOT.parents[1]/'meet-basic/opening/verification/verify.py')
opening=importlib.util.module_from_spec(spec);spec.loader.exec_module(opening)
class Spectrum(opening.Spectrum):
 def text(self,text):
  symbols={'<':'r','>':'t','+':'k','-':'j','.':'m',':':'z','*':'b','(':'8',')':'9'}
  for c in text:
   if c in symbols:self.key('symbol',symbols[c])
   else:super().text(c)
 def statement(self,line):
  normal={'PRINT':'p','LET':'l','RUN':'r','SAVE':'s','LOAD':'j','INPUT':'i','CLS':'v','IF':'u','GO TO':'g','GO SUB':'h','RETURN':'y','BORDER':'b','FOR':'f','NEXT':'n','PAUSE':'m'}
  symbol={'THEN':'g','<>':'w','STOP':'a','AT':'i','TO':'f'}
  extended={'INKEY$':'n'};shifted={'PAPER':'c','INK':'x','BEEP':'z','BRIGHT':'b'}
  tokens=sorted([*normal,*symbol,*extended,*shifted],key=len,reverse=True)
  for part in re.split(r'("[^"]*"|'+ '|'.join(re.escape(t) for t in tokens)+')',line):
   if part in normal:self.key(normal[part])
   elif part in symbol:self.key('symbol',symbol[part])
   elif part in extended:self.key('caps','symbol');self.key(extended[part])
   elif part in shifted:self.key('caps','symbol');self.key('symbol',shifted[part])
   else:self.text(part)
  self.enter()
 def labels(self,count=4):
  rows=self.screen()
  for digit,row,col in [('1',2,7),('2',2,23),('3',11,7),('4',11,23)][:count]:assert rows[row][col]==digit,(digit,rows)
 def stars(self):return [(r,c) for r,line in enumerate(self.screen()) for c,x in enumerate(line) if x=='*']
 def cue(self,key,hold=2):
  self.call('press_key',key=key,hold_frames=hold)
  states=[]
  for frame in range(65):
   self.frames(1);self.labels();stars=self.stars();states.append(stars)
   if stars and len(states)>1 and states[-2] and not any(states[:-2]):self.call('save_screenshot',path=str(self.output/f'panel-{key}-active.png'))
  expected={'1':(5,7),'2':(5,23),'3':(14,7),'4':(14,23)}[key]
  assert any(expected in s for s in states),(key,states)
  assert all(not s or s==[expected] for s in states),(key,states)
  assert not states[-1],(key,states[-1])
  self.check('cue-'+key+'-labels-and-rest',[],capture=False)
  self.evidence[-1]['active_frames']=[i for i,s in enumerate(states) if s]
 def close(self):super().close()
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--emulator',required=True);p.add_argument('--output',required=True,type=Path);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True);evidence=[]
 sources=sorted((ROOT/'steps').glob('*.bas'))
 for i,path in enumerate(sources,1):
  m=Spectrum(a.emulator,a.output)
  try:
   for line in path.read_text().splitlines():m.statement(line)
   m.statement('RUN');m.frames(180);m.labels(1 if i==1 else 4);m.check(f'step-{i}-board',['BRIGHT SPARK'])
   if i==3:
    m.call('start_audio_recording',path=str(a.output/'four-cues.wav'))
    for key in '1234':m.cue(key)
    m.call('stop_audio_recording')
    m.cue('2');m.cue('2');m.check('consecutive-identical-cues',[],capture=True)
    # One held key must not retrigger after its initial cue.
    m.call('press_key',key='1',hold_frames=120);m.frames(5);assert not m.stars();m.labels();m.check('held-key-released-at-rest',[],capture=False)
    m.call('press_key',key='x',hold_frames=30);m.frames(30);assert not m.stars();m.labels();m.check('irrelevant-key',[],capture=False)
    m.key('q');m.check('quit',['Finished. RUN to try again.','9 STOP'])
    # PAUSE experiment, deliberately separate from game input. These direct
    # commands establish key interruption; they do not claim game-loop timing.
    m.statement('1000 PAUSE 10');m.statement('1010 PRINT "WAIT COMPLETE"');m.statement('1020 STOP')
    for key in [None,'x']:
     m.statement('CLS');m.key('r');m.text('1000');m.call('press_key',key='enter',hold_frames=1)
     if key:m.call('press_key',key=key,hold_frames=2)
     frames=0
     while not any('WAIT COMPLETE' in row for row in m.screen()):
      m.frames(1);frames+=1;assert frames<25
     m.check('pause-'+('no-key' if key is None else 'key'),['WAIT COMPLETE'],capture=False);m.evidence[-1]['frames_after_initial_key_calls']=frames
    # Delete labelled test lines before saving the ordinary prototype.
    for n in [1000,1010,1020]:m.text(str(n));m.enter()
    m.statement('SAVE "spark"');m.enter();m.frames(2600);m.check('save',['0 OK'],capture=False)
    tape=a.output/'spark.tap';m.call('save_tape',path=str(tape));evidence+=m.evidence;m.close();m=Spectrum(a.emulator,a.output)
    m.call('load_media',slot='tape-1',kind='tape',path=str(tape));m.statement('LOAD "spark"');m.call('media_transport',slot='tape-1',transport='start');m.frames(2800);m.check('load',['0 OK'],capture=False);m.statement('RUN');m.frames(180);m.labels();m.cue('4');m.key('q');m.check('loaded-quit',['9 STOP'])
   evidence+=m.evidence
   (a.output/'progress.json').write_text(json.dumps(evidence,indent=2)+'\n')
  finally:m.close()
 (a.output/'results.json').write_text(json.dumps({'status':'passed','server':m.server,'configuration':'Spectrum 48K via ROM key entry, released Apple silicon Emu198x; fresh-process named tape load','limits':'No original hardware, native host events or subjective audio listening. PAUSE remains interruptible; playback scheduling not yet implemented.','binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'sources':{p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in sources},'checks':evidence},indent=2)+'\n')
if __name__=='__main__':main()
