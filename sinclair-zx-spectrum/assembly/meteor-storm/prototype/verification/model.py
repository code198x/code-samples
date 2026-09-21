"""Independent movement model for scattered meteors; route needs no boost."""
import importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('art',ROOT/'assets.py');art=importlib.util.module_from_spec(spec);spec.loader.exec_module(art)
SCHEDULE=[]
time=20
for x,speed,delay,drift,kind in art.EVENTS:
 SCHEDULE.append((time,x,speed,drift,kind));time+=delay
END=max(t+(150+s-1)//s for t,x,s,d,k in SCHEDULE)
TRACKS={}
for t,x,speed,drift,kind in SCHEDULE:
 y=24
 while y<174:
  TRACKS.setdefault(t,[]).append((x,y,kind))
  if kind==1 and t%4==0:
   x+=drift
   if x<8:x=8;drift=1
   if x>224:x=224;drift=-1
  y+=speed;t+=1
def meteors(tick):return TRACKS.get(tick,[])
def audit():
 paths={116:(0,[])};peak=0;stationary={x:1 for x in range(8,225,2)};grace={x:0 for x in stationary}
 for tick in range(1,END+1):
  objects=meteors(tick);peak=max(peak,len(objects));danger=[x for x,y,kind in objects if kind==1 and 146<=y<174]
  following={}
  for old,(reward,path) in paths.items():
   for action in [0,-2,2]:
    x=max(8,min(224,old+action))
    if all(abs(x-mx)>=22 for mx in danger):
     bonus=sum(abs(x-sx)<12 and 156<=sy<169 for sx,sy,kind in objects if kind==2)
     candidate=(reward+bonus,path+[action])
     if x not in following or candidate[0]>following[x][0]:following[x]=candidate
  paths=following;assert paths,('no safe route',tick)
  for x in stationary:
   grace[x]=max(0,grace[x]-1)
   if stationary[x]>0 and not grace[x] and any(abs(x-mx)<16 for mx,y,kind in objects if kind==1 and 154<=y<172):stationary[x]-=1;grace[x]=60
 assert peak<=20
 route=max(paths.values(),key=lambda v:v[0])[1];positions=[116]
 for action in route:positions.append(max(8,min(224,positions[-1]+action)))
 return {'meteors':sum(k==1 for t,x,s,d,k in SCHEDULE),'stars':sum(k==2 for t,x,s,d,k in SCHEDULE),'last_hazards_clear_tick':END,'peak_meteors':peak,'damage_free_route_exists':True,'stationary_positions_tested':len(stationary),'stationary_survivors':sum(v>0 for v in stationary.values()),'positions':positions}
if __name__=='__main__':
 report=audit();print(json.dumps({k:v for k,v in report.items() if k!='positions'},indent=2));(ROOT/'verification/model-results.json').write_text(json.dumps(report,indent=2)+'\n')
