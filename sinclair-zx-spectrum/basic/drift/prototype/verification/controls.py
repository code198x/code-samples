#!/usr/bin/env python3
"""Additional keyboard trials: fast dock passage, held turns and phase exits."""
import argparse,json
from pathlib import Path
from check import Review,state,sha,ROOT
from entry import Spectrum
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
def load():
 r.m.call('load_media',slot='tape-1',kind='tape',path=str(r.out/'drift.tap'));r.m.statement('LOAD ""');r.m.call('media_transport',slot='tape-1',transport='start');r.wait_text('S starts.')
def quit_game():
 r.m.frames(40);r.m.call('press_key',key='q',hold_frames=60);r.wait_text('Finished. RUN');r.m.frames(100)
 assert any('Finished. RUN' in s for s in r.m.screen())
try:
 load();quit_game();r.record('quit-from-title')
 r.m.close();r.m=Spectrum(a.emulator,r.out);load();r.m.call('press_key',key='s',hold_frames=4);r.boundary({200})
 # Hold a turn across several updates, then release. There is no translational force.
 r.event('o',True);r.m.frames(140);r.event('o',False);r.m.frames(1);r.boundary({200});s=state(r.m)
 assert s['steps']>=3 and s['x']==48 and s['y']==56 and s['vx']==s['vy']==0;r.record('held-turn-updates-without-changing-position')
 r.reset()
 for _ in range(4):r.tick(' ')
 for _ in range(69):r.tick()
 r.face(6)
 for _ in range(4):r.tick(' ')
 r.face(1)
 for _ in range(5):r.tick(' ')
 inside=False
 for _ in range(200):
  s,crash,win=r.tick();assert not win
  if 190<=s['x']<=210 and 94<=s['y']<=114:inside=True;assert s['vx']**2+s['vy']**2>.16
  if crash:break
 assert inside and crash;r.record('fast-passage-through-dock-does-not-win')
 # Result-screen exit is checked with ordinary frame execution in timing.py.
 (r.out/'controls.json').write_text(json.dumps(dict(status='passed',source_sha256=sha(ROOT/'drift.bas'),tape_sha256=sha(r.out/'drift.tap'),checks=r.checks,trace=r.trace),indent=2)+'\n')
finally:r.m.close()
