"""Independent coordinate model: collision is map state, never screen colour."""
from collections import deque
from functools import lru_cache
from math import floor
from pathlib import Path
import re,json
ROOT=Path(__file__).resolve().parents[1]
MAP=[row for n,row in re.findall(r'^(7[23]\d0) DATA "([^"]+)"$',(ROOT/'night-patrol.bas').read_text(),re.M)]
MOVES={'':(0,0),'i':(0,-1),'k':(0,1),'j':(-1,0),'l':(1,0)}
D=((1,0),(0,1),(-1,0),(0,-1))
def wall(x,y):return MAP[y-1][x-1]=='#'
@lru_cache(None)
def beam(gx,gy,gd):
 dx,dy=D[gd-1];sx,sy=-dy,dx;cells=set()
 for depth in range(1,6):
  for offset in range(1-depth,depth):
   previous=(gx,gy);clear=True
   for distance in range(1,depth+1):
    side=floor(offset*distance/depth+0.5)
    x,y=gx+dx*distance+sx*side,gy+dy*distance+sy*side
    if not (1<=x<=30 and 1<=y<=18) or wall(x,y):clear=False;break
    # Walls touching either side of a diagonal block that corner.
    if x!=previous[0] and y!=previous[1] and (wall(x,previous[1]) or wall(previous[0],y)):
     clear=False;break
    previous=x,y
   if clear:cells.add((x,y))
 return frozenset(cells)
# Independent schedule: walk a side, look behind, then face the next side.
GUARDS=[(7,5,1)]
GUARDS += [(x,5,1) for x in range(8,25)]+[(24,5,3),(24,5,2)]
GUARDS += [(24,y,2) for y in range(6,15)]+[(24,14,4),(24,14,3)]
GUARDS += [(x,14,3) for x in range(23,6,-1)]+[(7,14,1),(7,14,4)]
GUARDS += [(7,y,4) for y in range(13,4,-1)]+[(7,5,2),(7,5,1)]
START=(3,16,7,5,1,0,0,0)
def advance(s,key):
 x,y,gx,gy,gd,beat,got,phase=s;dx,dy=MOVES.get(key.lower(),(0,0));nx,ny=x+dx,y+dy
 if not wall(nx,ny):x,y=nx,ny
 if (x,y)==(gx,gy) or (x,y) in beam(gx,gy,gd):return (x,y,gx,gy,gd,beat,got,phase),1
 if (x,y)==(27,3):got=1
 if (x,y)==(3,16) and got:return (x,y,gx,gy,gd,beat,got,phase),2
 beat+=1
 if beat==2:
  beat=0
  phase=phase+1 if phase<60 else 1
  gx,gy,gd=GUARDS[phase]
  assert not wall(gx,gy)
 result=int((x,y)==(gx,gy) or (x,y) in beam(gx,gy,gd))
 return (x,y,gx,gy,gd,beat,got,phase),result
def route(start=START,goal=None):
 queue=deque([start]);parents={start:None}
 while queue:
  s=queue.popleft()
  if goal and goal(s):
   path=[]
   while parents[s] is not None:s,k=parents[s];path.append(k)
   return path[::-1]
  for key in MOVES:
   nxt,result=advance(s,key)
   if result==2 and goal is None:
    path=[key]
    while parents[s] is not None:s,k=parents[s];path.append(k)
    return path[::-1]
   if result or nxt in parents:continue
   parents[nxt]=(s,key);queue.append(nxt)
 raise AssertionError('No safe route')
def audit():
 assert len(MAP)==18 and all(len(r)==30 for r in MAP)
 assert all(MAP[y][0]==MAP[y][-1]=='#' for y in range(18)) and set(MAP[0]+MAP[-1])=={'#'}
 reachable={(3,16)};q=deque(reachable)
 while q:
  x,y=q.popleft()
  for dx,dy in D:
   p=x+dx,y+dy
   if not wall(*p) and p not in reachable:reachable.add(p);q.append(p)
 assert len(reachable)==sum(row.count(' ') for row in MAP)
 path=route();s=START
 for key in path:s,result=advance(s,key)
 assert result==2
 guards=set();s=START
 for _ in range(242):s,result=advance(s,'');assert not result;guards.add(s[2:5])
 assert {s[2] for s in guards}=={1,2,3,4}
 # Both sides of the opening fan are visible; range and walls still limit it.
 assert (13,5) not in beam(7,5,1) and (9,4) in beam(7,5,1) and (9,6) in beam(7,5,1)
 assert all(not wall(x,y) for gx,gy,gd in guards for x,y in beam(gx,gy,gd))
 assert (9,9) not in beam(7,12,4)
 assert len(GUARDS)==61 and GUARDS[-1]==GUARDS[0]
 assert sum(GUARDS[i][:2]==GUARDS[i-1][:2] for i in range(1,61))==8
 return dict(dimensions=[30,18],connected_floor_cells=len(reachable),safe_route_beats=len(path),safe_route=path,patrol_states=len(guards))
if __name__=='__main__':
 data=audit();(ROOT/'verification/evidence').mkdir(exist_ok=True);(ROOT/'verification/evidence/model.json').write_text(json.dumps(data,indent=2)+'\n');print('PASS map connectivity, four patrol directions, wall occlusion and safe round trip:',len(data['safe_route']),'beats')
