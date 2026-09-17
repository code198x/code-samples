#!/usr/bin/env python3
"""Derive standalone teaching listings and exact editor changes from the accepted endpoint."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
def lines(s):return {int(l.split()[0]):l for l in s.splitlines() if l.strip()}
p=lines((ROOT.parent/'prototype/drift.bas').read_text())
def put(d,s):d.update(lines(s))
def drop(d,*numbers):
 for n in numbers:d.pop(n,None)
def base(hud=False,dock=False):
 d=p.copy()
 for n in list(d):
  if 5000<=n<6000 or not hud and 6000<=n<7000:del d[n]
 d[10]='10 GO SUB 7000'
 if not hud:
  d[110]='110 GO SUB 1000: GO SUB 3000';drop(d,355)
  d[1020]='1020 PRINT AT 1,2; "Turn. Burn. Coast. Brake."'
  d[1070]='1070 PRINT AT 20,2; INK 7; "Turn back to slow down."'
 if not dock:
  drop(d,360,1040,1050)
  d[1010]='1010 PRINT AT 0,2; INK 5; "DRIFT"; AT 0,19; INK 7; "FREE FLIGHT"'
  if hud:
   d[6020]='6020 IF vx * vx + vy * vy <= .16 THEN PRINT AT 1,17; INK 4; "SLOW    "'
 return d
items=[];previous={}
def save(name,d,lessons,kind):
 global previous
 folder=ROOT/name;folder.mkdir(exist_ok=True);source=folder/'drift.bas'
 source.write_text('\n'.join(d[n] for n in sorted(d))+'\n')
 edits={'from':items[-1]['name'] if items else None,'add':sorted(d.keys()-previous.keys()),'replace':sorted(n for n in d.keys()&previous.keys() if d[n]!=previous[n]),'delete':sorted(previous.keys()-d.keys())}
 (folder/'edits.json').write_text(json.dumps(edits,indent=2)+'\n')
 (folder/'changes.bas').write_text('\n'.join(d[n] for n in sorted(edits['add']+edits['replace']))+'\n')
 items.append(dict(name=name,source=str(source.relative_to(ROOT)),lessons=lessons,kind=kind));previous=d
one={1030:p[1030]}
put(one,'''10 BORDER 0: PAPER 0: INK 7: CLS
20 LET x = 48: LET y = 56
30 GO SUB 1000: GO SUB 3000: STOP
1000 PRINT AT 0,2; INK 5; "DRIFT"
1090 RETURN
3000 LET px = INT (x + .5): LET py = INT (y + .5)
3010 PLOT INK 7; OVER 1;px + 5,py
3020 DRAW INK 7; OVER 1;-8,3
3030 DRAW INK 7; OVER 1;0,-6
3040 DRAW INK 7; OVER 1;8,3: RETURN''')
save('draw-ship',one,[1],'drawing')
d=base()
for n in list(d):
 if 280<=n<=330 or 4000<=n<5000:del d[n]
d[100]='100 LET x = 48: LET y = 56: LET h = 2: LET steps = 0'
d[340]='340 LET steps = steps + 1'
d[1010]='1010 PRINT AT 0,2; INK 5; "DRIFT"; AT 0,19; INK 7; "HEADING"'
d[1020]='1020 PRINT AT 1,2; "Point somewhere. Stay here."'
d[1060]='1060 PRINT AT 19,2; INK 5; "O/P turn"'
d[1070]='1070 PRINT AT 20,2; INK 7; "Eight headings. One position."'
save('heading',d,[2],'heading')
save('flight',base(),[3,4],'flight')
save('readout',base(hud=True),[5],'readout')
save('docking',base(hud=True,dock=True),[6],'docking')
save('finished',p,[7,8],'finished')
assert (ROOT/'finished/drift.bas').read_bytes()==(ROOT.parent/'prototype/drift.bas').read_bytes()
(ROOT/'checkpoints.json').write_text(json.dumps(items,indent=2)+'\n')
print('Six checkpoints for eight lessons; final listing is byte-identical to the accepted prototype.')
