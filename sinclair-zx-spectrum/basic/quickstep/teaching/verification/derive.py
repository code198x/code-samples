#!/usr/bin/env python3
"""Derive inspectable standalone listings and exact line-edit transitions."""
from pathlib import Path
import json,re,hashlib
ROOT=Path(__file__).resolve().parents[1]
original=(ROOT.parent/'prototype/quickstep.bas').read_text()
end={int(s.split()[0]):s for s in original.splitlines()}
def change(lines,updates):
 result=dict(lines)
 for n,s in updates.items():
  if s is None:result.pop(n,None)
  else:result[n]=f'{n} {s}'
 return result
def subset(lines,predicate):return {n:s for n,s in lines.items() if predicate(n)}
# Build backwards from the accepted endpoint; keep its line numbers and artwork.
buffered=change(subset(end,lambda n:not 5000<=n<7000),{10:'GO SUB 7000'})
six=change(buffered,{180:'GO SUB 1000: GO SUB 3000: LET dx = 0: LET dy = 0: LET tick = PEEK 23672',291:'LET k$ = INKEY$',292:'LET dx = 0: LET dy = 0'})
one=change(subset(six,lambda n:not 7100<=n<7200),{
100:'LET p = 10: LET d = -1: LET v = 2: LET t = v: DIM a$(30): DIM b$(30)',
110:'LET x = 7: LET y = 2: LET steps = 0',120:None,
140:'FOR j = 0 TO 2: FOR k = 0 TO 3',150:'LET c = 2 * p + 10 * j + k: LET c = c - 30 * INT (c / 30) + 1',
160:'LET a$(c) = CHR$ (144 + k): LET b$(c) = CHR$ (148 + k)',170:'NEXT k: NEXT j',
310:'IF nx < 0 OR nx > 14 OR ny < 0 OR ny > 2 THEN LET nx = x: LET ny = y',
350:'LET t = t - 1',360:'IF t > 0 THEN GO TO 440',370:'LET t = v: LET p = p + d',380:'IF p = 15 THEN LET p = 0',390:'IF p = -1 THEN LET p = 14',
400:'IF d = 1 THEN LET a$ = a$(29 TO 30) + a$(1 TO 28): LET b$ = b$(29 TO 30) + b$(1 TO 28)',
410:'IF d = -1 THEN LET a$ = a$(3 TO 30) + a$(1 TO 2): LET b$ = b$(3 TO 30) + b$(1 TO 2)',
420:'GO SUB 1200: IF y = 1 THEN GO SUB 3000',430:None,
1030:'FOR j = 0 TO 2 STEP 2',1080:'GO SUB 1200: LET z$ = ">": IF d = -1 THEN LET z$ = "<"',1082:None,
1200:'LET row = 4: LET ink = 6: IF d = -1 THEN LET ink = 5',1210:'PRINT AT row,1; PAPER 0; INK ink; a$; AT row+1,1; b$',
2000:'LET hit = 0: IF ny <> 1 THEN RETURN',2010:None,2015:'LET delta = nx - p: LET delta = delta - 5 * INT (delta / 5)',
3000:'LET paper = 0: IF y <> 1 THEN LET paper = 1',
3100:'IF y = 1 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN',
})
clock=change(subset(one,lambda n:not 2000<=n<3000 and not 4000<=n<5000),{320:None,330:None,440:'LET steps = steps + 1',450:None,460:None,
3110:'IF y = 0 AND x = 7 THEN PRINT AT 2,15; PAPER 4; "  "; AT 3,15; "  ": RETURN',
3120:'PRINT AT 2+2*y,1+2*x; PAPER 1; INK 5; g$; AT 3+2*y,1+2*x; g$: RETURN',
3100:'IF y = 1 THEN GO SUB 1200: RETURN',
})
lane=change(subset(clock,lambda n:not 280<=n<=294),{
180:'GO SUB 1000: GO SUB 3000',210:'IF k$ = "" THEN GO TO 200',
240:'IF k$ = " " THEN GO TO 370',
300:'LET nx = x + dx: LET ny = y + dy',
250:'LET dx = 0: LET dy = 0',340:'IF nx = x AND ny = y THEN GO TO 470',
341:'GO SUB 3100: LET x = nx: LET y = ny: GO SUB 3000: GO TO 470',350:None,360:None,
370:'LET p = p + d',440:'LET steps = steps + 1',470:'IF INKEY$ <> "" THEN GO TO 470',480:'GO TO 200',
1095:'PRINT AT 12,2; PAPER 0; INK 6; "SPACE moves the lane"',
})
walk=change(subset(lane,lambda n:not 1200<=n<2000 and not 7200<=n<7280),{
100:'LET steps = 0',110:'LET x = 7: LET y = 2',140:None,150:None,160:None,170:None,240:None,370:None,380:None,390:None,400:None,410:None,420:None,440:None,
1080:None,1081:None,1095:None,
3100:'IF y = 1 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN',
7000:'RESTORE 7280: FOR j = 64 TO 103: READ n: POKE USR "a" + j,n: NEXT j',
})
board=change(subset(walk,lambda n:n in (10,110,180) or 1000<=n<=1070 or 3000<=n<3100 or 7000<=n<9000),{
190:'STOP',1090:'RETURN',110:'LET x = 7: LET y = 2',
})
items=[];previous={}
for name,lesson,lines in [('board',1,board),('walk',2,walk),('lane',3,lane),('clock',4,clock),('crossing',5,one),('six-lanes',6,six),('buffered',8,buffered),('finished',9,end)]:
 text='\n'.join(lines[n] for n in sorted(lines))+'\n'
 folder=ROOT/name;folder.mkdir(exist_ok=True);(folder/'quickstep.bas').write_text(text)
 targets=[int(m) for m in re.findall(r'\b(?:GO TO|GO SUB|RESTORE) (\d+)',text)]
 assert all(n in lines for n in targets),(name,set(targets)-set(lines))
 adds=[n for n in lines if n not in previous];replaces=[n for n in lines if n in previous and lines[n]!=previous[n]];deletes=[n for n in previous if n not in lines]
 patched={n:s for n,s in previous.items() if n not in deletes};patched.update({n:lines[n] for n in adds+replaces});assert patched==lines
 (folder/'edits.json').write_text(json.dumps(dict(add=sorted(adds),replace=sorted(replaces),delete=sorted(deletes),enter=[lines[n] for n in sorted(adds+replaces)]),indent=2)+'\n')
 items.append(dict(name=name,lesson=lesson,source=f'{name}/quickstep.bas',sha256=hashlib.sha256(text.encode()).hexdigest(),lines=len(lines)))
 previous=lines
assert (ROOT/'finished/quickstep.bas').read_text()==original
(ROOT/'checkpoints.json').write_text(json.dumps(items,indent=2)+'\n')
print('Derived eight checkpoints; exact edit reconstruction and literal targets pass')
