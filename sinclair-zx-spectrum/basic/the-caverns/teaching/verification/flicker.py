#!/usr/bin/env python3
"""Watch every frame of each turn: `steady` must never blank a line that stays.

Plays the same key sequence on two fresh-tape programs: `finished`, which
redraws with CLS, and `steady`, which overprints. During each turn it samples
the screen text after every frame. A flash frame is one in which a row holding
text both before and after the turn is entirely blank. `finished` must show
flash frames on every turn that redraws (the control: the check can fail);
`steady` must show none. After each action both programs must also hold
the same colour at every pixel, so overprinting leaves
nothing stale and every message, warning and ending looks the same.

Display memory is sampled once per frame, not at the moment the beam passes a
line; a change and its reversal inside one frame could go unseen. All actions
are ordinary keys; memory is read-only.

The lesson's mid-turn pictures come from the first move: `mid-turn-finished.png`
is the frame of that turn with the most blank rows, `mid-turn-steady.png` the
same frame number of the same turn in `steady`.
"""
import argparse,hashlib,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
sys.path.insert(0,str(ROOT.parents[1]/'tail-chase/prototype/verification'))
from verify import line
READY=(310,5090)

def play(exe,tape,out,script,shot,pick=None):
 # shot: (action index, file name); pick: the frame to save, or None for the frame with most blank rows.
 m=Spectrum(exe,out);actions=[]
 def text():return [r.rstrip() for r in m.screen()[:22]]
 def display():
  # The colour of every pixel, from bitmap and attributes. A padding space
  # keeps its INK where CLS left the permanent one: different bytes, same picture.
  d=sum((m.call('memory_read',addr=a,len=256)['bytes'] for a in range(16384,23296,256)),[]);px=bytearray()
  for y in range(192):
   for x in range(32):
    b=d[((y&192)<<5)|((y&7)<<8)|((y&56)<<2)|x];at=d[6144+(y>>3)*32+x];ink,paper,bright=at&7,(at>>3)&7,(at>>6)&1
    px+=bytes((ink if b&(128>>i) else paper)+8*bright for i in range(8))
  return hashlib.sha256(bytes(px)).hexdigest()
 def settle(targets):
  for _ in range(3000):
   if line(m) in targets:m.frames(5);return
   m.frames(1)
  raise AssertionError((targets,line(m),m.screen()))
 def act(kind,k):
  nonlocal pick
  before=text();name='space' if k==' ' else k;frames=[];left=False;filming=len(actions)==shot[0]
  m.call('input',events=[{'Key':{'name':name,'pressed':True}}])
  for n in range(1,3000):
   m.frames(1);frames.append(text())
   if filming and pick in (None,n):m.call('save_screenshot',path=str(out/'_frames'/f'{n:03}.png'))
   if n==3:m.call('input',events=[{'Key':{'name':name,'pressed':False}}])
   at=line(m)
   if at not in READY:left=True
   if left and n>3 and at in READY:break
  else:raise AssertionError((kind,k,line(m),m.screen()))
  m.frames(5);after=text()
  kept=[r for r in range(22) if before[r].strip() and after[r].strip()]
  flashes=[{'frame':i+1,'blank_rows':blank} for i,f in enumerate(frames) if (blank:=[r for r in kept if not f[r].strip()])]
  if filming:
   pick=pick or max(flashes,key=lambda f:len(f['blank_rows']))['frame']
   (out/'_frames'/f'{pick:03}.png').replace(out/shot[1])
   for f in (out/'_frames').iterdir():f.unlink()
   (out/'_frames').rmdir()
  actions.append({'kind':kind,'key':k,'frames':len(frames),'flash_frames':len(flashes),'first_flash':flashes[0] if flashes else None,'picture_sha256':display(),'screen':after})
 try:
  (out/'_frames').mkdir(exist_ok=True)
  m.call('load_media',slot='tape-1',kind='tape',path=str(tape));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start')
  settle([110]);m.key('s');settle(READY)
  for kind,k in script:act(kind,k)
  return actions,pick
 finally:m.close()

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output.resolve()
 model=json.loads((out/'finished/model.json').read_text())
 # Walls and waits, then every worked example from the entrance: win, pit,
 # creature, arrival and escape. R between them starts a fresh expedition.
 script=[('wall','n'),('turn',' ')]
 for name,path in model['examples'].items():
  script.append(('restart','r'));script+=[('turn',k) for k in path]
 first=next(i for i,(kind,k) in enumerate(script) if kind=='turn' and k!=' ')
 old,frame=play(a.emulator,out/'finished/caverns.tap',out/'finished',script,(first,'mid-turn-finished.png'))
 new,_=play(a.emulator,out/'steady/caverns.tap',out/'steady',script,(first,'mid-turn-steady.png'),frame)
 (out/'finished/mid-turn-finished.png').replace(out/'steady/mid-turn-finished.png')
 results={'finished':old,'steady':new}
 for i,(o,s) in enumerate(zip(old,new)):
  assert o['picture_sha256']==s['picture_sha256'],(i,o['kind'],o['key'],o['screen'],s['screen'])
  if s['kind']=='turn':assert s['flash_frames']==0,(i,s)
  if o['kind']=='turn' and o['screen']!=old[i-1]['screen']:assert o['flash_frames']>0,(i,o)
 turns=[i for i,o in enumerate(old) if o['kind']=='turn']
 report={'source_sha256':{n:hashlib.sha256((ROOT/n/'caverns.bas').read_bytes()).hexdigest() for n in results},'configuration':'Stock 48K PAL; fresh ROM tape load; ordinary keys; screen text sampled after every frame','checks':['steady-turns-never-blank-a-kept-row','finished-turns-flash (control)','same-picture-after-every-action'],'turns':len(turns),'finished_flash_frames':sum(old[i]['flash_frames'] for i in turns),'steady_flash_frames':sum(new[i]['flash_frames'] for i in turns),'direct_memory_writes':False,'mid_turn_capture':{'action':first,'key':script[first][1],'frame':frame},'actions':results}
 (out/'steady/flicker.json').write_text(json.dumps(report,indent=2)+'\n')
 print('PASS',len(turns),'turns;',report['finished_flash_frames'],'flash frames in finished,',report['steady_flash_frames'],'in steady; same picture after',len(script),'actions')
