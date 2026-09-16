#!/usr/bin/env python3
import argparse,hashlib,json
from pathlib import Path
from verify import Spectrum,ref,ROOT
state=ref.state
p=argparse.ArgumentParser(description='Measure ROM-entered movement to return to the input loop, in emulated PAL frames.')
p.add_argument('--emulator',required=True);p.add_argument('--tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();m=Spectrum(a.emulator,a.output.parent)
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape.resolve()));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');m.frames(12000)
 m.call('press_keys',keys=['s'],hold_frames=12);m.frames(3000)
 results=[]
 for key in 'il':
  before=state(m);m.call('press_keys',keys=[key],hold_frames=3)
  for elapsed in range(1,1501):
   m.frames(1);b=m.call('memory_read',addr=23621,len=2)['bytes'];line=b[0]+256*b[1]
   if 3000<=line<=3030 and state(m)['moves']==before['moves']+1:break
  else:raise AssertionError(('not ready',state(m),m.screen()))
  results.append({'action':'walk' if key=='i' else 'push','frames':elapsed+3,'seconds_at_50hz':(elapsed+3)/50})
  m.frames(100)
 evidence={'tape_sha256':hashlib.sha256(a.tape.read_bytes()).hexdigest(),'source_sha256':hashlib.sha256((ROOT/'unit-10/steps/step-01.bas').read_bytes()).hexdigest(),'measurements':results,'method':'Three-frame press, then one-frame samples until the BASIC input loop is reached with the expected move count. One walk and one push from the initial room. Includes drawing and command processing; excludes tape loading. Not native host latency.'};a.output.write_text(json.dumps(evidence,indent=2)+'\n');print(json.dumps(evidence),flush=True)
finally:m.close()
