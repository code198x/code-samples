"""Derive readable teaching states and exact edit rosters from reviewed prototypes."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
PROTO=ROOT.parent/'prototype'
def read(path):return {int(s.split()[0]):s for s in path.read_text().splitlines()}
def change(program, updates=None, remove=()):
    result=program.copy()
    for n in remove:result.pop(n,None)
    for n,text in (updates or {}).items():result[n]=f'{n} {text}'
    return result
p1=read(PROTO/'steps/step-01.bas')
p2=read(PROTO/'steps/step-02.bas')
p3=read(PROTO/'steps/step-03.bas')
final=read(PROTO/'experiments/distance-bands.bas')
row={10:'BORDER 1: PAPER 0: INK 7: CLS',20:'LET r = 1',30:'FOR c = 1 TO 8',40:'LET y = 4 + 2 * (r - 1): LET x = 5 + 3 * (c - 1)',50:'PAPER 1: INK 7',60:'IF r + c = 2 * INT ((r + c) / 2) THEN PAPER 5: INK 0',70:'PRINT AT y, x; " . "; AT y + 1, x; "   "',80:'NEXT c',90:'STOP'}
row={n:f'{n} {s}' for n,s in row.items()}
board=change(p1,{90:'PRINT AT 21, 1; "X marks row 3, column 6.";'},[60,70])
row_input=change(p2,{110:'PRINT AT 21, 0; "Selected row: "; pr; "                ";',115:'GO TO 100'},range(120,271))
latest=change(p3,{80:'PRINT AT 21, 0; "N=1-2, M=3-4, F=5+ steps.";',171:'IF d > 4 THEN LET d = 3: GO TO 180',172:'IF d > 2 THEN LET d = 2: GO TO 180',173:'IF d > 0 THEN LET d = 1',180:'LET b$ = " F"',190:'IF d = 2 THEN LET b$ = " M"',195:'IF d = 1 THEN LET b$ = " N"',250:'IF d = 3 THEN PRINT AT 21, 0; "Far: at least 5 steps away.";',251:'IF d = 2 THEN PRINT AT 21, 0; "Medium: 3 or 4 steps away.";',252:'IF d = 1 THEN PRINT AT 21, 0; "Near: 1 or 2 steps away.";',1010:'PRINT AT 0, 6; "SONAR N1-2 M3-4 F5+"'})
fixed=change(final,{20:'LET tr = 3: LET tc = 6'},[16])
counted=change(fixed,{},[15,300,*range(5000,6060)])
memory=change(counted,{27:'LET lr = 0: LET lc = 0: LET pr = 0: LET pc = 0',160:'LET g(pr,pc) = d',280:'IF d = 0 THEN LET s$ = "Found! Q quits; RUN tries again"'},[120,130,140,250,270,1180,2500,2510,2520])
# First introduce the array in a small independent laboratory program. The
# roster explicitly says to save the game, NEW, inspect, then reload the game.
array={10:'DIM g(8,8)',20:'PRINT g(1,1)',30:'FOR r = 1 TO 8',40:'FOR c = 1 TO 8',50:'LET g(r,c) = -1',60:'NEXT c',70:'NEXT r',80:'PRINT g(1,1); " "; g(8,8)',90:'LET g(1,2) = 3',100:'PRINT g(1,2); " "; g(2,1)',110:'STOP'}
array={n:f'{n} {s}' for n,s in array.items()}
items=[(1,1,'row',row),(1,2,'board',board),(2,1,'row-input',row_input),(2,2,'probe',p2),(3,1,'distance',p3),(4,1,'bands',latest),(5,1,'array-lab',array),(5,2,'memory',memory),(6,1,'count',counted),(7,1,'round',fixed),(8,1,'random',final)]
roster=[];previous={};previous_path=None;saved=None
for unit,step,name,program in items:
    if name=='array-lab':saved=(previous,previous_path);previous={};previous_path=None
    if name=='memory':previous,previous_path=saved
    folder=ROOT/f'unit-{unit:02}'
    rel=Path(f'unit-{unit:02}/steps/step-{step:02}.bas');path=ROOT/rel;path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text('\n'.join(program[n] for n in sorted(program))+'\n')
    add=sorted(program.keys()-previous.keys());replace=sorted(n for n in program.keys()&previous.keys() if program[n]!=previous[n]);delete=sorted(previous.keys()-program.keys())
    edits=folder/'snippets'/f'step-{step:02}-edits.bas';edits.parent.mkdir(exist_ok=True)
    edits.write_text('\n'.join(program[n] for n in sorted(add+replace))+'\n')
    roster.append({'unit':unit,'step':step,'name':name,'source':str(rel),'from':previous_path,'add':add,'replace':replace,'delete':delete,'edits':str(edits.relative_to(ROOT))})
    previous=program;previous_path=str(rel)
(ROOT/'roster.json').write_text(json.dumps(roster,indent=2)+'\n')
assert (ROOT/'unit-08/steps/step-01.bas').read_bytes()==(PROTO/'experiments/distance-bands.bas').read_bytes()
print('Derived',len(roster),'states; final source equals accepted endpoint.')
