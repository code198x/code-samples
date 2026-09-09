"""Capture the ordinary title and an early flight after fresh tape loading."""
import argparse,hashlib,json
from pathlib import Path
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output)
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape));m.statement('LOAD "touchdown"');m.call('media_transport',slot='tape-1',transport='start');m.frames(7000)
 assert any('0 OK' in r for r in m.screen()),m.screen()
 m.statement('RUN');m.frames(300);assert any('S launches' in r for r in m.screen())
 m.call('save_screenshot',path=str(a.output/'title.png'))
 m.call('press_key',key='s',hold_frames=3);m.frames(200)
 assert any('FUEL' in r for r in m.screen())
 m.call('save_screenshot',path=str(a.output/'flight.png'))
 (a.output/'manifest.json').write_text(json.dumps({'source':'../steps/step-06.bas','source_sha256':hashlib.sha256((ROOT/'steps/step-06.bas').read_bytes()).hexdigest(),'tape_sha256':hashlib.sha256(a.tape.read_bytes()).hexdigest(),'emulator':'Emu198x Spectrum 0.22.1','configuration':'48K PAL, lawfully configured ROM','method':'Fresh named tape load, RUN via ROM keyboard entry; title after 300 further frames; S held for 3 frames, then 200 frames to flight. No injected state or source edits.','files':['title.png','flight.png']},indent=2)+'\n')
finally:m.close()
