#!/usr/bin/env python3
"""Check queued and simultaneous steering through held keyboard matrix events."""
import argparse,json
from pathlib import Path
from verify import Review,state,line,body,sha,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output);m=r.m
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str((a.output/'tail.tap').resolve()));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');r.wait('S starts.');m.call('press_key',key='s',hold_frames=4);r.ready()
 m.call('input',events=[{'Key':{'name':'i','pressed':True}}])
 for _ in range(30):
  m.frames(1)
  try:s=state(m)
  except (AssertionError,IndexError):continue
  if s.get('turn')==1:break
 else:raise AssertionError('first turn not queued')
 assert s['steps']==0 and s['nd']==-1 and s['nc']==0
 m.call('input',events=[{'Key':{'name':'i','pressed':False}},{'Key':{'name':'j','pressed':True}}])
 for _ in range(100):
  m.frames(1)
  if line(m)==460 or 150<=line(m)<=260:
   try:s=state(m)
   except (AssertionError,IndexError):continue
   if s['steps']==1:break
 assert body(s)[-1]==(7,9),(s['steps'],body(s))
 m.call('input',events=[{'Key':{'name':'j','pressed':False}}]);r.record('second-key-cannot-replace-queued-turn')
 r.restart();m.call('input',events=[{'Key':{'name':'i','pressed':True}},{'Key':{'name':'j','pressed':True}}])
 for _ in range(100):
  m.frames(1)
  if line(m)==460 or 150<=line(m)<=260:
   try:s=state(m)
   except (AssertionError,IndexError):continue
   if s['steps']==1:break
 assert body(s)[-1]==(8,10)
 m.call('input',events=[{'Key':{'name':'i','pressed':False}},{'Key':{'name':'j','pressed':False}}]);r.record('simultaneous-directions-do-not-change-heading')
 r.wait('Mind the wall!');m.call('press_key',key='q',hold_frames=60);r.wait('Finished. RUN');r.record('quit-from-result')
 (a.output/'controls.json').write_text(json.dumps({'status':'passed','source_sha256':sha(ROOT/'tail-chase.bas'),'checks':r.checks,'method':'ROM-loaded game; held key matrix input; read-only state; no fixtures'},indent=2)+'\n')
finally:m.close()
