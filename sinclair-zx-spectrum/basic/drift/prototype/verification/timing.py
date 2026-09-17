#!/usr/bin/env python3
"""Observe ordinary frame execution, without instruction stepping or state writes."""
import argparse,json,statistics
from pathlib import Path
from check import Review,state,line,sha,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
try:
 r.m.call('load_media',slot='tape-1',kind='tape',path=str(r.out/'drift.tap'));r.m.statement('LOAD ""');r.m.call('media_transport',slot='tape-1',transport='start');r.wait_text('S starts.');r.m.call('press_key',key='s',hold_frames=4);r.m.frames(150)
 changes=[];last=state(r.m)['steps']
 for frame in range(800):
  r.m.frames(1);s=state(r.m)
  if s.get('steps',-1)!=last:
   last=s['steps'];changes.append(dict(frame=frame,steps=last,line=line(r.m)))
 assert len(changes)>5,changes
 periods=[b['frame']-a['frame'] for a,b in zip(changes,changes[1:])]
 # Real held input, observed at video frames, then enough release time for the ROM.
 r.m.call('press_key',key='space',hold_frames=80);r.m.frames(40);s=state(r.m);assert s['vx']>0 and s['vy']>0
 v=(s['vx'],s['vy']);r.m.frames(60);s=state(r.m);assert (s['vx'],s['vy'])==v
 r.m.call('press_key',key='r',hold_frames=40);r.m.frames(150);s=state(r.m);assert s['x']==48 and s['y']==56 and s['vx']==s['vy']==0
 r.m.call('press_key',key='space',hold_frames=2500);r.m.frames(40);r.wait_text('Hull lost.')
 r.m.call('press_key',key='q',hold_frames=60);r.wait_text('Finished. RUN');r.m.frames(100)
 assert any('Finished. RUN' in row for row in r.m.screen())
 result=dict(status='passed',source_sha256=sha(ROOT/'drift.bas'),tape_sha256=sha(r.out/'drift.tap'),method='Ordinary run_frames; movement-commit intervals at rest; no instruction stepping',frames=dict(median=statistics.median(periods),minimum=min(periods),maximum=max(periods),samples=len(periods)),observations=changes,checks=['frame-driven-held-thrust','frame-driven-coasting','frame-driven-restart','frame-driven-crash-and-result-quit'])
 (r.out/'timing.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result['frames']),flush=True)
finally:r.m.close()
