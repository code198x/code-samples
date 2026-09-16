"""Execute a one-bit artwork edit and a palette change independent of collision."""
import argparse,json
from pathlib import Path
from verify import Review,ROOT,ref,lines,sha,bitmap,pixelcell,Spectrum
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output=a.output.resolve();r=Review(a.emulator,a.output)
def load(name):
    r.m.close();r.m=Spectrum(a.emulator,a.output);r.stage=next(s for s in json.loads((ROOT/'roster.json').read_text()) if s['name']==name);r.program=lines(ROOT/r.stage['source'])
    tape=a.output/'cache'/(name+'.tap');meta=json.loads(tape.with_suffix('.json').read_text());assert sha(tape)==meta['tape_sha256'] and sha(ROOT/r.stage['source'])==meta['source_sha256']
    r.m.call('load_media',slot='tape-1',kind='tape',path=str(tape));r.m.statement('LOAD "'+meta.get('tape_name','crateswork')+'"');r.m.call('media_transport',slot='tape-1',transport='start');r.wait('0 OK');assert r.m.program_lines()=={int(n):v for n,v in meta['stored'].items()}
try:
    load('tile');stored=r.m.program_lines();r.m.statement('RUN');r.wait('9 STOP');before=bitmap(r.m)
    r.m.statement('7200 DATA 128,127,64,95,88,84,82,81');r.m.statement('RUN');r.wait('9 STOP');after=bitmap(r.m)
    py=80;addr=((py&192)<<5)|((py&7)<<8)|((py&56)<<2)|15
    changed=[i for i,(a,b) in enumerate(zip(before,after)) if a!=b]
    assert changed==[addr] and before[addr]^after[addr]==128,changed
    r.capture('tile-one-bit-edit');r.m.statement(r.program[7200]);r.m.statement('RUN');r.wait('9 STOP');assert bitmap(r.m)==before and r.m.program_lines()==stored
    load('walk');stored=r.m.program_lines();r.start();r.quit();r.m.statement('LET a(2) = 2: GO SUB 1000');r.m.frames(1200)
    # A palette-only edit changes the display; world coordinates and grid remain.
    actual=ref.state(r.m)
    for k,v in r.model.items():assert actual[k]==v
    r.m.statement('GO TO 110');r.m.frames(100)
    for key in 'jj':
        candidate=ref.expected_move(r.model,key);r.key(key);r.model=candidate;actual=ref.state(r.m)
        for k,v in candidate.items():assert actual[k]==v
    assert (r.model['pr'],r.model['pc'],r.model['moves'])==(6,2,1)
    r.capture('walk-palette-does-not-change-collision');r.quit();r.m.statement('LET a(2) = 1: GO SUB 1000');r.m.frames(1200);r.check();assert r.m.program_lines()==stored
    (a.output/'graphics.json').write_text(json.dumps({'status':'passed','sources':{n:next(s['sha256'] for s in json.loads((ROOT/'roster.json').read_text()) if s['name']==n) for n in ['tile','walk']},'checks':['one-row-byte-edit-changes-exactly-one-pixel-and-restores','wall-palette-change-leaves-world-and-collision-unchanged'],'setup':'Declared ROM edit to DATA 7200, restored; palette variable changed through a direct BASIC command, restored. No game-state injection.'},indent=2)+'\n');print('PASS pixel edit and palette-independent collision',flush=True)
finally:r.m.close()
