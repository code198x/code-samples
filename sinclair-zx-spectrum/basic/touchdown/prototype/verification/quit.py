"""Verify held flight quit and save through the ROM after returning to its prompt."""
import argparse,json,hashlib
from pathlib import Path
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();out=a.output;out.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,out)
def key(k,d):m.call('input',events=[{'Key':{'name':k,'pressed':d}}])
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape));m.statement('LOAD "touchdown"');m.call('media_transport',slot='tape-1',transport='start');m.frames(7000)
 for line in (ROOT/'steps/step-06.bas').read_text().splitlines():
  if line.startswith(('850 ','860 ')):m.statement(line)
 m.statement('RUN');m.frames(300);m.call('press_key',key='s',hold_frames=3);m.frames(200)
 key('q',True);m.frames(80);assert not any('Finished.' in r for r in m.screen())
 key('q',False);m.frames(80);assert any('9 STOP' in r for r in m.screen()),m.screen()
 m.statement('SAVE "touchdown"');m.enter();m.frames(8000);assert any('0 OK' in r for r in m.screen()),m.screen()
 m.call('save_tape',path=str(out/'touchdown.tap'))
 (out/'quit-results.json').write_text(json.dumps({'check':'Held Q waits for release before returning to BASIC; following SAVE succeeds without stray input','source_sha256':hashlib.sha256((ROOT/'steps/step-06.bas').read_bytes()).hexdigest(),'tape_sha256':hashlib.sha256((out/'touchdown.tap').read_bytes()).hexdigest()},indent=2)+'\n')
 print('PASS held-flight-quit-and-final-tape',flush=True)
finally:m.close()
