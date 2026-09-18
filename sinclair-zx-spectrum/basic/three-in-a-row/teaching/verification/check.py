"""Fresh tape checks of teaching stages, using keys and read-only observations."""
import argparse, concurrent.futures, hashlib, json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from model import choose,result,LINES
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line

def check(item,exe,out):
 name=item['name'];out=out/name;m=Spectrum(exe,out);checks=[]
 def record(s):checks.append(s);print('PASS',name,s,flush=True)
 def wait(targets):
  for _ in range(2500):
   if line(m) in targets:return state(m)
   m.frames(5)
  raise AssertionError((name,targets,line(m),m.screen()))
 def stopped():
  for _ in range(500):
   if any('9 STOP statement' in s for s in m.screen()):return
   m.frames(5)
  raise AssertionError(m.screen())
 def key(k):m.key(k);m.frames(10)
 def ready():return wait([260,5010])
 def capture(label):m.frames(10);m.call('save_screenshot',path=str(out/(label+'.png')))
 def reset():key('r');return ready()
 try:
  m.call('load_media',slot='tape-1',kind='tape',path=str(out/'three.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start')
  if name=='board':
   stopped();assert state(m)['b']==[0]*9
   capture('board');record('fresh-tape-numbered-board-stop')
  else:
   s=ready();assert s['b']==[0]*9;capture('board');record('fresh-tape-empty-board')
  assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};record('stored-line-identity')
  if name!='board':
   for k in ['0','a','enter','space']:key(k);assert ready()['b']==[0]*9
   record('invalid-keys')
   m.call('input',events=[{'Key':{'name':'1','pressed':True}}]);m.frames(400)
   expected=[1]+[0]*8
   if name in ('reply','tactics'):expected[1]=2
   if name=='policy':expected[4]=2
   assert state(m)['b']==expected
   m.call('input',events=[{'Key':{'name':'1','pressed':False}}]);m.frames(15);ready();record('held-key-places-once')
   key('1');assert ready()['b']==expected;assert 'Taken.' in m.screen()[18];record('occupied-key')
   reset();assert ready()['b']==[0]*9;record('reset')
   if name=='place':
    for n in range(1,10):key(str(n));assert ready()['b'][n-1]==1
    capture('marks');record('nine-crosses')
   elif name in ('turns','results'):
    seq=(1,4,2,5,3) if name=='results' else (1,2,3,4,5,6,7,8,9)
    for i,n in enumerate(seq):key(str(n));assert ready()['b'][n-1]==1+i%2
    if name=='results':assert ready()['winner']==1 and ready()['wl']==1
    else:assert ready()['moves']==9
    capture('result');before=ready()['b'];key('9');assert ready()['b']==before;record('alternating-turns-and-stable-ending')
    reset()
    for n in (1,2,3,5,4,6,8,7,9):key(str(n));ready()
    assert ready()['moves']==9
    if name=='results':assert ready()['winner']==0
    capture('draw');record('full-board-draw-or-practice-stop')
   else:
    seq={'reply':(1,5,9),'tactics':(1,5,7),'policy':(1,8,7,4)}[name]
    b=[0]*9
    for n in seq:
     assert b[n-1]==0;b[n-1]=1
     if not result(b)[0] and not all(b):
      if name=='policy':mv,reason=choose(b)
      else:
       mv=0;reason='first empty'
       if name=='tactics':
        for mark,label in ((2,'win'),(1,'block')):
         for triple in LINES:
          vals=[b[i-1] for i in triple]
          if vals.count(mark)==2 and vals.count(0)==1:mv=triple[vals.index(0)];reason=label;break
         if mv:break
       if not mv:mv=b.index(0)+1
      b[mv-1]=2
     else:mv=None
     key(str(n));s=ready();assert s['b']==b,(name,n,b,s)
     assert (s['winner'],s['wl'])==result(b)
     if mv:assert s['mv']==mv and s['a$']==reason
    capture('result');record('legal-opponent-path-reasons-and-result')
   if name=='tactics':
    reset()
    for n,mv,reason in ((1,2,'first empty'),(3,4,'first empty'),(7,5,'block'),(6,8,'win')):
     key(str(n));s=ready();assert s['mv']==mv and s['a$']==reason
    assert s['winner']==2;record('lesson-winning-trace-prioritises-win-over-block')
   if name=='policy':
    reset();key('5');s=ready();assert s['mv']==1 and s['a$']=='corner';record('lesson-centre-opening-corner-response')
   key('q');stopped();record('quit')
  if name in ('results','reply','tactics','policy'):
   for mark in (1,2):
    for w,triple in enumerate(LINES,1):
     m.statement('DIM b(9)')
     for n in triple:m.statement(f'LET b({n}) = {mark}')
     m.statement('GO SUB 3000');s=state(m);assert s['winner']==mark and s['wl']==w
   record('sixteen-explicit-ROM-diagnostic-winning-lines')
   if name=='results':
    m.statement('DIM b(9)')
    for n in range(1,10):m.statement(f'LET b({n}) = {1 if n in (1,3,5,6,9) else 2}')
    m.statement('LET moves = 9: GO SUB 3000: GO TO 4900');ready()
    assert 'X WINS' in m.screen()[18];record('ROM-diagnostic-last-cell-win-before-draw')
    key('q');stopped()
  if name in ('tactics','policy'):
   # O can win at 6 while X threatens 3: choosing 6 proves rule priority.
   m.statement('DIM b(9)')
   for n,mark in ((1,1),(2,1),(4,2),(5,2)):m.statement(f'LET b({n}) = {mark}')
   m.statement('GO SUB 4000');s=state(m);assert s['mv']==6 and s['a$']=='win';record('ROM-diagnostic-win-before-block')
  (out/'results.json').write_text(json.dumps({'name':name,'source_sha256':hashlib.sha256((ROOT/item['source']).read_bytes()).hexdigest(),'checks':checks,'configuration':'48K PAL; fresh tape load; ordinary key play','direct_memory_writes':False,'diagnostics':'Winning-line and priority fixtures entered as ordinary DIM/LET after STOP; not public captures.'},indent=2)+'\n')
 finally:m.close()
 return checks
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');p.add_argument('--jobs',type=int,default=1);a=p.parse_args()
 items=[i for i in json.loads((ROOT/'checkpoints.json').read_text()) if i['name']!='finished' and (not a.only or i['name']==a.only)]
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:list(pool.map(lambda i:check(i,a.emulator,a.output.resolve()),items))
