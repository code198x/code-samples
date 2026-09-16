"""Additional executed push-boundary fixtures for the floor-only checkpoint."""
import argparse,json
from pathlib import Path
from verify import Review,ROOT,ref,lines,sha
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output=a.output.resolve();r=Review(a.emulator,a.output)
try:
    r.stage=next(s for s in json.loads((ROOT/'roster.json').read_text()) if s['name']=='push');r.program=lines(ROOT/r.stage['source'])
    meta=json.loads((a.output/'cache/push.json').read_text());tape=a.output/'cache/push.tap';assert sha(tape)==meta['tape_sha256'] and sha(ROOT/r.stage['source'])==meta['source_sha256']
    r.m.call('load_media',slot='tape-1',kind='tape',path=str(tape));r.m.statement('LOAD "'+meta['tape_name']+'"');r.m.call('media_transport',slot='tape-1',transport='start');r.wait('0 OK');stored=r.m.program_lines();assert stored=={int(n):v for n,v in meta['stored'].items()};r.start()
    grid=[int(row in [1,8] or col in [1,8]) for row in range(1,9) for col in range(1,9)]
    for row,col,v in [(3,3,3),(3,4,3),(6,5,2),(6,6,2)]:grid[(row-1)*8+col-1]=v
    r.fixture({60:'LET g(3,3) = 3: LET g(3,4) = 3',70:'LET g(6,5) = 2: LET g(6,6) = 2',80:'LET pr = 3: LET pc = 2: LET moves = 0: LET won = 0'},{'grid':grid,'pr':3,'pc':2,'moves':0,'won':0,'room':1});r.move('l');r.capture_stage('-blocked-pair')
    grid=[int(row in [1,8] or col in [1,8]) for row in range(1,9) for col in range(1,9)];grid[3*8+7]=3;grid[2*8+6]=2
    r.fixture({60:'LET g(4,8) = 3',70:'LET g(3,7) = 2',80:'LET pr = 4: LET pc = 7: LET moves = 0: LET won = 0'},{'grid':grid,'pr':4,'pc':7,'moves':0,'won':0,'room':1});r.move('l');r.capture_stage('-beyond-edge');r.restore([60,70,80]);r.quit();assert r.m.program_lines()==stored
    (a.output/'boundaries.json').write_text(json.dumps({'status':'passed','source_sha256':r.stage['sha256'],'checks':['adjacent-crates-blocked-without-mutation','push-beyond-array-edge-rejected-before-index'],'setup':'Declared ROM-entered replacements for lines 60,70,80; originals restored and stored bytes compared.'},indent=2)+'\n');print('PASS floor-only push pair and bounds',flush=True)
finally:r.m.close()
