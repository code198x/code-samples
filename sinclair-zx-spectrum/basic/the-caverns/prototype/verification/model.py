"""Source-pinned graph audit and host exploration; not Spectrum execution."""
from pathlib import Path
from collections import deque
import csv,hashlib,json
ROOT=Path(__file__).resolve().parents[1]
source=(ROOT/'caverns.bas').read_text();rooms={}
for line in source.splitlines():
 n=int(line.split()[0])
 if 9500<=n<=9610:
  row=next(csv.reader([line.split('DATA ',1)[1]],skipinitialspace=True));rooms[(n-9500)//10+1]=dict(name=row[0],description=row[1],exits=list(map(int,row[2:])))
PATROL=tuple(map(int,next(line for line in source.splitlines() if line.startswith('9800 DATA ')).split('DATA ',1)[1].split(',')))
TREASURES=(6,10,12);START=(1,2,7);KEYS='nsew '
assert '240 LET t(6) = 1: LET t(10) = 1: LET t(12) = 1' in source
assert '250 LET rm = 1: LET pit = 7: LET ci = 3: LET cr = c(ci): LET found = 0: LET turns = 0' in source
def step(s,key):
 rm,ci,mask=s;cr=PATROL[ci];dest=rm if key==' ' else rooms[rm]['exits'][KEYS.index(key)]
 if not dest:return s,'wall'
 if dest==7:return (dest,ci,mask),'pit'
 if dest==cr:return (dest,ci,mask),'caught'
 if dest in TREASURES:mask &= ~(1<<TREASURES.index(dest))
 if dest==1 and mask==0:return (dest,ci,mask),'win'
 ci=(ci+1)%8
 return (dest,ci,mask),('arrival' if dest==PATROL[ci] else 'move')
def explore():
 for room,data in rooms.items():
  for j,dest in enumerate(data['exits']):
   if dest:assert rooms[dest]['exits'][j^1]==room
 for a,b in zip(PATROL,PATROL[1:]+PATROL[:1]):assert b in rooms[a]['exits'] and b!=7
 assert 7 not in rooms[1]['exits'] and PATROL[START[1]] not in rooms[1]['exits']
 q=deque([(START,'')]);seen={START};examples={};arrivals=0
 while q:
  s,path=q.popleft()
  if s[0]==PATROL[s[1]]:
   arrivals+=1
   escape=[k for k in KEYS[:4] if step(s,k)[1] in ('move','arrival','win')]
   assert escape,(s,path)
   examples.setdefault('escape',path+escape[0])
  for key in KEYS:
   nxt,event=step(s,key);trace=path+key
   if event in ('pit','caught','win','arrival'):examples.setdefault(event,trace)
   if event not in ('pit','caught','win','wall') and nxt not in seen:seen.add(nxt);q.append((nxt,trace))
 assert all(k in examples for k in ('win','pit','caught','arrival','escape'))
 return {'source_sha256':hashlib.sha256((ROOT/'caverns.bas').read_bytes()).hexdigest(),'reachable_nonterminal_states':len(seen),'arrival_states_with_safe_escape':arrivals,'examples':examples,'limits':'Host state-space exploration, not ROM execution or proof of player enjoyment.'}
if __name__=='__main__':
 out=ROOT/'verification/evidence';out.mkdir(exist_ok=True);report=explore();(out/'model.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
