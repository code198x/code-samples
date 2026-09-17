#!/usr/bin/env python3
"""Derive standalone teaching checkpoints from the accepted Locksmith endpoint."""
from pathlib import Path
import json,hashlib,re
ROOT=Path(__file__).resolve().parents[1]
original=(ROOT.parent/'prototype/locksmith.bas').read_text();end={int(s.split()[0]):s for s in original.splitlines()}
def change(lines,updates):
 result=dict(lines)
 for n,s in updates.items():
  if s is None:result.pop(n,None)
  else:result[n]=f'{n} {s}'
 return result
def subset(lines,pred):return {n:s for n,s in lines.items() if pred(n)}
rounds=change(subset(end,lambda n:n==10 or n>=200),{})
history=change(rounds,{
200:'DIM c(4): LET c(1) = 1: LET c(2) = 1: LET c(3) = 2: LET c(4) = 2',210:None,
430:None,440:'IF t = 10 THEN GO TO 5100',5000:None,5010:None,
5100:'PRINT AT 17,1; INK 6; "Ten practice guesses recorded. "',
1020:'PRINT AT 2,1; INK 7; "Practice code: 1122"',1070:'PRINT AT 21,1; "ENTER: check  R: clear Q: quit"',
5220:'PRINT AT 20,1; "R: clear board   Q: quit       "',
})
clues=change(subset(history,lambda n:not 5000<=n<8000),{
440:None,450:None,460:None,470:'GO TO 230',
1010:'PRINT AT 0,1; INK 5; "LOCKSMITH"; AT 0,21; INK 7; "PRACTICE"',
1040:'PRINT AT 5,1; INK 1; "-"; AT 5,7; ". . . ."; AT 5,21; "."; AT 5,28; "."',
420:'GO SUB 4000: PRINT AT 18,2; "                            "',
})
exact=change(subset(clues,lambda n:not 3030<=n<=3110),{
3000:'DIM g(4): LET bulls = 0',3120:'RETURN',
1030:'PRINT AT 4,1; INK 5; "TRY"; AT 4,7; "CODE"; AT 4,19; "EXACT"',
1040:'PRINT AT 5,1; INK 1; "-"; AT 5,7; ". . . ."; AT 5,21; "."',
4020:'PRINT AT 4 + t,21; INK 4; bulls',
})
editor=change(subset(exact,lambda n:not 3000<=n<5000),{
200:'LET t = 1',220:'LET g$ = "": GO SUB 1000',
410:'PRINT AT 18,2; INK 4; "Four digits ready.          ": GO TO 230',420:None,470:None,
1020:'PRINT AT 2,1; INK 7; "Build a four-digit guess."',1030:None,1040:None,
})
board=change(subset(editor,lambda n:n in (10,200,220,240) or 1000<=n<3000),{
240:'GO SUB 2000: STOP',1060:'PRINT AT 20,1; INK 7; "Four spaces for four digits."',1070:None,
2010:None,
})
previous={};items=[];edits=['# Locksmith source transitions','', 'The opening is a new program. Later steps list exact additions, replacements and deletions.','']
for name,lesson,lines in [('board',1,board),('editor',2,editor),('exact',3,exact),('clues',4,clues),('history',5,history),('round',7,rounds),('finished',8,end)]:
 text='\n'.join(lines[n] for n in sorted(lines))+'\n';folder=ROOT/name;folder.mkdir(exist_ok=True);(folder/'locksmith.bas').write_text(text)
 targets=[int(n) for n in re.findall(r'\b(?:GO TO|GO SUB|RESTORE) (\d+)',re.sub(r'"[^"]*"','',text))];assert all(n in lines for n in targets),(name,targets)
 add=sorted(set(lines)-set(previous));delete=sorted(set(previous)-set(lines));replace=sorted(n for n in lines.keys()&previous.keys() if lines[n]!=previous[n]);enter=[lines[n] for n in sorted(add+replace)]
 patched={n:s for n,s in previous.items() if n not in delete};patched.update({n:lines[n] for n in add+replace});assert patched==lines
 (folder/'edits.json').write_text(json.dumps(dict(add=add,replace=replace,delete=delete,enter=enter),indent=2)+'\n')
 if previous:(folder/'changes.bas').write_text('\n'.join(enter+[str(n) for n in delete])+'\n')
 edits+=['## '+name,'']+[action+': '+(', '.join(map(str,ns)) or 'none') for action,ns in [('Add',add),('Replace',replace),('Delete',delete)]]+['']
 items.append(dict(name=name,lesson=lesson,source=name+'/locksmith.bas',sha256=hashlib.sha256(text.encode()).hexdigest(),lines=len(lines)));previous=lines
assert (ROOT/'finished/locksmith.bas').read_text()==original
(ROOT/'checkpoints.json').write_text(json.dumps(items,indent=2)+'\n');(ROOT/'edits.md').write_text('\n'.join(edits))
print('Seven checkpoints: source transitions, literal targets and endpoint identity pass')
