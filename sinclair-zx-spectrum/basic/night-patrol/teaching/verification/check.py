"""Fresh teaching tapes, ordinary keys, read-only state and checkpoint-specific rules."""
import argparse,concurrent.futures,hashlib,json,sys
from collections import deque
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from observe import state,line
from model import MAP,beam,GUARDS,D
from check import Review as PrototypeReview
# Importing this file as __main__ resolves `check` above to the prototype helper.
NAMES=['archive','movement','mission','patrol','scans','sight','stealth','finished']
FIELDS=['x','y','gx','gy','gd','beat','got','phase']
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def pack(s):return tuple(int(s.get(k,0)) for k in FIELDS)
def advance(mode,s,key):
 x,y,gx,gy,gd,beat,got,phase=s;dx,dy={'i':(0,-1),'k':(0,1),'j':(-1,0),'l':(1,0)}.get(key.lower(),(0,0));nx,ny=x+dx,y+dy
 if MAP[ny-1][nx-1]==' ':x,y=nx,ny
 guarded=mode in ('patrol','scans','sight','stealth');sighted=mode in ('sight','stealth')
 if guarded and ((x,y)==(gx,gy) or (sighted and (x,y) in beam(gx,gy,gd))):return (x,y,gx,gy,gd,beat,got,phase),1
 if mode!='movement':
  if (x,y)==(27,3):got=1
  if (x,y)==(3,16) and got:return (x,y,gx,gy,gd,beat,got,phase),2
 if mode in ('patrol','scans','stealth'):
  beat+=1
  if beat==2:
   beat=0
   if mode=='patrol':
    if (gd==1 and gx==24) or (gd==2 and gy==14) or (gd==3 and gx==7) or (gd==4 and gy==5):gd=gd%4+1
    dx,dy=D[gd-1];gx+=dx;gy+=dy
   else:phase=phase+1 if phase<60 else 1;gx,gy,gd=GUARDS[phase]
 result=int(guarded and ((x,y)==(gx,gy) or (sighted and (x,y) in beam(gx,gy,gd))))
 return (x,y,gx,gy,gd,beat,got,phase),result

def route(mode,start,goal=None):
 q=deque([start]);parents={start:None}
 while q:
  s=q.popleft()
  if goal and goal(s):
   path=[]
   while parents[s] is not None:s,k=parents[s];path.append(k)
   return path[::-1]
  for k in ('','i','j','k','l'):
   nxt,result=advance(mode,s,k)
   if result==2 and goal is None:
    path=[k]
    while parents[s] is not None:s,k=parents[s];path.append(k)
    return path[::-1]
   if result or nxt in parents:continue
   parents[nxt]=(s,k);q.append(nxt)
 raise AssertionError(('no route',mode))

class Review(PrototypeReview):
 def __init__(self,mode,exe,out):super().__init__(exe,out);self.mode=mode
 def record(self,name):self.checks.append(name);print('PASS',self.mode,name,flush=True)
 def invariant(self,s):
  assert MAP[int(s['y'])-1][int(s['x'])-1]==' '
  assert 'scroll?' not in ''.join(self.m.screen()).lower()
  if self.mode in ('sight','stealth'):
   cells=beam(int(s['gx']),int(s['gy']),int(s['gd']))
   assert all((s['v$'][32*y+x-1]=='!')==((x,y) in cells) for y in range(1,19) for x in range(1,31))
   assert s['bn']==len(cells)
 def tick(self,key='',held=False):
  self.boundary({250});before=state(self.m);expected,result=advance(self.mode,pack(before),key)
  self.event(key,True);self.m.frames(0);self.boundary({260})
  if not held:self.event(key,False);self.m.frames(0)
  self.boundary({470,4000});after=state(self.m)
  assert pack(after)==expected,(self.mode,key,pack(before),pack(after),expected)
  assert after.get('outcome',0)==result and (line(self.m)==4000)==bool(result)
  assert after['steps']==before['steps']+int(expected[:2]!=pack(before)[:2]);self.invariant(after)
  self.trace.append(dict(key=key,before=pack(before),after=pack(after),result=result))
  self.boundary({8010} if result else {200});return after,result
 def reset(self):
  self.event('r',True);self.m.frames(0);self.boundary({8100,8020});self.event('r',False);self.m.frames(0)
  self.boundary({100});self.boundary({200});s=state(self.m)
  assert pack(s)==self.initial and s['steps']==0 and s.get('outcome',0)==0;self.invariant(s);return s
 def execute(self):
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'night-patrol.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start')
  self.boundary({20} if self.mode=='archive' else {200})
  assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()};self.record('fresh-tape-autostart-and-stored-source-identity')
  if self.mode=='archive':
   self.advance_frames(50);assert any('9 STOP statement' in r for r in self.m.screen())
   rows=self.m.screen()
   for y,row in enumerate(MAP,1):
    expected=''.join('?' if c=='#' or (x,y) in [(27,3),(3,16)] else ' ' for x,c in enumerate(row,1))
    assert rows[y+1][1:31]==expected,(y,rows[y+1],expected)
   self.record('full-map-and-distinct-object-positions');self.record('stops-without-falling-into-subroutines');self.save();return
  s=state(self.m);self.initial=pack(s);self.invariant(s);assert s['x']==3 and s['y']==16;self.record('safe-start-and-map-state')
  for key in ('x','L','j','j','k'):s,result=self.tick(key);assert not result
  assert s['x']==3 and s['y']==16;self.record('ignored-key-uppercase-and-wall-rejection')
  for _ in range(3):s,result=self.tick('l',held=True);assert not result
  self.event('l',False);self.m.frames(0);assert s['x']==6;self.record('held-key-repeats-movement')
  self.reset();self.record('retry-restores-initial-state')
  if self.mode!='movement':
   s,result=self.tick();assert not result and s['got']==0;self.record('empty-handed-entrance-does-not-win');self.reset()
  if self.mode in ('patrol','scans','sight','stealth'):
   poses=set();scans=set();initial_guard=pack(state(self.m))[2:5]
   for _ in range(122 if self.mode!='sight' else 8):
    before=pack(state(self.m));s,result=self.tick();assert not result;after=pack(s);poses.add(after[2:5])
    if after[2:4]==before[2:4] and after[4]!=before[4]:scans.add(after[2:5])
   if self.mode=='sight':assert poses=={initial_guard};self.record('diagnostic-guard-and-mask-stay-stationary')
   else:
    assert {p[2] for p in poses}=={1,2,3,4};self.record('patrol-without-player-input-and-complete-lap')
    if self.mode!='patrol':assert len(scans)==8;self.record('eight-stationary-corner-facing-changes')
   self.reset()
  if self.mode!='movement':
   path=route(self.mode,pack(state(self.m)));picked=False
   for key in path:
    s,result=self.tick(key);picked |= bool(s['got'])
   assert picked and result==2;self.record('ordinary-key-file-pickup-and-safe-return')
   before=pack(s);self.advance_frames(150);assert pack(state(self.m))==before;self.record('win-freezes-world')
   self.reset();self.record('retry-after-win-restores-file-and-state')
  if self.mode in ('patrol','scans','sight','stealth'):
   s,result=self.walk(route(self.mode,pack(state(self.m)),goal=lambda s:any(advance(self.mode,s,k)[1]==1 for k in ('i','j','k','l'))))
   key=next(k for k in ('i','j','k','l') if advance(self.mode,pack(s),k)[1]==1)
   s,result=self.tick(key);assert result==1;self.record('ordinary-movement-into-danger-is-caught')
   before=pack(s);self.advance_frames(150);assert pack(state(self.m))==before;self.record('capture-freezes-world')
   self.reset();self.record('retry-after-capture-restores-world')
  if self.mode=='stealth':
   def scan_catches(s):
    after,result=advance(self.mode,s,'');return result==1 and after[2:4]==s[2:4] and after[4]!=s[4]
   s,result=self.walk(route(self.mode,pack(state(self.m)),goal=scan_catches));s,result=self.tick();assert result==1;self.record('stationary-look-back-capture')
  self.event('q',True);self.m.frames(0);self.boundary({9000});self.event('q',False);self.m.frames(0);self.advance_frames(50)
  assert any('9 STOP statement' in r for r in self.m.screen());self.record('quit-to-basic');self.save()
 def save(self):
  (self.out/'results.json').write_text(json.dumps(dict(source_sha256=sha(ROOT/self.mode/'night-patrol.bas'),tape_sha256=sha(self.out/'night-patrol.tap'),binary_sha256=sha(Path(self.exe)),checks=self.checks,server=self.m.server,direct_memory_writes=False,configuration='Stock 48K PAL; independently ROM-entered tape; ordinary keys; read-only observation',trace=self.trace),indent=2)+'\n')

def check(name,exe,out):
 if name=='finished':
  r=PrototypeReview(exe,out/name)
 else:r=Review(name,exe,out/name)
 try:r.execute()
 except Exception:
  (r.out/'failure.json').write_text(json.dumps(dict(line=line(r.m),screen=r.m.screen(),checks=r.checks,trace=r.trace[-3:]),indent=2)+'\n');raise
 finally:r.m.close()
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only',choices=NAMES);p.add_argument('--jobs',type=int,default=1);a=p.parse_args()
 names=[a.only] if a.only else NAMES
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:list(pool.map(lambda name:check(name,a.emulator,a.output.resolve()),names))
