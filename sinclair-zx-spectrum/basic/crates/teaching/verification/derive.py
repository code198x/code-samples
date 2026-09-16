"""Derive complete Crates stages and exact ROM line edits from the accepted game."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
PROTO=ROOT.parent/'prototype/crates.bas'
def read(path):return {int(l.split()[0]):l for l in path.read_text().splitlines()}
def change(p,updates=None,remove=()):
    q={n:l for n,l in p.items() if n not in remove}
    for n,l in (updates or {}).items():q[n]=f'{n} {l}'
    return q
p=read(PROTO)
one=change(p,{2510:'IF won = 1 THEN PRINT AT 19, 2; INK 4; "Delivered! R replay / Q quit"',590:'IF left = 0 THEN LET won = 1',5020:'PRINT AT 5, 2; INK 7; "A small warehouse puzzle."',6000:'LET left = 0: LET total = 0: FOR r = 1 TO 8: FOR c = 1 TO 8',6015:'IF g(r,c) = 2 OR g(r,c) = 4 THEN LET total = total + 1',2505:'PRINT AT 1, 18; INK 5; "GOALS "; total - left; "/"; total'},[82,83,90,135,580,800,810,820,2520,*range(4000,4330)])
counter=change(one,{10:'GO SUB 7000: LET h$ = ""'},[140,590,2510,*range(5000,5130)])
targets=change(counter,{},[85,475,476,2505,*range(6000,6030)])
push=change(targets,{430:'IF bv <> 0 THEN GO TO 700'},[450,470])
walk=change(push,{1030:'PRINT AT 21, 13; INK 5; "Q quit";',240:'IF v = 1 OR v = 3 THEN GO TO 700'},[130,250,*range(400,481)])
player=change(walk,{110:'STOP'},[*range(120,721),*range(2500,2541),*range(3000,3040),1070,1020,1030,*range(9000,9030)])
room=change(player,{},[2020,2025])
tile=change({}, {10:'BORDER 0: PAPER 0: INK 6: CLS',20:'RESTORE 7200: FOR n = 0 TO 31: READ b: POKE USR "a" + n,b: NEXT n',30:'LET t$ = CHR$ 144 + CHR$ 145 + CHR$ 146 + CHR$ 147',40:'PRINT AT 10,15; t$(1 TO 2); AT 11,15; t$(3 TO 4)',50:'STOP',**{7200+10*i:p[7280+10*i].split(' ',1)[1] for i in range(4)}})
# Spaces are deliberately not part of this map alphabet. '-' is floor, '+' is
# player-on-target and '*' is crate-on-target. The final dimension is not trimmed.
maps={1:['########','#------#','#--#.--#','#--#---#','#--C---#','#-P----#','#------#','########'],2:['########','#------#','#---.#-#','#---##-#','#---C-##','#---P--#','#------#','########'],3:['########','###.####','###.####','#--C---#','#--C---#','#--P---#','#------#','########']}
def map_lines(room):return {8000+(room-1)*100+10*i:'DATA "'+row+'"' for i,row in enumerate(maps[room])}
loadlines={86:'IF left = 0 THEN LET won = 1',20:'DIM g(8,8): LET moves = 0: LET won = 0: GO SUB 4000',4000:'RESTORE 8000',4010:'FOR r = 1 TO 8: READ m$',4020:'FOR c = 1 TO 8: LET b$ = m$(c): LET v = -1',4030:'IF b$ = "-" THEN LET v = 0',4040:'IF b$ = "#" THEN LET v = 1',4050:'IF b$ = "." THEN LET v = 2',4060:'IF b$ = "C" THEN LET v = 3',4070:'IF b$ = "*" THEN LET v = 4',4080:'IF b$ = "P" OR b$ = "+" THEN LET pr = r: LET pc = c: LET v = 0',4090:'IF b$ = "+" THEN LET v = 2',4100:'LET g(r,c) = v',4110:'NEXT c: NEXT r: RETURN',**map_lines(1)}
loader=change(one,loadlines,[30,40,50,60,70,80])
valid=change(loader,{20:'DIM g(8,8): LET moves = 0: LET won = 0: GO SUB 4000',21:'IF e$ <> "" THEN GO TO 4500',4005:'LET people = 0: LET crates = 0: LET goals = 0: LET e$ = ""',4015:'IF LEN m$ <> 8 THEN LET e$ = "Use eight symbols per row.": RETURN',4095:'IF v = -1 THEN LET e$ = "Unknown map symbol.": RETURN',4102:'IF b$ = "P" OR b$ = "+" THEN LET people = people + 1',4104:'IF v = 3 OR v = 4 THEN LET crates = crates + 1',4106:'IF v = 2 OR v = 4 THEN LET goals = goals + 1',4110:'NEXT c: NEXT r',4120:'IF people <> 1 THEN LET e$ = "Use exactly one player.": RETURN',4130:'IF crates = 0 THEN LET e$ = "Add at least one crate.": RETURN',4140:'IF crates <> goals THEN LET e$ = "Match crates and targets.": RETURN',4150:'IF goals = 0 THEN LET e$ = "Add at least one target."',4160:'RETURN',4500:'BORDER 0: PAPER 0: INK 7: CLS',4510:'PRINT AT 4,2; "Check room "; room',4520:'PRINT AT 6,2; e$',4530:'IF r < 9 THEN PRINT AT 8,2; "Row "; r',4540:'PRINT AT 11,2; "Edit DATA, then RUN again."',4550:'STOP'})
two=change(valid,{135:p[135].split(' ',1)[1],800:'LET room = room + 1',810:'IF room = 3 THEN LET room = 1',820:'GO TO 20',2510:'IF won = 1 AND room = 1 THEN PRINT AT 19, 2; INK 4; "Delivered! N for next room"',2520:'IF won = 1 AND room = 2 THEN PRINT AT 19, 2; INK 4; "Both done! N for a new game"',4002:'IF room = 2 THEN RESTORE 8100',5020:'PRINT AT 5, 2; INK 7; "Two rooms. Think, then push."',**map_lines(2)})
three=change(two,{810:'IF room = 4 THEN LET room = 1',2510:p[2510].split(' ',1)[1],2520:p[2520].split(' ',1)[1],4003:'IF room = 3 THEN RESTORE 8200',5020:p[5020].split(' ',1)[1],**map_lines(3)})
palette=change({n:l for n,l in p.items() if 7000<=n<8000},{10:'GO SUB 7000: BORDER 0: PAPER 0: CLS',20:'FOR z = 1 TO 7',30:'PRINT AT 10,2+3*z; INK a(z); t$(z,1 TO 2); AT 11,2+3*z; t$(z,3 TO 4)',40:'NEXT z',50:'STOP'})
items=[(1,1,'tile',tile),(2,1,'palette',palette),(2,2,'room',room),(2,3,'player',player),(3,1,'walk',walk),(4,1,'push',push),(5,1,'targets',targets),(6,1,'counter',counter),(6,2,'complete',one),(7,1,'loader',loader),(8,1,'validation',valid),(9,1,'two-rooms',two),(10,1,'three-rooms',three)]
roster=[];previous={};prev=None
for unit,step,name,program in items:
    rel=Path(f'unit-{unit:02}/steps/step-{step:02}.bas');path=ROOT/rel;path.parent.mkdir(parents=True,exist_ok=True)
    path.write_text('\n'.join(program[n] for n in sorted(program))+'\n')
    add=sorted(program.keys()-previous.keys());replace=sorted(n for n in program.keys()&previous.keys() if program[n]!=previous[n]);delete=sorted(previous.keys()-program.keys())
    edits=ROOT/f'unit-{unit:02}/snippets/step-{step:02}-edits.bas';edits.parent.mkdir(parents=True,exist_ok=True);edits.write_text('\n'.join(program[n] for n in sorted(add+replace))+'\n')
    restored={n:l for n,l in previous.items() if n not in delete};restored.update({n:program[n] for n in add+replace});assert restored==program
    roster.append({'unit':unit,'step':step,'name':name,'source':str(rel),'from':prev,'add':add,'replace':replace,'delete':delete,'edits':str(edits.relative_to(ROOT)),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
    previous=program;prev=str(rel)
(ROOT/'roster.json').write_text(json.dumps(roster,indent=2)+'\n')
print('Derived and reconstructed',len(roster),'states; lesson 11 saves the lesson 10 source unchanged.')
