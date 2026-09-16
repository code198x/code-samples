#!/usr/bin/env python3
"""ROM-entered three-room Crates, independent state checks and fresh tape loading."""
import argparse, hashlib, json
from collections import deque
from pathlib import Path
from entry import ROOT, Spectrum

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def number(b):
    if b[0]==0:return b[2]+256*b[3]-(65536 if b[1] else 0)
    return (-1 if b[1]&128 else 1)*(1+(((b[1]&127)<<24)+(b[2]<<16)+(b[3]<<8)+b[4])/2**31)*2**(b[0]-129)
def state(m):
    ptr=m.call('memory_read',addr=23627,len=2)['bytes'];addr=ptr[0]+256*ptr[1];data=[]
    for offset in range(0,2048,128):data+=m.call('memory_read',addr=addr+offset,len=128)['bytes']
    i=0;out={}
    while data[i]!=128:
        tag=data[i]>>5;name=chr((data[i]&31)+96);i+=1
        if tag in [2,4,6]:
            size=data[i]+256*data[i+1];i+=2
            if tag==4 and name=='g':
                assert data[i]==2 and data[i+1:i+5]==[8,0,8,0]
                out['grid']=[int(number(data[j:j+5])) for j in range(i+5,i+5+64*5,5)]
            i+=size
        elif tag in [3,5,7]:
            if tag==5:
                while True:
                    ch=data[i];i+=1;name+=chr(ch&127)
                    if ch&128:break
            out[name]=number(data[i:i+5]);i+=5
            if tag==7:i+=13
        else:raise AssertionError(tag)
    return out

def initial(room=1):
    grid=[int(r in [1,8] or c in [1,8] or (room==3 and r in [2,3] and c!=4)) for r in range(1,9) for c in range(1,9)]
    cells={1:[(3,4,1),(4,4,1),(3,5,2),(5,4,3)],
           2:[(3,6,1),(4,5,1),(4,6,1),(5,7,1),(3,5,2),(5,5,3)],
           3:[(2,4,2),(3,4,2),(4,4,3),(5,4,3)]}[room]
    for r,c,value in cells:grid[(r-1)*8+c-1]=value
    return {'grid':grid,'pr':6,'pc':{1:3,2:5,3:4}[room],'moves':0,'won':0,'room':room}

def solve(start):
    # Breadth-first search of legal states: no heuristic deadlock assumptions.
    identity=lambda s:(tuple(s['grid']),s['pr'],s['pc'])
    queue=deque([(start,'')]);seen={identity(start)}
    while queue:
        current,path=queue.popleft()
        if current['won']:return path
        for key in 'ijkl':
            candidate=expected_move(current,key);signature=identity(candidate)
            if signature not in seen:
                seen.add(signature);queue.append((candidate,path+key))
    return None

def expected_move(current,key):
    result={**current,'grid':current['grid'].copy()}
    if key not in 'ijkl' or current['won']:return result
    dr,dc={'i':(-1,0),'j':(0,-1),'k':(1,0),'l':(0,1)}[key]
    r,c=current['pr']+dr,current['pc']+dc
    if not (1<=r<=8 and 1<=c<=8):return result
    at=lambda r,c:(r-1)*8+c-1
    code=current['grid'][at(r,c)]
    if code==1:return result
    if code in [3,4]:
        br,bc=r+dr,c+dc
        if not (1<=br<=8 and 1<=bc<=8):return result
        beyond=current['grid'][at(br,bc)]
        if beyond not in [0,2]:return result
        # Semantic conversion independent of the BASIC branch order.
        result['grid'][at(r,c)]={3:0,4:2}[code]
        result['grid'][at(br,bc)]={0:3,2:4}[beyond]
    result.update(pr=r,pc=c,moves=current['moves']+1,won=int(2 not in result['grid']))
    return result

class Review:
    def __init__(self,executable,output):
        self.executable=executable;self.output=output;self.m=Spectrum(executable,output);self.checks=[];self.trace=[]
    def wait(self,text,limit=16000):
        for _ in range(limit//20):
            if any(text in row for row in self.m.screen()):return
            self.m.frames(20)
        raise AssertionError((text,self.m.screen()))
    def key(self,key,hold=12):
        # Let display completion reach the release/press input loop.
        self.m.frames(100)
        keys=['caps',key.lower()] if key.isupper() else [key]
        self.m.call('press_keys',keys=keys,hold_frames=hold);self.m.frames(100)
    def capture(self,name):
        self.m.frames(100);self.m.call('save_screenshot',path=str(self.output/(name+'.png')))
    def check(self):
        for attempt in range(200):
            try:
                self.check_now();return
            except AssertionError:
                if attempt==199:raise
                self.m.frames(20)
    def check_now(self):
        actual=state(self.m)
        for key,value in self.model.items():assert actual[key]==value,(key,actual[key],value,self.m.screen())
        assert actual['left']==self.model['grid'].count(2), ('remaining targets',actual['left'])
        # Observe actual display pixels, including custom characters.
        display=[]
        for address in range(16384,23296,128):
            display+=self.m.call('memory_read',addr=address,len=min(128,23296-address))['bytes']
        patterns=[]
        for line in (ROOT/'crates.bas').read_text().splitlines():
            if ' DATA ' in line:patterns.append(list(map(int,line.split(' DATA ')[1].split(','))))
        for r in range(1,9):
            for c in range(1,9):
                code=self.model['grid'][(r-1)*8+c-1]
                glyph={0:None,1:0,2:4,3:8,4:8}[code]
                ink=[0,1,5,6,4][code]
                if (r,c)==(self.model['pr'],self.model['pc']):
                    glyph=16 if code==2 else 12;ink=5 if code==2 else 7
                y,x=3+2*(r-1),8+2*(c-1)
                for q,(dy,dx) in enumerate([(0,0),(0,1),(1,0),(1,1)]):
                    assert display[6144+(y+dy)*32+x+dx]==ink,(r,c,'colour')
                    for scan in range(8):
                        py=(y+dy)*8+scan
                        address=((py&192)<<5)|((py&7)<<8)|((py&56)<<2)|(x+dx)
                        expected=0 if glyph is None else patterns[glyph+q][scan]
                        assert display[address]==expected,(r,c,q,scan)
        assert self.m.screen()[1].strip()==f"STEPS {self.model['moves']}"
        assert f"ROOM 0{self.model.get('room',1)}" in self.m.screen()[0]
    def move(self,key,hold=12):
        self.model=expected_move(self.model,key.lower());self.key(key,hold);self.check();self.trace.append(key)
    def record(self,name):self.checks.append(name);print('PASS',name,flush=True)
    def restart(self,key='r',hold=12):
        self.key(key,hold);self.model=initial(self.model.get("room",1));self.check()
    def quit(self):self.key('q');self.wait('9 STOP')
    def fixture(self,lines,grid,player):
        self.quit()
        for line in lines:self.m.statement(line)
        self.m.statement('RUN');self.wait('S starts. Q quits.');self.key('s');self.model={'grid':grid,'pr':player[0],'pc':player[1],'moves':0,'won':0};self.check()
    def execute(self):
        source=ROOT/'crates.bas'
        cache=self.output/'entered.tap';meta=self.output/'entered.json'
        if cache.exists() and meta.exists() and json.loads(meta.read_text())['source_sha256']==sha(source):
            evidence=json.loads(meta.read_text());assert sha(cache)==evidence['tape_sha256']
            self.m.call('load_media',slot='tape-1',kind='tape',path=str(cache));self.m.statement('LOAD "cratesdev"');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('S starts. Q quits.');self.quit()
            stored=self.m.program_lines();assert stored=={int(n):v for n,v in evidence['stored'].items()}
            print('Loaded verified ROM-entry cache',flush=True)
        else:
            self.m.load_source(source);stored=self.m.program_lines()
            self.m.statement('SAVE "cratesdev" LINE 10');self.m.enter();self.wait('0 OK');self.m.call('save_tape',path=str(cache))
            meta.write_text(json.dumps({'source_sha256':sha(source),'tape_sha256':sha(cache),'stored':stored})+'\n')
        rom=[]
        for address in range(0,16384,128):rom+=self.m.call('memory_read',addr=address,len=128)['bytes']
        self.m.statement('RUN');self.wait('S starts. Q quits.');self.capture('instructions')
        self.key('x');assert any('S starts.' in row for row in self.m.screen())
        self.key('s',180);self.model=initial();self.check();self.capture('room')
        self.m.call('press_keys',keys=['i','l'],hold_frames=100);self.m.frames(100);self.check();self.record('simultaneous-direction-keys-ignored')
        self.move('l',180);self.move('i');self.move('x');self.move('k');self.move('k')
        self.record('held-movement-one-step-blocked-push-wall-and-invalid-key-preserve-state')
        self.restart('R',180)
        for key in 'ilkl':self.move(key)
        self.capture('first-push')
        self.move('i');self.move('i',180);assert self.model['won']==1;self.capture('solved')
        for key in 'ijkl':self.move(key)
        self.record('six-move-solution-held-winning-key-and-completion-movement-ignored')
        self.restart();self.move('i');self.move('j')
        self.quit();before=state(self.m);self.m.statement('CLS');self.m.statement('GO SUB 1000');self.m.frames(500);self.check()
        after=state(self.m)
        for key in self.model:assert before[key]==after[key]
        self.m.statement('GO TO 110');self.m.frames(100);self.record('CLS-full-reconstruction-does-not-change-world')
        # Explicit ROM-entered fixtures preserve the published source and are
        # restored before saving. No memory writes set up these scenarios.
        grid=[int(r in [1,8] or c in [1,8]) for r in range(1,9) for c in range(1,9)]
        def fixture_grid(cells):
            g=grid.copy()
            for r,c,v in cells:g[(r-1)*8+c-1]=v
            return g
        self.fixture(['60 LET g(3,3) = 3: LET g(3,4) = 2','70 LET g(6,6) = 3: LET g(6,5) = 2','80 LET pr = 3: LET pc = 2: LET moves = 0: LET won = 0'],fixture_grid([(3,3,3),(3,4,2),(6,6,3),(6,5,2)]),(3,2))
        self.move('l');self.move('L');self.capture('player-on-target');self.move('k');self.move('i');self.move('j')
        self.record('push-onto-and-off-target-player-overlay-and-restored-target')
        self.fixture(['60 LET g(3,3) = 3: LET g(3,4) = 3','70 LET g(6,5) = 2: LET g(6,6) = 2'],fixture_grid([(3,3,3),(3,4,3),(6,5,2),(6,6,2)]),(3,2));self.move('l');self.record('cannot-push-two-crates')
        self.fixture(['60 LET g(4,1) = 0','70 LET g(4,2) = 3: LET g(4,7) = 2','80 LET pr = 4: LET pc = 1: LET moves = 0: LET won = 0'],fixture_grid([(4,1,0),(4,2,3),(4,7,2)]),(4,1));self.move('j');self.record('player-bound-check-with-open-edge')
        self.fixture(['60 LET g(4,8) = 3','70 LET g(3,7) = 2','80 LET pr = 4: LET pc = 7: LET moves = 0: LET won = 0'],fixture_grid([(4,8,3),(3,7,2)]),(4,7));self.move('l');self.record('push-destination-bound-check')
        self.quit()
        originals={int(line.split()[0]):line for line in source.read_text().splitlines()}
        for n in [60,70,80]:self.m.statement(originals[n])
        assert self.m.program_lines()==stored
        self.m.statement('RUN');self.wait('S starts. Q quits.');self.quit();self.record('quit-from-title')
        self.m.statement('SAVE "crates1" LINE 10');self.m.enter();self.wait('0 OK')
        tape=self.output/'crates1.tap';self.m.call('save_tape',path=str(tape));self.m.close();self.m=Spectrum(self.executable,self.output)
        self.m.call('load_media',slot='tape-1',kind='tape',path=str(tape));self.m.statement('LOAD "crates1"');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('S starts. Q quits.')
        assert self.m.program_lines()==stored
        self.key('s');self.model=initial();self.check();self.move('n')
        for key in 'ilkl ii'.replace(' ',''):self.move(key)
        self.key('N',180);self.model=initial(2);self.check();self.capture('room-2')
        self.move('n');self.move('i')
        self.record('next-room-only-after-completion-held-N-cannot-skip')
        for key in 'jil':self.move(key)
        assert solve(self.model) is None
        self.capture('room-2-trap');self.restart('R',180)
        self.record('room-2-legal-deadlock-and-current-room-restart')
        solution=solve(initial(2));assert solution=='lijkjiijil'
        for key in solution:self.move(key)
        assert self.model['won']==1;self.capture('room-2-solved')
        for key in 'ijkl':self.move(key)
        self.restart();assert self.model['room']==2
        for key in solution:self.move(key)
        self.record('room-2-solve-and-current-room-replay')
        self.key('N',180);self.model=initial(3);self.check();self.capture('room-3')
        self.move('n');self.move('i')
        solution3=solve(initial(3));assert solution3=='jiliikllkjkjii'
        for key in solution3[:3]:self.move(key)
        self.capture('room-3-space-made')
        self.move(solution3[3]);assert self.model['won']==0 and self.model['grid'].count(4)==1
        self.move('N');self.capture('room-3-one-delivered')
        self.record('room-3-pair-blocked-space-made-one-target-not-completion')
        for key in solution3[4:]:self.move(key)
        assert self.model['won']==1 and self.model['grid'].count(4)==2
        self.capture('room-3-solved')
        for key in 'ijkl':self.move(key)
        self.restart('R',180);assert self.model['room']==3
        for key in solution3:self.move(key)
        self.key('n',180);self.model=initial();self.check();self.capture('new-game')
        self.record('room-3-solve-replay-and-new-game-clears-state')
        self.quit();self.record('ROM-save-fresh-load-three-rooms-replay-exit')
        (self.output/'results.json').write_text(json.dumps({'status':'passed','configuration':'48K ZX Spectrum PAL; ROM keyboard entry and read-only observation','server':self.m.server,'binary_sha256':sha(Path(self.executable)),'rom_sha256':hashlib.sha256(bytes(rom)).hexdigest(),'source_sha256':sha(source),'tape_sha256':sha(tape),'checks':self.checks,'trace':self.trace,'solutions':{'room_1':'ilklii','room_2':solution,'room_3':solution3},'limits':'Three fixed rooms. Fixture edits are declared in the runner and restored before save. No map loader, sound, undo, native host-input or original-hardware acceptance.'},indent=2)+'\n')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True);r=Review(a.emulator,a.output)
    try:r.execute()
    except Exception:r.capture('failure');raise
    finally:r.m.close()
