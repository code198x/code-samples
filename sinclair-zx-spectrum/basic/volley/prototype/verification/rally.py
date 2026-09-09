#!/usr/bin/env python3
"""Screen-observed automated rally; this is not human playtesting."""
import argparse,importlib.util,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
s=importlib.util.spec_from_file_location('spark',ROOT.parents[1]/'bright-spark/opening/verification/completion.py');mod=importlib.util.module_from_spec(s);s.loader.exec_module(mod)
p=argparse.ArgumentParser();p.add_argument('--paper-paddle',action='store_true');p.add_argument('--emulator',required=True);p.add_argument('--tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=mod.Spectrum(a.emulator,a.output)
def key(k,b):m.call('input',events=[{'Key':{'name':k,'pressed':b}}])
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape));m.statement('LOAD "volley"');m.call('media_transport',slot='tape-1',transport='start');m.frames(6000)
 m.statement('RUN');m.frames(60);key('s',True);m.frames(10);key('s',False)
 last=None;dx=dy=1;held=None;score=0;hits=[];moves=[];lastframe=0
 for frame in range(16000):
  m.frames(1);rows=m.screen()
  assert not any('Miss.' in r for r in rows),(frame,score,rows)
  balls=[(r,c) for r in range(3,20) for c in range(3,30) if rows[r][c]=='o']
  if a.paper_paddle:
   attrs=[]
   for offset in range(0,513,256):
    attrs+=m.call('memory_read',addr=22528+3*32+2+offset,len=min(256,513-offset))['bytes']
   paddle=[r for r in range(3,20) if ((attrs[(r-3)*32]>>3)&7)==6]
  else:paddle=[r for r in range(3,20) if rows[r][2]=='I']
  if not balls or len(paddle)!=3:continue
  y,x=balls[0]
  if last and (y,x)!=last:
   dx=1 if x>last[1] else -1
   if y!=last[0]:dy=1 if y>last[0] else -1
   moves.append(frame-lastframe);lastframe=frame
  last=(y,x)
  # Aim at projected arrival after right-wall return if travelling away.
  distance=x-2 if dx<0 else (29-x)+27
  offset=(y-3+dy*distance)%32
  target=3+(offset if offset<=16 else 32-offset)
  desired=max(3,min(17,target-1))
  want='a' if paddle[0]>desired else ('z' if paddle[0]<desired else None)
  if want!=held:
   if held:key(held,False)
   if want:key(want,True)
   held=want
  digits=rows[0][19:].strip()
  if digits.isdigit() and int(digits)>score:
   assert int(digits)==score+1,(score,digits,rows)
   score=int(digits);print('RETURN',score,frame,flush=True);hits.append({'score':score,'frame':frame,'paddle_top':paddle[0]})
   if score>=8:break
 assert score>=8,(score,rows)
 if held:key(held,False)
 key('q',True);m.frames(40);key('q',False);assert any('Finished.' in r for r in m.screen())
 result={'status':'passed','method':'One-frame screen observation and automated predictive paddle input, pristine ROM-loaded tape','returns':hits,'observed_frames_between_drawn_positions':{'min':min(moves),'max':max(moves),'mean':sum(moves)/len(moves)},'limits':'Automated interception demonstrates a sustained rally, not human responsiveness or enjoyment. Frame intervals include drawing and input; not a fixed-rate guarantee.'}
 (a.output/'rally-results.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result),flush=True)
finally:m.close()
