#!/usr/bin/env python3
"""Check held-key and repeated-key cue counts from a freshly loaded prototype."""
import argparse,json,wave,struct,math
from pathlib import Path
from verify import Spectrum
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--emulator',required=True);p.add_argument('--tape',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output)
def bursts(path):
 with wave.open(str(path)) as w:
  sr=w.getframerate();v=struct.unpack('<'+'h'*w.getnframes(),w.readframes(w.getnframes()))
 width=sr//100;active=[]
 for i in range(0,len(v),width):
  b=v[i:i+width];active.append(math.sqrt(sum(x*x for x in b)/len(b))>5000)
 groups=[]
 for i,on in enumerate(active):
  if on and (i==0 or not active[i-1]):groups.append([i,i+1])
  elif on:groups[-1][1]=i+1
 return [{'start':s*.01,'end':e*.01} for s,e in groups if e-s>=5]
try:
 m.call('load_media',slot='tape-1',kind='tape',path=a.tape);m.statement('LOAD "spark"');m.call('media_transport',slot='tape-1',transport='start');m.frames(2800);m.statement('RUN');m.frames(180)
 for key in '1234':m.cue(key)
 result=[]
 for label,count in [('held',1),('released-and-pressed-again',2)]:
  out=a.output/(label+'.wav');m.call('start_audio_recording',path=str(out))
  if label=='held':m.call('press_key',key='2',hold_frames=150);m.frames(15)
  else:
   for _ in range(2):m.call('press_key',key='2',hold_frames=3);m.frames(65)
  m.call('stop_audio_recording');observed=bursts(out);assert len(observed)==count,(label,observed);m.labels();assert not m.stars();result.append({'case':label,'expected_cues':count,'observed_tone_bursts':observed})
 m.key('q');m.check('quit-after-input-tests',['9 STOP'],capture=False)
 (a.output/'input-audio.json').write_text(json.dumps({'status':'passed','method':'RMS over 10 ms windows in emulated 16-bit mono audio; sustained bursts above 5000 RMS lasting at least 50 ms. This counts notes, not subjective listening.','checks':result},indent=2)+'\n')
finally:m.close()
