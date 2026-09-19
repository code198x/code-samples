"""Fresh ROM tape, ordinary keys, read-only state and independent patrol model."""
import argparse,hashlib,json
from pathlib import Path
from entry import Spectrum,ROOT
from observe import state,line
from model import START,advance,route,beam,MAP,audit

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def unpack(s):return tuple(int(s[k]) for k in ['x','y','gx','gy','gd','beat','got','phase'])
class Review:
 def __init__(self,exe,out):self.exe=exe;self.out=out;self.m=Spectrum(exe,out);self.checks=[];self.trace=[]
 def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
 def boundary(self,targets):
  for attempt in range(8000):
   at=line(self.m)
   if attempt and attempt%500==0:print("WAIT",targets,"at",at,self.m.screen()[-3:],flush=True)
   if at in targets:return at
   self.m.call('run_until_mem_change',addrs=[23621,23622],max_steps=200000)
  raise AssertionError(('boundary',targets,line(self.m),self.m.screen()))
 def event(self,key,down):
  if not key:return
  if key.isupper():self.m.call('input',events=[{'Key':{'name':'caps','pressed':down}}])
  self.m.call('input',events=[{'Key':{'name':key.lower(),'pressed':down}}])
 def advance_frames(self,count):
  # CPU debug stepping and run_frames do not share a clock in this binary.
  # Advance against the ROM interrupt counter; never write emulator state.
  for _ in range(count):
   self.m.call('run_until_mem_change',addrs=[23672],max_steps=200000)
 def capture(self,name):
  self.advance_frames(2)
  self.m.frames(0)
  self.m.call('save_screenshot',path=str(self.out/(name+'.png')))
 def invariant(self,s):
  cells=beam(int(s['gx']),int(s['gy']),int(s['gd']))
  assert all((s['v$'][32*y+x-1]=='!')==((x,y) in cells) for y in range(1,19) for x in range(1,31))
  assert s['bn']==len(cells);assert MAP[int(s['y'])-1][int(s['x'])-1]==' '
  assert 'scroll?' not in ''.join(self.m.screen()).lower()
 def stamp(self):return int.from_bytes(bytes(self.m.call('memory_read',addr=23672,len=3)['bytes']),'little')
 def tick(self,key=''):
  started=self.stamp()
  self.boundary({250});before=state(self.m);expected,result=advance(unpack(before),key)
  self.event(key,True);self.m.frames(0);self.boundary({260});self.event(key,False);self.m.frames(0)
  self.boundary({470,4000});after=state(self.m)
  assert unpack(after)==expected,(key,unpack(before),unpack(after),expected,result)
  assert after['outcome']==result and (line(self.m)==4000)==bool(result)
  assert after['steps']==before['steps']+int(expected[:2]!=unpack(before)[:2]);self.invariant(after)
  self.trace.append(dict(key=key,before=unpack(before),after=unpack(after),result=result,frames=(self.stamp()-started)%(1<<24)))
  self.boundary({8010} if result else {200});return after,result
 def reset(self):
  self.event('r',True);self.m.frames(0);self.boundary({8100,8020});self.event('r',False);self.m.frames(0)
  self.boundary({100});self.boundary({200});s=state(self.m);assert unpack(s)==START and s['steps']==0 and s['outcome']==0;self.invariant(s);return s
 def walk(self,path):
  for key in path:s,result=self.tick(key)
  return s,result
 def execute(self):
  model=audit();self.record('independent-model-connected-map-and-safe-round-trip')
  self.m.call('load_media',slot='tape-1',kind='tape',path=str(self.out/'night-patrol.tap'));self.m.statement('LOAD ""');self.m.call('media_transport',slot='tape-1',transport='start');self.boundary({8010})
  assert any('S starts.' in r for r in self.m.screen());assert self.m.program_lines()=={int(k):v for k,v in json.loads((self.out/'stored.json').read_text()).items()};self.capture('instructions');self.record('fresh-tape-title-and-stored-source-identity')
  self.event('x',True);self.m.frames(0);self.boundary({8020});self.event('x',False);self.m.frames(0);self.boundary({8010});assert any('S starts.' in r for r in self.m.screen());self.record('invalid-title-key')
  self.event('s',True);self.m.frames(0);self.boundary({8020});self.event('s',False);self.m.frames(0);self.boundary({200});s=state(self.m);assert unpack(s)==START;self.invariant(s);self.capture('archive');self.record('large-map-safe-start-and-visible-ray')
  s,result=self.tick('x');assert s['x']==3 and s['y']==16 and not result;self.tick('L');self.tick('j');s,result=self.tick('j');assert s['x']==3;self.record('invalid-key-uppercase-movement-and-wall-blocking')
  s,result=self.tick('k');assert s['y']==16;self.record('closed-bottom-boundary')
  self.reset();directions=set();scans=set()
  for _ in range(122):
   before=unpack(state(self.m));s,result=self.tick();assert not result and s['x']==3 and s['y']==16;directions.add(s['gd'])
   if unpack(s)[2:4]==before[2:4] and s['gd']!=before[4]:scans.add((int(s['gx']),int(s['gy']),int(s['gd'])))
  assert scans=={(24,5,3),(24,5,2),(24,14,4),(24,14,3),(7,14,1),(7,14,4),(7,5,2),(7,5,1)}
  self.record('all-four-corners-look-back-then-check-next-corridor')
  assert directions=={1,2,3,4};self.record('patrol-moves-without-input-and-turns-all-four-corners')
  self.reset();path=route();print('WIN ROUTE',len(path),'beats',flush=True)
  picked=False
  for key in path:
   s,result=self.tick(key)
   if s['got'] and not picked:picked=True;self.capture('file-taken');self.record('file-pickup-and-return-objective')
  assert result==2 and picked;self.capture('escaped');self.record('ordinary-key-round-trip-agrees-with-model')
  before=unpack(s);self.advance_frames(150);assert unpack(state(self.m))==before;self.record('escape-freezes-patrol')
  self.reset();self.record('retry-restores-file-player-patrol-and-vision')
  # Reach cover through ordinary controls: a pillar blocks the west-facing ray.
  path=route(goal=lambda s:s[:2]==(9,9) and s[2:5]==(7,12,4))
  s,result=self.walk(path);assert not result and (9,9) not in beam(*s_guard(s));self.capture('cover');self.record('wall-occlusion-protects-player-in-line-with-guard')
  self.reset()
  path=route(goal=lambda s:any(advance(s,k)[1]==1 for k in ('i','j','k','l')))
  s,result=self.walk(path)
  key=next(k for k in ('i','j','k','l') if advance(unpack(s),k)[1]==1)
  s,result=self.tick(key);assert result==1;self.capture('spotted');self.record('entering-danger-is-caught')
  before=unpack(s);self.advance_frames(150);assert unpack(state(self.m))==before;self.record('caught-freezes-patrol')
  self.reset()
  path=route(goal=lambda s:advance(s,'')[1]==1)
  s,result=self.walk(path);s,result=self.tick();assert result==1;self.record('moving-sightline-catches-stationary-player')
  self.reset()
  def scan_catches(s):
   after,result=advance(s,'')
   return result==1 and after[2:4]==s[2:4] and after[4]!=s[4]
  s,result=self.walk(route(goal=scan_catches));before=unpack(s);s,result=self.tick()
  assert result==1 and unpack(s)[2:4]==before[2:4] and s['gd']!=before[4]
  self.capture('corner-scan-capture');self.record('stationary-corner-scan-catches-player-behind-guard')
  self.event('q',True);self.m.frames(0);self.boundary({9000});self.event('q',False);self.m.frames(0);self.advance_frames(50);assert any('9 STOP statement' in r for r in self.m.screen());self.record('quit-to-basic')
  (self.out/'results.json').write_text(json.dumps(dict(source_sha256=sha(ROOT/'night-patrol.bas'),tape_sha256=sha(self.out/'night-patrol.tap'),binary_sha256=sha(Path(self.exe)),server=self.m.server,configuration='Stock 48K PAL; fresh ROM tape; ordinary key events; read-only BASIC state',direct_memory_writes=False,checks=self.checks,model=model,trace=self.trace),indent=2)+'\n')
def s_guard(s):return int(s['gx']),int(s['gy']),int(s['gd'])
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
 try:r.execute()
 except Exception:
  (r.out/'failure.json').write_text(json.dumps(dict(line=line(r.m),screen=r.m.screen(),checks=r.checks,trace=r.trace[-3:]),indent=2)+'\n');raise
 finally:r.m.close()
