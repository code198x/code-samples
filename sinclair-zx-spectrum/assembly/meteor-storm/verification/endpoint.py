"""Endpoint regression: ordinary frames and keyboard, no game-state writes."""
import argparse,hashlib,importlib.util,json,re,subprocess,sys
from pathlib import Path
PROJECT=Path(__file__).resolve().parents[1]
donor=PROJECT.parents[1]/'basic/meet-basic/opening/verification/verify.py'
spec=importlib.util.spec_from_file_location('spectrum_transport',donor);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)

def main():
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True)
 # Later checkpoints keep the finished game's rules, so the same regression applies.
 p.add_argument('--checkpoint',default='finished',choices=['finished','tone','sound-table','sound-frames','debris','colour-bands']);a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=True)
 ROOT=PROJECT/'checkpoints'/a.checkpoint
 for flag,ext in [('--sna','sna'),('--tapbas','tap')]:subprocess.run(['asm198x','--dialect','pasmonext','--cpu','z80',flag,'--sym='+str(out/'meteor-storm.sym'),str(ROOT/'meteor-storm.asm'),'-o',str(out/('meteor-storm.'+ext))],check=True,cwd=ROOT)
 symbols={m[1]:int(m[2],16) for line in (out/'meteor-storm.sym').read_text().splitlines() if (m:=re.match(r'(\w+) = \$(\w+)',line))}
 m=module.Spectrum(a.emulator,out);checks=[];events=[]
 def state():
  data=m.call('memory_read',addr=symbols['state_start'],len=symbols['state_end']-symbols['state_start'])['bytes'];v={name:data[addr-symbols['state_start']] for name,addr in symbols.items() if symbols['state_start']<=addr<symbols['state_end']};v['ticks']+=256*data[symbols['ticks']-symbols['state_start']+1];v['elapsed']+=256*data[symbols['elapsed']-symbols['state_start']+1];v['objects']=[data[i:i+7] for i in range(symbols['objects']-symbols['state_start'],len(data),7)];return v
 def check(name,truth,detail=None):
  assert truth,(name,detail);checks.append({'check':name,'detail':detail});print('PASS',name,flush=True)
 def key(name,down):m.call('input',events=[{'Key':{'name':name,'pressed':down}}])
 def start():
  m.call('load_snapshot',path=str(out/'meteor-storm.sna'));m.frames(30);m.call('press_key',key='space',hold_frames=6);m.frames(12);check('start enters flight',state()['phase']==1,state()['phase'])
 try:
  m.call('load_snapshot',path=str(out/'meteor-storm.sna'));m.frames(60)
  title_lines={3:'METEOR STORM',6:'DODGE ROCKS. ONE HIT ENDS IT',10:'O LEFT       P RIGHT',13:'HOLD SPACE: DOUBLE SPEED',15:'STARS: 10 / BOOST: 20',17:'FASTER FINISH = MORE POINTS',20:'SPACE TO LAUNCH'}
  font=[]
  for addr in range(0x3d00,0x4000,256):font+=m.call('memory_read',addr=addr,len=256)['bytes']
  for row,line in title_lines.items():
   assert len(line)<=32
   for scan in range(8):
    y=row*8+scan;addr=0x4000|((y&0xc0)<<5)|((y&7)<<8)|((y&0x38)<<2)
    actual=m.call('memory_read',addr=addr,len=32)['bytes'];expected=[0]*32
    for col,char in enumerate(line,(32-len(line))//2):expected[col]=font[(ord(char)-32)*8+scan]
    assert actual==expected,('title layout',row,scan)
  check('every title line is centred without wrapping',True)
  m.call('save_screenshot',path=str(out/'title.png'))
  start();m.call('save_screenshot',path=str(out/'opening.png'))
  t=state()['ticks'];key('Space',True);m.frames(12);fast_delta=state()['ticks']-t
  t=state()['ticks'];key('Space',False);m.frames(12);slow_delta=state()['ticks']-t
  check('releasing boost restores normal speed',fast_delta>=1.7*slow_delta and state()['boost_time']==0,{'boost_steps':fast_delta,'normal_steps':slow_delta})
  start();m.call('press_keys',keys=['o','p'],hold_frames=30);check('opposing controls cancel',state()['ship_x']==116)
  m.call('press_key',key='q',hold_frames=3);m.frames(3);check('quit returns to title',state()['phase']==0)
  key('Space',True);m.frames(40);check('held launch waits for release',state()['phase']==0);key('Space',False);m.frames(4);check('release starts one flight',state()['phase']==1)
  # A full idle run exercises ordinary impacts and a terminal failure.
  m.call('clear_audio_capture');before=state()['hull'];hits=[]
  for frame in range(2200):
   m.frames(1);s=state()
   if s['hull']<before:hits.append({'frame':frame,'hull':s['hull']});before=s['hull']
   if s['phase']==2:break
  check('idle flight is destroyed',s['phase']==2 and s['hull']==0,hits)
  check('one contact spends the one life',[h['hull'] for h in hits]==[0])
  check('first impact ends the run',len(hits)==1 and s['phase']==2)
  if 'debris_time' in symbols:
   # From debris on, phase 2 begins with about a second of debris before the
   # result screen, so the lost path waits for it instead of assuming the result.
   start_frame=m.call('memory_read',addr=symbols['frames'],len=1)['bytes'][0];m.frames(1)
   while state()['debris_time']:m.frames(1)
   destroyed_frames=(m.call('memory_read',addr=symbols['frames'],len=1)['bytes'][0]-start_frame)&255
   check('debris plays before the result',46<=destroyed_frames<=52 and state()['phase']==2,{'frames':destroyed_frames})
   # The next run's elapsed count starts on the frame new_game finishes, so
   # the retry below must land on the same frame parity as the recorded runs
   # (an odd frame count): one frame later measures the course a frame shorter.
   while m.call('memory_read',addr=symbols['frames'],len=1)['bytes'][0]%2==0:m.frames(1)
  m.call('save_audio_capture',path=str(out/'impacts.wav'));m.frames(20);m.call('save_screenshot',path=str(out/'destroyed.png'));frozen=state()['ticks'];m.frames(40);check('result freezes simulation',state()['ticks']==frozen)
  m.call('press_key',key='r',hold_frames=3);m.frames(4);s=state();check('retry restores flight',s['phase']==1 and s['hull']==1 and s['wave']==0 and s['ship_x']==116 and s['score']==0)
  # Keyboard-only feedback pilot, at frame boundaries. State reads choose input;
  # no writes stage a win. Follow the gap in the lowest active meteor row.
  def pilot(boosted):
   positions=json.loads((PROJECT/'prototype/verification/model-results.json').read_text())['positions']
   key('Space',boosted)
   max_pool=0;last=None;frame=0;min_hull=1;route=[];periods=set();previous_score=0;score_steps=[];tracked={};last_y={};vertical_samples=0;drift_samples=0
   while frame<2600:
    s=state();min_hull=min(min_hull,s['hull']);max_pool=max(max_pool,s['active_count']);periods.add(s['frame_delta'])
    for slot,o in enumerate(s['objects']):
     if not o[2]:tracked.pop(slot,None);continue
     old=tracked.get(slot)
     if old and o[2]==old[2] and o[1]>=last_y.get(slot,255) and o[3]==old[3]:
      if o[2]==2:
       assert o[0]==old[0],('star drifted',old,o)
       vertical_samples+=1
      else:
       age=(o[1]-old[1])//o[3]
       assert abs(o[0]-old[0])<=(age+3)//4+1,('excessive drift',old,o)
       drift_samples+=1
     else:tracked[slot]=o
     last_y[slot]=o[1]
    if s['score']!=previous_score and s['phase']==1:
     score_steps.append(s['score']-previous_score);previous_score=s['score']
    if s['phase']!=1:break
    target=positions[min(s['ticks']+1,len(positions)-1)]
    action='P' if target>s['ship_x'] else 'O' if target<s['ship_x'] else None
    if action!=last:
     if last:key(last,False)
     if action:key(action,True)
     route.append({'frame':frame,'action':action});last=action
    m.frames(1);frame+=1
    if frame in [140,400,800]:m.call('save_screenshot',path=str(out/f'{"boost" if boosted else "normal"}-flight-{frame}.png'))
   if last:key(last,False)
   key('Space',False)
   check('keyboard route reaches clear space',s['phase']==3,{'frames':frame,'ticks':s['ticks'],'wave':s['wave'],'hull':s['hull']})
   check('complete route takes no damage',min_hull==1,min_hull)
   check('stars fall vertically',vertical_samples>0,vertical_samples)
   check('meteor drift stays gentle',drift_samples>0,drift_samples)
   check('stars award points without damage',0<s['score']<=140,s['score']*10)
   check('pickup value follows speed',score_steps and all(n==(2 if boosted else 1) for n in score_steps),score_steps)
   check('finish bonus rewards elapsed time',s['finish_points']==max(0,100-s['elapsed']//50) and s['score']==sum(score_steps)+s['finish_points'],{'pickup_units':sum(score_steps),'bonus_units':s['finish_points']})
   final_score=s['score'];m.frames(30);check('result preserves score',state()['score']==final_score)
   # Inspect the actual bitmap, not only numeric state behind the HUD.
   expected_line='SCORE '+str(final_score*10).zfill(4)
   for scan in range(8):
    y=16+scan;addr=0x4000|((y&0xc0)<<5)|((y&7)<<8)|((y&0x38)<<2)
    actual=m.call('memory_read',addr=addr+1,len=len(expected_line))['bytes']
    expected=[font[(ord(char)-32)*8+scan] for char in expected_line]
    assert actual==expected,('result score bitmap',scan,actual,expected)
   check('result displays complete score line',True)
   check('all hazards pass before arrival',s['wave']==120 and s['active_count']==0)
   check('updates keep a two-frame cadence',periods<={0,1,2},sorted(periods))
   check('object pool remains bounded',max_pool<=20 and s['pool_overflow']==0,max_pool)
   m.frames(20);m.frames(1);m.frames(1);m.call('save_screenshot',path=str(out/('boost-result.png' if boosted else 'normal-result.png')));(out/'route.json').write_text(json.dumps(route,indent=2)+'\n')
   return s
  def records_state():
   v=m.call('memory_read',addr=symbols['best_time'],len=3)['bytes'];return v[0]+256*v[1],v[2]
  normal=pilot(False)
  check('normal finish establishes both records',records_state()==(normal['elapsed'],normal['score']),records_state())
  m.call('press_key',key='r',hold_frames=3);m.frames(4)
  check('retry keeps records',records_state()==(normal['elapsed'],normal['score']))
  boosted=pilot(True)
  check('unlimited boost finishes sooner',boosted['elapsed']<normal['elapsed']*0.6,{'normal_frames':normal['elapsed'],'boost_frames':boosted['elapsed']})
  check('faster finish earns more points',boosted['score']>normal['score'],{'normal_points':normal['score']*10,'boost_points':boosted['score']*10})
  check('fast finish improves best time',records_state()[0]==boosted['elapsed'])
  check('best score retains highest run',records_state()[1]==max(normal['score'],boosted['score']))
  m.call('press_key',key='r',hold_frames=3);m.frames(4);m.frames(1500)
  check('failed run cannot replace best time',state()['phase']==2 and records_state()[0]==boosted['elapsed'])
  check('failed run preserves best score',records_state()[1]>=boosted['score'])
  # Fresh machine and ROM keyboard LOAD of the actual tape, rather than a snapshot.
  m.close();m=module.Spectrum(a.emulator,out)
  m.call('load_media',slot='tape-1',kind='tape',path=str(out/'meteor-storm.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');m.frames(7000)
  check('fresh tape loads exact program',m.call('memory_read',addr=32768,len=3)['bytes']==list((out/'meteor-storm.sna').read_bytes()[27+32768-16384:30+32768-16384]))
  check('fresh tape reaches title',state()['phase']==0)
  m.call('press_key',key='space',hold_frames=3);m.frames(8);check('tape-loaded game starts',state()['phase']==1 and state()['hull']==1)
  m.call('save_screenshot',path=str(out/'tape-flight.png'))
  report={'checkpoint':a.checkpoint,'method':'Ordinary emulator frames, keyboard input, read-only game-state probes; snapshot checks plus separate fresh tape load. No debug stepping or state writes.','target':'spectrum_48k PAL','emulator_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'source_sha256':hashlib.sha256((ROOT/'meteor-storm.asm').read_bytes()).hexdigest(),'tape_sha256':hashlib.sha256((out/'meteor-storm.tap').read_bytes()).hexdigest(),'checks':checks}
  version=subprocess.run(['asm198x','--version'],capture_output=True,text=True)
  report['assembler_version']=(version.stdout+version.stderr).strip()
  report['assets_sha256']=hashlib.sha256((ROOT/'assets.inc').read_bytes()).hexdigest()
  rom=Path.home()/'.emu198x/roms/sinclair-zx-spectrum-48k/48.rom'
  report['rom_sha256']=hashlib.sha256(rom.read_bytes()).hexdigest()
  baseline=json.loads((PROJECT/'prototype/verification/evidence/results.json').read_text())
  compared=['keyboard route reaches clear space','finish bonus rewards elapsed time','normal finish establishes both records','unlimited boost finishes sooner','faster finish earns more points']
  reference=[c for c in baseline['checks'] if c['check'] in compared]
  actual=[c for c in checks if c['check'] in compared]
  check('accepted gameplay measurements match',json.loads(json.dumps(actual))==reference,actual)
  report['accepted_source_sha256']=baseline['source_sha256']
  (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
 finally:m.close()
if __name__=='__main__':main()
