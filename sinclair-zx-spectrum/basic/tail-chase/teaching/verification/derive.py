#!/usr/bin/env python3
"""Derive the taught listings and exact edits from the accepted endpoint.

Authoring tool only. Every output is a standalone learner program; execution
verification is separate. Run after deliberately editing this derivation.
"""
from pathlib import Path
import json
ROOT=Path(__file__).resolve().parents[1]
PROTO=ROOT.parent/'prototype/tail-chase.bas'
def listing(text):return {int(x.split()[0]):x for x in text.splitlines() if x.strip()}
p=listing(PROTO.read_text())
def setlines(d,text):d.update(listing(text))
def remove(d,*numbers):
 for n in numbers:d.pop(n,None)
def graphics(d,count):
 for n in range(7200,7270,10):d.pop(n,None)
 for n in range(7200,7200+count*10,10):d[n]=p[n]
 d[7000]=f'7000 RESTORE 7200: FOR j = 0 TO {count*8-1}: READ v: POKE USR "a" + j,v: NEXT j: RETURN'
def early_graphics(d):
 graphics(d,1);d[7220]=p[7220]
 d[7000]='7000 RESTORE 7200: FOR j = 0 TO 7: READ v: POKE USR "a" + j,v: NEXT j'
 d[7010]='7010 RESTORE 7220: FOR j = 0 TO 7: READ v: POKE USR "c" + j,v: NEXT j: RETURN'
def base(stage):
 d=p.copy()
 for n in list(d):
  if 5000<=n<7000:del d[n]
 d[10]='10 GO SUB 7000'
 if stage<6:
  remove(d,2000,2010,2020,2030,2500,2510,300,330,380,420,430,440,450)
  d[130]='130 GO SUB 1000'
 if stage<4:
  remove(d,100,120,310,320,330,340,350,360,390,1040+10)
  d[110]='110 LET r = 8: LET c = 9: LET dr = 0: LET dc = 1: LET steps = 0'
  d[170]='170 IF k$ = "r" OR k$ = "R" THEN GO TO 110'
  d[4050]='4050 IF k$ = "r" OR k$ = "R" THEN GO TO 110'
  d[280]='280 LET nr = r + dr: LET nx = c + dc'
  d[400]='400 PRINT AT r+3,c+3; " ": LET r = nr: LET c = nx: LET steps = steps + 1'
  d[3040]='3040 PRINT AT r+3,c+3; INK 7; CHR$ z'
  if stage==2:
   remove(d,180,190,200,210,220,3010,3020,3030)
   early_graphics(d)
   d[140]='140 LET tick = PEEK 23672'
   d[270]='270 LET tick = PEEK 23672'
   d[460]='460 GO TO 150'
   d[1070]='1070 PRINT AT 21,7; INK 5; "R retry     Q quit";'
  else:graphics(d,5)
 else:
  graphics(d,6 if stage<6 else 7)
  if stage<7:
   d[100]='100 DIM a(12): DIM b(12)'
   d[120]='120 FOR j = 1 TO 4: LET a(j) = 8: LET b(j) = j + 5: NEXT j'
   d[340]='340 PRINT AT a(t)+3,b(t)+3; " "'
   d[400]='400 LET a(h) = nr: LET b(h) = nx: LET steps = steps + 1'
   d[310]='310 GO SUB 3500: IF hit = 1 THEN LET e$ = "You caught your tail!": GO TO 4000'
   setlines(d,'''3500 LET hit = 0: LET slot = t
3510 FOR j = 1 TO n
3520 IF j = 1 AND grow = 0 THEN GO TO 3540
3530 IF a(slot) = nr AND b(slot) = nx THEN LET hit = 1
3540 LET slot = slot + 1: IF slot = 13 THEN LET slot = 1
3550 NEXT j: RETURN''')
  if stage<6:d[300]='300 LET grow = 0'
  if stage==4:
   d[100]='100 DIM a(4): DIM b(4)'
   remove(d,350,360)
   d[390]='390 FOR j = 1 TO 3: LET a(j) = a(j+1): LET b(j) = b(j+1): NEXT j'
   d[3500]='3500 LET hit = 0'
   d[3510]='3510 FOR j = 2 TO n'
   d[3530]='3530 IF a(j) = nr AND b(j) = nx THEN LET hit = 1'
   remove(d,3520,3540)
 if stage in (6,7,8):
  d[440]='440 IF eaten = 1 THEN LET e$ = "One snack. Nicely done!": GO TO 4000'
  d[2500]='2500 PRINT AT 1,4; INK 7; "FOOD "; eaten; "/1"; AT 1,18; "LENGTH "; n; " "'
  if stage<8:
   d[2000]='2000 LET fr = 8: LET fc = 12';remove(d,2010)
  d[1020]='1020 PRINT AT 2,5; INK 7; "Eat one snack. R retries."'
 return d
face=listing('''10 BORDER 0: PAPER 0: INK 7: CLS
20 RESTORE 7220: FOR j = 0 TO 7: READ v: POKE USR "c" + j,v: NEXT j
30 PRINT AT 11,12; CHR$ 146
40 STOP''');face[7220]=p[7220]
arena=base(2)
for n in list(arena):
 if n<1000:del arena[n]
setlines(arena,'''10 GO SUB 7000
20 LET r = 8: LET c = 9
30 GO SUB 1000
40 STOP''')
for n in list(arena):
 if 4000<=n<7000:del arena[n]
# A stationary arena needs no control promise.
arena[1070]='1070 PRINT AT 21,5; INK 5; "An arena with room to turn.";'
items=[(1,1,'face',face),(1,2,'arena',arena)]+[(i,1,name,base(i)) for i,name in [(2,'moving-head'),(3,'steering'),(4,'shifted-body'),(5,'circular-body'),(6,'fixed-food'),(7,'occupancy'),(8,'random-food')]]+[(9,1,'eight-foods',p)]
expanded=[]
for item in items:
 expanded.append(item)
 unit,step,name,d=item
 if unit in (6,7):
  diag=d.copy();diag[440]='440 LET fr = 0: LET fc = 0: GO TO 460'
  diag[1020]='1020 PRINT AT 2,2; INK 7; "Body test: eat, then turn."'
  expanded.append((unit,2,name+'-body-test',diag))
items=expanded
previous={};records=[]
for unit,step,name,d in items:
 path=ROOT/f'unit-{unit:02}/steps/step-{step:02}.bas';path.parent.mkdir(parents=True,exist_ok=True)
 path.write_text('\n'.join(d[n] for n in sorted(d))+'\n')
 added=sorted(d.keys()-previous.keys());deleted=sorted(previous.keys()-d.keys());replaced=sorted(n for n in d.keys()&previous.keys() if d[n]!=previous[n])
 edits=path.parent.parent/'snippets'/f'step-{step:02}-edits.bas';edits.parent.mkdir(exist_ok=True)
 edits.write_text('\n'.join(d[n] for n in sorted(added+replaced))+'\n')
 records.append({'unit':unit,'step':step,'name':name,'source':str(path.relative_to(ROOT)),'add':added,'replace':replaced,'delete':deleted})
 previous=d
(ROOT/'checkpoints.json').write_text(json.dumps(records,indent=2)+'\n')
print('Derived',len(records),'standalone checkpoints. Unit 10 saves the unit 9 endpoint.')
