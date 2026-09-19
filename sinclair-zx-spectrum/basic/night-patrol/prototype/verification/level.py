"""Compile static, wall-clipped sight changes into ordinary BASIC DATA.

The game needs no host at runtime. Re-run after changing the map, patrol or fan.
Positive cells enter sight; negative cells leave it. Cell = 32 * row + column.
"""
from pathlib import Path
from model import beam,D
ROOT=Path(__file__).resolve().parents[1]
def patrol():
 x,y,d=7,5,1;out=[(x,y,d)]
 for tx,ty in [(24,5),(24,14),(7,14),(7,5)]:
  dx,dy=D[d-1]
  while (x,y)!=(tx,ty):
   x+=dx;y+=dy;out.append((x,y,d))
  out.append((x,y,(d+1)%4+1))  # Look back along the corridor.
  d=d%4+1
  out.append((x,y,d))          # Check the next corridor before moving.
 assert len(out)==61 and out[-1]==out[0]
 return out
def lines():
 guards=patrol();result=[]
 for i,g in enumerate(guards):
  before=beam(*guards[i-1]);after=beam(*g)
  added=after-before
  changes=[-(32*y+x) for x,y in sorted(before-after)]+[32*y+x for x,y in sorted(added)]
  data=[*g,len(after),len(changes),*changes]
  result.append(f'{8200+10*i} DATA '+','.join(map(str,data)))
 cells=beam(*guards[0]);data=[*guards[0],len(cells),len(cells),*[32*y+x for x,y in sorted(cells)]]
 result.append('8900 DATA '+','.join(map(str,data)))
 return result
if __name__=='__main__':
 p=ROOT/'night-patrol.bas';source=[s for s in p.read_text().splitlines() if not 8200<=int(s.split()[0])<=8900]
 p.write_text('\n'.join(sorted(source+lines(),key=lambda s:int(s.split()[0])))+'\n')
 print('Compiled opening plus 60 patrol/scan transitions and initial fan; maximum',max(len(beam(*g)) for g in patrol()),'visible cells')
