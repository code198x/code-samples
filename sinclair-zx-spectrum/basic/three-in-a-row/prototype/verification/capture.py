"""Refresh original captures after complete display frames; legal keys only."""
import argparse,json,hashlib
from pathlib import Path
from check import Review
from entry import ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();r=Review(a.emulator,a.output.resolve())
try:
 r.m.call('load_media',slot='tape-1',kind='tape',path=str(r.out/'three.tap'));r.m.statement('LOAD ""');r.m.call('media_transport',slot='tape-1',transport='start');r.waitline([110]);r.capture('title')
 r.key('s');r.ready();r.capture('board')
 for n in (1,8,7):r.move(n)
 r.capture('fork');r.move(4);r.capture('win')
 r.key('r');r.ready();r.capture('computer-start')
 model=json.loads((r.out/'model.json').read_text())['starters'][0]
 for name,target in [('draw','draw'),('O','loss')]:
  r.run()
  for move in model['examples'][name]:
   if move['mark']==1:r.move(move['cell'])
  r.capture(target)
 (r.out/'captures.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/'three.bas').read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),'server':r.m.server,'method':'Fresh ROM tape load and legal keys; ten settled frames before each original PNG.','trials':r.trials,'direct_memory_writes':False},indent=2)+'\n')
 print('PASS seven settled original captures')
finally:r.m.close()
