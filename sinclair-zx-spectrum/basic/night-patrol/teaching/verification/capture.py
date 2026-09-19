"""Capture ordinary frame advancement, avoiding debug-step/frame clock mixing."""
import argparse,concurrent.futures,json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum

def capture(name,exe,out):
 folder=out/name;m=Spectrum(exe,folder)
 try:
  m.call('load_media',slot='tape-1',kind='tape',path=str(folder/'night-patrol.tap'));m.statement('LOAD ""');m.call('media_transport',slot='tape-1',transport='start');m.frames(8000)
  if name=='finished':
   assert any('S starts.' in r for r in m.screen());m.call('press_key',key='s',hold_frames=30);m.frames(1200)
  rows=m.screen();assert any('NIGHT PATROL' in r for r in rows),rows
  assert any('?' in r for r in rows[2:20]),rows
  attributes={}
  if name!='archive':
   for label,row,col in [('player',17,3),('controls',20,1),('retry',21,1)]:
    value=m.call('memory_read',addr=22528+32*row+col,len=1)['bytes'][0]
    assert value==(71 if label=='player' else 7),(name,label,value)
    attributes[label]=value
  m.call('save_screenshot',path=str(folder/'native-view.png'))
  (folder/'capture.json').write_text(json.dumps(dict(method='Fresh tape; ordinary frame advancement; S at finished title; no CPU debug stepping or state writes',screen=rows,attributes=attributes),indent=2)+'\n');print('CAPTURED',name,flush=True)
 finally:m.close()
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--only',nargs='+');p.add_argument('--jobs',type=int,default=1);a=p.parse_args()
 names=a.only or [i['name'] for i in json.loads((ROOT/'checkpoints.json').read_text())]
 with concurrent.futures.ThreadPoolExecutor(max_workers=a.jobs) as pool:list(pool.map(lambda n:capture(n,a.emulator,a.output.resolve()),names))
