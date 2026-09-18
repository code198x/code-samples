"""Fresh-ROM checks of intermediate cave programs, driven only by keys."""
import argparse,concurrent.futures,hashlib,json,sys
from pathlib import Path
from collections import deque
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from model import rooms,PATROL,TREASURES
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import state,line
NAMES=['room','map','walk','treasure','pit','patrol','expedition']
def check(item,exe,out):
 name=item['name'];level=NAMES.index(name);out=out/name;m=Spectrum(exe,out);checks=[];actions=[];sampling=[]
 def record(s):checks.append(s);print('PASS',name,s,flush=True)
 def wait(targets):
  retries=0
  for _ in range(2500):
   if line(m) in targets:
    try:return state(m)
    except AssertionError as error:
     # PPC identifies the BASIC line, not a boundary within its ROM string
     # assignment. A frame can stop during variable-table relocation.
     retries+=1
     if retries>8:raise
     sampling.append({'line':line(m),'reader_error':str(error),'resume_frames':1})
     m.frames(1)
     continue
   m.frames(5)
  raise AssertionError((name,targets,line(m),m.screen()))
 def stopped():
  for _ in range(500):
   if any('9 STOP statement' in s for s in m.screen()):return
   m.frames(5)
  raise AssertionError(m.screen())
 def key(k):m.key('space' if k==' ' else k);m.frames(10)
 def ready():return wait([310,5090])
 def capture(label):m.frames(10);m.call('save_screenshot',path=str(out/(label+'.png')))
 def reset():key('r');s=ready();assert s['rm']==1 and s['turns']==0;return s
 def move(k):
  before=ready();room=before['rm'];dest=room if k==' ' else rooms[room]['exits']['nsew'.index(k)]
  turns=before['turns'];t=before.get('t',[]).copy();found=before.get('found',0);ci=before.get('ci',3);event='move'
  if not dest:dest=room;event='wall'
  else:
   turns+=1
   if level>=4 and dest==7:event='pit'
   elif level>=5 and dest==PATROL[ci-1]:event='caught'
   else:
    if level>=3 and t[dest-1]:t[dest-1]=0;found+=1
    if level>=6 and dest==1 and found==3:event='win'
    elif level>=5:ci=ci%8+1;event='arrival' if PATROL[ci-1]==dest else 'move'
  key(k);s=ready();assert s['rm']==dest and s['turns']==turns,(name,k,event,s)
  if level>=3:assert s['t']==t and s['found']==found
  if level>=5:assert s['ci']==ci and s['cr']==PATROL[ci-1]
  if event in ('pit','caught','win'):assert s['ending']=={'pit':1,'caught':2,'win':3}[event]
  else:
   screen=m.screen();assert rooms[dest]['name'] in screen[5]
   for j,v in enumerate(rooms[dest]['exits']):
    text=screen[j+11];assert ('Open' if v else '--') in text
    if not v:continue
    if level>=4 and v==7:assert 'Cold draught' in text
    if level>=5 and v==PATROL[ci-1]:assert 'Footsteps' in text or 'Steps + glint' in text
    if level>=3:assert ('glint' in text.lower())==bool(t[v-1])
    if level>=5:assert ('Footsteps' in text or 'Steps + glint' in text)==(v==PATROL[ci-1])
   if event=='arrival':assert 'IT IS HERE' in screen[16]
  actions.append({'key':k,'room':dest,'turns':turns,'event':event});return s
 try:
  m.call('load_media',slot='tape-1',kind='tape',path=str(out/'caverns.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start')
  if level<2:stopped()
  else:ready()
  assert 'The entrance' in m.screen()[5];capture('entrance');record('fresh-tape-room-display')
  assert m.program_lines()=={int(k):v for k,v in json.loads((out/'stored.json').read_text()).items()};record('stored-token-identity')
  if level>=1:assert state(m)['m']==[v for r in rooms.values() for v in r['exits']];record('all-room-links-loaded')
  if level>=2:
   for k in ['a','0','enter']:key(k);assert ready()['turns']==0
   move('n');assert ready()['turns']==0;record('ignored-keys-and-wall-cost-no-turn')
   reset();m.call('input',events=[{'Key':{'name':'s','pressed':True}}]);m.frames(500);assert state(m)['turns']==1 and state(m)['rm']==5
   m.call('input',events=[{'Key':{'name':'s','pressed':False}}]);m.frames(15);ready();record('held-direction-one-move')
   reset();move(' ');assert ready()['turns']==1;record('wait-counts-turn')
   reset();m.key('caps','e');s=ready();assert s['rm']==2 and s['turns']==1;record('uppercase-direction')
   if level==2:
    # Visit all rooms by legal shortest paths, including the not-yet-dangerous shaft.
    for target in rooms:
     reset();q=deque([(1,'')]);seen={1}
     while q:
      room,path=q.popleft()
      if room==target:break
      for j,nxt in enumerate(rooms[room]['exits']):
       if nxt and nxt not in seen:seen.add(nxt);q.append((nxt,path+'nsew'[j]))
     for k in path:move(k)
     assert ready()['rm']==target
    capture('exploration');record('all-twelve-rooms-reached-by-keys')
   if level>=3:
    reset()
    for k in 'se':move(k)
    assert ready()['found']==1;capture('treasure')
    for k in 'we':move(k)
    assert ready()['found']==1;record('treasure-collected-once-and-clue-cleared')
   if level>=4:
    reset()
    for k in 'see':move(k)
    assert ready()['ending']==1;capture('pit');before=ready();key('n');assert ready()['turns']==before['turns'];record('pit-and-stable-result')
   if level>=5:
    reset()
    for k in 'sse ':move(k)
    capture('arrival');assert ready()['rm']==ready()['cr'];before=ready()
    key('a');assert ready()['turns']==before['turns'];move('s');assert ready()['turns']==before['turns'];record('arrival-invalid-and-wall-preserve-escape-turn')
    move('w');assert ready()['rm']!=ready()['cr'];capture('escape');record('arrival-escape')
    reset()
    for k in 'sse n':move(k)
    assert ready()['rm']==6 and ready()['cr']==6 and ready()['found']==2;record('north-escape-can-receive-another-arrival')
    move('w');assert ready()['rm']==5 and ready()['cr']==2;record('escape-after-second-arrival')
    reset()
    for k in 'sse  ':move(k)
    assert ready()['ending']==2;record('waiting-after-arrival-is-caught')
    reset()
    for k in 'ssee':move(k)
    assert ready()['ending']==2;record('entering-warned-creature-is-caught')
   if level>=3:
    reset()
    for k in 'eeesswwnn':move(k)
    assert ready()['found']==3 and ready()['rm']==2 and line(m)==310;capture('three-found');record('third-treasure-does-not-end-expedition')
    move('w');assert ready()['rm']==1
    if level>=6:assert ready()['ending']==3 and line(m)==5090
    else:assert line(m)==310
    capture('return');record('return-rule-present-only-in-expedition')
   reset();s=ready();assert s.get('found',0)==0
   if level>=3:assert sum(s['t'])==3
   if level>=5:assert s['ci']==3 and s['cr']==4
   record('reset-restores-state');key('q');stopped();record('quit')
  (out/'results.json').write_text(json.dumps({'name':name,'source_sha256':hashlib.sha256((ROOT/item['source']).read_bytes()).hexdigest(),'checks':checks,'actions':actions,'configuration':'Stock 48K PAL, fresh tape load and ordinary keys','direct_memory_writes':False,'sampling_retries':sampling},indent=2)+'\n')
 except Exception:
  diagnostic={'screen':m.screen(),'line':line(m),'pointers':m.call('memory_read',addr=23627,len=16)['bytes']}
  address=diagnostic['pointers'][0]+256*diagnostic['pointers'][1]
  diagnostic['variables']=sum([m.call('memory_read',addr=address+offset,len=128)['bytes'] for offset in range(0,2048,128)],[])
  m.frames(1)
  try:diagnostic['after_one_frame']=state(m)
  except AssertionError as error:diagnostic['after_one_frame_error']=str(error)
  (out/'failure.json').write_text(json.dumps(diagnostic,indent=2)+'\n')
  raise
 finally:m.close()
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only');p.add_argument('--jobs',type=int,default=1);a=p.parse_args()
 items=[i for i in json.loads((ROOT/'checkpoints.json').read_text()) if i['name']!='finished' and (not a.only or i['name']==a.only)]
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:list(pool.map(lambda i:check(i,a.emulator,a.output.resolve()),items))
