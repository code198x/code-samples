"""Enter a checkpoint through the 48K ROM and save a named BASIC tape."""
import argparse,json,hashlib
from pathlib import Path
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--source',type=Path,default=ROOT/'steps/step-06.bas');p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output)
try:
 source_text=a.source.read_text()
 for line in source_text.splitlines():
  m.statement(line)
  ptr=m.call('memory_read',addr=23627,len=10)['bytes']
  start=ptr[8]+256*ptr[9];end=ptr[0]+256*ptr[1]
  data=[]
  for addr in range(start,end,128):data+=m.call('memory_read',addr=addr,len=min(128,end-addr))['bytes']
  i=0;found=[]
  while i+4<=len(data):
   found.append(data[i]*256+data[i+1]);i+=4+data[i+2]+256*data[i+3]
  assert int(line.split()[0]) in found,(line,m.screen())
  print('ENTERED',line.split()[0],flush=True)
 m.statement('RUN');m.frames(250)
 rows=m.screen();print('\n'.join(rows),flush=True)
 assert any('S launches' in r for r in rows),rows
 m.call('save_screenshot',path=str(a.output/'title.png'))
 m.call('press_key',key='s',hold_frames=3);m.frames(200)
 print('\n'.join(m.screen()),flush=True)
 m.call('save_screenshot',path=str(a.output/'flight.png'))
 m.frames(3000);print('\n'.join(m.screen()),flush=True)
 assert any('Terrain collision' in r for r in m.screen()),m.screen()
 m.call('save_screenshot',path=str(a.output/'crash.png'))
 m.call('press_key',key='q',hold_frames=3);m.frames(100)
 assert any('9 STOP' in r for r in m.screen()),m.screen()
 m.statement('SAVE "touchdown"');m.enter();m.frames(10000)
 assert any('0 OK' in r for r in m.screen()),m.screen()
 m.call('save_tape',path=str(a.output/'touchdown.tap'))
 (a.output/'build.json').write_text(json.dumps({'source_sha256':hashlib.sha256(source_text.encode()).hexdigest(),'server':m.server,'checks':['ROM entry','title','launch','uncontrolled terrain crash','quit','ROM tape save']},indent=2)+'\n')
finally:m.close()
