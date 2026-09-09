"""Check the maintained independent keyboard display with all control combinations."""
import argparse,itertools,json,sys,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1];sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from entry import Spectrum
from state import variables
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True);m=Spectrum(a.emulator,a.output)
try:
 source=ROOT/'unit-07/diagnostic.bas'
 for line in source.read_text().splitlines():m.statement(line)
 m.statement('RUN');cases=[]
 for left,right,thrust in itertools.product([False,True],repeat=3):
  for k,d in [('o',left),('p',right),('space',thrust)]:m.call('input',events=[{'Key':{'name':k,'pressed':d}}])
  m.frames(60);state=variables(m)
  assert [state[k] for k in ['left','right','thrust']]==[left,right,thrust],state
  cases.append({'left':left,'right':right,'thrust':thrust});print('PASS',cases[-1],flush=True)
 m.call('save_screenshot',path=str(a.output/'combined-input.png'))
 for k in ['o','p','space']:m.call('input',events=[{'Key':{'name':k,'pressed':False}}])
 m.frames(60);assert all(variables(m)[k]==0 for k in ['left','right','thrust'])
 m.call('input',events=[{'Key':{'name':'q','pressed':True}}]);m.frames(60);assert not any('9 STOP' in r for r in m.screen())
 m.call('input',events=[{'Key':{'name':'q','pressed':False}}]);m.frames(100);assert any('9 STOP' in r for r in m.screen())
 (a.output/'diagnostic-results.json').write_text(json.dumps({'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),'combinations':cases,'release_and_quit':'passed'},indent=2)+'\n')
finally:m.close()
