#!/usr/bin/env python3
"""Additional stated experiments: fixed seeds, repeat counts, routines and motion."""
import argparse,json,hashlib
from pathlib import Path
from verify import Spectrum,ROOT
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
evidence=[]
def load(arc,u,step):
 m=Spectrum(a.emulator,a.output)
 for line in (ROOT/arc/f'unit-{u:02}/steps/step-{step:02}.bas').read_text().splitlines():m.statement(line)
 return m
m=load('lucky-number',7,2)
try:
 m.statement('5 RANDOMIZE 1')
 for i in range(2):m.statement('RUN');m.guess(1);m.check('seed-one-'+str(i),['Correct!','Guesses: 1'])
 # A deliberately bounded sample; this does not establish statistical fairness.
 vals=[]
 for i in range(12):
  m.statement('CLS');m.statement('PRINT INT (RND*10)+1');v=int(m.rows()[0]);assert 1<=v<=10;vals.append(v)
 m.check('twelve-generated-values-in-range',[],capture=False);m.evidence[-1]['values']=vals
 evidence+=m.evidence
finally:m.close()
m=load('oracle',11,2)
try:
 m.statement('510 PRINT "============"');m.statement('RUN');m.check('changed-routine-question',['ORACLE STONE','============'])
 m.text('Hello');m.enter();m.frames(100);m.check('changed-routine-answer',['ORACLE STONE','============','THE STONE SAYS'])
 m.statement('81 FOR i=1 TO 5');m.statement('RUN');m.text('Hello');m.enter();m.frames(130);assert m.rows()[0]=='.....';m.check('five-loop-visits',['.....'])
 evidence+=m.evidence
finally:m.close()
m=load('movement',12,2)
try:
 for row,col in [(0,0),(21,31)]:
  m.statement(f'55 LET row={row}');m.statement(f'56 LET col={col}');m.statement('RUN')
  assert m.screen()[row][col]=='O',(row,col,m.screen());m.check(f'corner-{row}-{col}',[],capture=True)
 evidence+=m.evidence
finally:m.close()
for step in [1,2,3]:
 m=load('movement',13,step)
 try:
  # Start without the transport helper's normal post-Enter wait, then sample motion.
  m.key('r');m.call('press_key',key='enter',hold_frames=1)
  positions=[]
  for tick in range(0,220,10):
   m.frames(10);row=m.screen()[10];positions.append([i for i,c in enumerate(row) if c=='O'])
   if tick in [10,50,100]:m.call('save_screenshot',path=str(a.output/f'motion-step-{step}-frame-{tick+10}.png'))
  visible={c for cols in positions for c in cols};assert len(visible)>3,positions
  if step>1:assert all(len(cols)<=1 for cols in positions),positions
  assert positions[-1]==(list(range(1,31)) if step==1 else [] if step==2 else [30]),positions
  m.check(f'motion-step-{step}',[],capture=False);m.evidence[-1]['sampled_columns_every_10_frames']=positions;evidence+=m.evidence
 finally:m.close()
(a.output/'experiments.json').write_text(json.dumps({'status':'passed','limits':'MCP frame observations; motion captures are samples, not native window playback. A finite random sample does not establish fairness.','binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'checks':evidence},indent=2)+'\n')
