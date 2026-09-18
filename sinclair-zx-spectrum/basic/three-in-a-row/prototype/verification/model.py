"""Enumerate legal play under both starters. Host model, not BASIC execution."""
from pathlib import Path
from collections import Counter
import json, hashlib
ROOT=Path(__file__).resolve().parents[1]
LINES=((1,2,3),(4,5,6),(7,8,9),(1,4,7),(2,5,8),(3,6,9),(1,5,9),(3,5,7))
def result(b):
 win=0;wl=0
 for i,t in enumerate(LINES,1):
  if b[t[0]-1] and len({b[n-1] for n in t})==1:win=b[t[0]-1];wl=i
 return win,wl

def choose(b):
 for mark,reason in [(2,'win'),(1,'block')]:
  for t in LINES:
   values=[b[n-1] for n in t]
   if values.count(mark)==2 and values.count(0)==1:return t[values.index(0)],reason
 for n in (5,1,3,7,9):
  if not b[n-1]:return n,'centre' if n==5 else 'corner'
 return max(n for n in range(1,10) if not b[n-1]),'edge'

def immediate(b,mark):
 out=[]
 for n in range(1,10):
  if b[n-1]==0:
   copy=b.copy();copy[n-1]=mark
   if result(copy)[0]==mark:out.append(n)
 return out

def enumerate_games(first):
 endings=Counter();positions=set();examples={};priority=Counter()
 def walk(b,turn,trace):
  win,wl=result(b)
  if win or all(b):
   kind='X' if win==1 else 'O' if win==2 else 'draw';endings[kind]+=1
   for key in [kind,kind+'-line-'+str(wl),'last-cell-win' if win and all(b) else kind]:
    if key not in examples or len(trace)<len(examples[key]):examples[key]=trace
   return
  if turn==1:options=[(n,'player') for n in range(1,10) if not b[n-1]]
  else:
   n,why=choose(b);assert not b[n-1]
   wins=immediate(b,2);threats=immediate(b,1)
   assert not wins or n in wins
   assert wins or not threats or n in threats
   if tuple(b) not in positions:positions.add(tuple(b));priority[why]+=1
   options=[(n,why)]
   if wins and threats:examples.setdefault('win-before-block',trace+[{'mark':2,'cell':n,'reason':why}])
   examples.setdefault('reason-'+why,trace+[{'mark':2,'cell':n,'reason':why}])
  for n,why in options:
   nxt=b.copy();nxt[n-1]=turn;walk(nxt,3-turn,trace+[dict(mark=turn,cell=n,reason=why)])
 walk([0]*9,first,[])
 return dict(starter=first,terminal_sequences=dict(endings),computer_positions=len(positions),priority_counts=dict(priority),examples=examples)
if __name__=='__main__':
 data={'source_sha256':hashlib.sha256((ROOT/'three.bas').read_bytes()).hexdigest(),'method':'All legal human replies; independent line-count policy; no execution or human win-rate claim.','starters':[enumerate_games(1),enumerate_games(2)]}
 (ROOT/'verification/evidence/model.json').write_text(json.dumps(data,indent=2)+'\n')
 for item in data['starters']:print(item['starter'],item['terminal_sequences'],item['computer_positions'])
