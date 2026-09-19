"""Capture native frame output without mixing CPU debug stepping and frame runs."""
import argparse,json,hashlib
from pathlib import Path
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output)
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str((a.output/'night-patrol.tap').resolve()))
 m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');m.frames(6000)
 assert any('S starts.' in s for s in m.screen())
 m.call('press_key',key='s',hold_frames=30);m.frames(1200)
 assert any('TAKE THE FILE.' in s for s in m.screen()),m.screen()
 m.call('save_screenshot',path=str((a.output/'live-frames.png').resolve()))
finally:m.close()
