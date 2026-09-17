#!/usr/bin/env python3
"""Authoring derivation; outputs are standalone programs, not runtime imports."""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
def lines(s):return {int(x.split()[0]):x for x in s.splitlines() if x.strip()}
p=lines((ROOT.parent/'prototype/brick-bash.bas').read_text())
def put(d,s):d.update(lines(s))
def drop(d,*ns):
 for n in ns:d.pop(n,None)
def base(u):
 d=p.copy()
 for n in list(d):
  if 5000<=n<7000:del d[n]
 d[10]='10 GO SUB 7000'
 if u<8:drop(d,420,430);d[410]='410 LET ny = 64 - ny: LET dy = 4'
 if u<5:
  for n in list(d):
   if 2000<=n<3000 or 1040<=n<=1070 or n in [120,440,450,460,470,480]:del d[n]
  d[100]='100 LET p = 14: LET x = 127: LET y = 40'
  d[1010]='1010 PRINT AT 0,2; INK 5; "BRICK BASH"'
  d[7000]='7000 RESTORE 7230: FOR j = 24 TO 47: READ v: POKE USR "a" + j,v: NEXT j'
  drop(d,7010,7200,7210,7220)
 if u==4:d[390]='390 IF ny >= 32 THEN GO TO 490'
 if u<4:
  drop(d,390,400,410)
  d[390]='390 IF ny < 32 THEN LET e$ = "Ball reached the bottom.": GO TO 4000'
 if u==2:
  for n in list(d):
   if 230<=n<=320 or n>=7000 and n<9000:del d[n]
  drop(d,1080)
  d[10]='10 GO TO 100'
  d[100]='100 LET x = 127: LET y = 40'
  d[110]='110 LET dx = 4: LET dy = 4: LET steps = 0'
  d[1020]='1020 PRINT AT 1,2; "Watch the ball bounce."'
  d[1090]='1090 PRINT AT 21,2; INK 5; "R retry  Q quit";'
 if u==3:d[300]='300 IF k$ = " " THEN LET served = 1: PRINT AT 1,2; "Watch the ball bounce.": GO TO 350'
 if u==4:d[300]='300 IF k$ = " " THEN LET served = 1: PRINT AT 1,2; "Keep the ball in play.": GO TO 350'
 if u==5:
  d[100]='100 LET alive = 1: LET left = 1: LET p = 14: LET x = 127: LET y = 40'
  drop(d,120,1040,1050,1060,1070)
  d[1010]='1010 PRINT AT 0,2; INK 5; "BRICK BASH"; AT 0,21; INK 7; "BRICKS 1"'
  d[1040]='1040 PRINT AT 8,24; INK 5; b$'
  for n in range(2000,2050,10):d.pop(n,None)
  put(d,'''2000 LET hit = 0
2010 IF alive = 0 THEN RETURN
2020 IF tx + 1 < 192 OR tx > 215 OR ty + 1 < 104 OR ty > 111 THEN RETURN
2030 LET hit = 1: RETURN
2500 LET alive = 0: LET left = 0
2510 PRINT AT 8,24; "   "; AT 0,28; INK 7; left; " "''')
  d[480]='480 IF left = 0 THEN LET e$ = "Brick cleared! Nicely done.": GO TO 4000'
 return d
items=[];previous={}
def save(u,d,kind='game'):
 global previous
 name=f'unit-{u:02d}';folder=ROOT/name;folder.mkdir(exist_ok=True)
 source=folder/'brick-bash.bas';source.write_text('\n'.join(d[n] for n in sorted(d))+'\n')
 edits={'from':items[-1]['name'] if items else None,'add':[n for n in sorted(d) if n not in previous],'replace':[n for n in sorted(d) if n in previous and d[n]!=previous[n]],'delete':[n for n in sorted(previous) if n not in d]}
 (folder/'edits.json').write_text(json.dumps(edits,indent=2)+'\n')
 (folder/'changes.bas').write_text('\n'.join(d[n] for n in sorted(edits['add']+edits['replace']))+'\n')
 items.append({'name':name,'unit':u,'source':str(source.relative_to(ROOT)),'kind':kind});previous=d
one={n:p[n] for n in [1030,3000]}
put(one,'''10 BORDER 0: PAPER 0: INK 7: CLS
20 LET x = 127: LET y = 40
30 GO SUB 1000: GO SUB 3000: STOP
1000 PRINT AT 0,2; INK 5; "BRICK BASH"
1040 RETURN''')
save(1,one,'drawing')
for u in range(2,6):save(u,base(u))
ins=base(7)
for n in list(ins):
 if 130<=n<1000 or 3000<=n<7000:del ins[n]
drop(ins,1080)
put(ins,'''130 GO SUB 1000
200 INPUT "Ball X (-1 quits)? ";tx
210 IF tx = -1 THEN GO TO 9000
220 INPUT "Ball Y? ";ty
230 GO SUB 2000
240 PRINT AT 20,0; "                                "; AT 20,0; "ROW ";br;" COL ";bc;" HIT ";hit
250 IF hit = 1 THEN GO SUB 2500
260 GO TO 200
1020 PRINT AT 1,2; "Probe a ball position."
1090 PRINT AT 21,2; INK 5; "X = -1 quits the inspector";''')
save(6,ins,'inspector')
for u in [7,8]:save(u,base(u))
save(9,p)
assert (ROOT/'unit-09/brick-bash.bas').read_bytes()==(ROOT.parent/'prototype/brick-bash.bas').read_bytes()
(ROOT/'checkpoints.json').write_text(json.dumps(items,indent=2)+'\n')
print('Derived nine checkpoints; lesson ten reuses unit nine. Final source matches prototype.')
