"""Execute every teaching checkpoint by ROM editing/loading and read-only checks."""
import argparse,hashlib,importlib.util,json,sys
from pathlib import Path
from tape import keep_program
ROOT=Path(__file__).resolve().parents[1]
DONOR=ROOT.parent/'prototype/verification'
sys.path.insert(0,str(DONOR))
spec=importlib.util.spec_from_file_location('crates_reference',DONOR/'verify.py');ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
Spectrum=ref.Spectrum
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def lines(path):return {int(l.split()[0]):l for l in path.read_text().splitlines()}

def bitmap(m):
    data=[]
    for addr in range(16384,23296,128):data+=m.call('memory_read',addr=addr,len=min(128,23296-addr))['bytes']
    return data

def pixelcell(display,row,col,pattern,ink):
    assert display[6144+32*row+col]==ink,(row,col,'ink')
    for scan,byte in enumerate(pattern):
        py=8*row+scan;addr=((py&192)<<5)|((py&7)<<8)|((py&56)<<2)|col
        assert display[addr]==byte,(row,col,scan,display[addr],byte)

class Review(ref.Review):
    def __init__(self,exe,out):
        super().__init__(exe,out);self.stage=None;self.results=[];self.program={};self.patterns=[list(map(int,l.split(' DATA ')[1].split(','))) for l in (ROOT.parent/'prototype/crates.bas').read_text().splitlines() if ' DATA ' in l]
    def check_now(self):
        actual=ref.state(self.m)
        for k,v in self.model.items():assert actual.get(k)==v,(self.stage['name'],k,actual.get(k),v)
        if self.stage['unit']>=6:assert actual.get('left')==self.model['grid'].count(2)
        d=bitmap(self.m)
        for r in range(1,9):
            for c in range(1,9):
                z=self.model['grid'][(r-1)*8+c-1];glyph={0:None,1:0,2:4,3:8,4:8}[z];ink=[0,1,5,6,4][z]
                if self.stage['name']!='room' and (r,c)==(self.model['pr'],self.model['pc']):glyph=16 if z==2 else 12;ink=5 if z==2 else 7
                for q,(dy,dx) in enumerate([(0,0),(0,1),(1,0),(1,1)]):pixelcell(d,3+2*(r-1)+dy,8+2*(c-1)+dx,[0]*8 if glyph is None else self.patterns[glyph+q],ink)
        if self.stage['unit']>=3:
            assert self.m.screen()[1][2:18].strip()==f"STEPS {self.model['moves']}"
        if self.stage['unit']>=6:
            total=sum(v in [2,4] for v in self.model['grid'])
            assert self.m.screen()[1][18:].strip()==f"GOALS {total-self.model['grid'].count(2)}/{total}"
    def move(self,key,hold=12):
        before=self.model;candidate=ref.expected_move(before,key.lower())
        changed=before['grid']!=candidate['grid']
        if self.stage['name']=='walk' and changed:candidate={**before,'grid':before['grid'].copy()}
        if self.stage['name']=='push' and changed and candidate['grid'].count(4):candidate={**before,'grid':before['grid'].copy()}
        if self.stage['unit']<6 or self.stage['name']=='counter':candidate['won']=0
        self.model=candidate;self.key(key,hold);self.check();self.trace.append(key)
    def start(self,model=None):
        self.m.statement('RUN')
        if self.stage['unit']>=7 or self.stage['name']=='complete':self.wait('S starts. Q quits.');self.key('s')
        self.model=model or ref.initial();self.check()
    def stop(self):
        if self.stage['unit']>=3:self.quit()
    def fixture(self,updates,model):
        self.stop()
        for n,value in updates.items():self.m.statement(f'{n} {value}')
        self.start(model)
    def restore(self,nums):
        self.stop()
        for n in nums:self.m.statement(self.program[n])
        self.start()
    def patch(self,program):
        for n in sorted(self.program.keys()-program.keys()):self.m.statement(str(n))
        for n in sorted(program):
            if self.program.get(n)!=program[n]:self.m.statement(program[n])
        assert set(self.m.program_lines())==set(program)
        self.program=program
    def save_cache(self,path,meta):
        stored=self.m.program_lines();tape_name=self.stage['name'][:10];self.m.statement(f'SAVE "{tape_name}"');self.m.enter();self.wait('0 OK');self.m.call('save_tape',path=str(path));keep_program(path,tape_name)
        meta.write_text(json.dumps({'source_sha256':self.stage['sha256'],'tape_sha256':sha(path),'stored':stored,'tape_name':tape_name})+'\n')
    def capture_stage(self,suffix=''):
        self.capture(self.stage['name']+suffix)
    def run_stage(self):
        name=self.stage['name'];unit=self.stage['unit']
        if name=='palette':
            self.m.statement('RUN');self.wait('9 STOP');d=bitmap(self.m)
            for z,glyph in enumerate([None,0,4,8,8,12,16],1):
                for q,(dy,dx) in enumerate([(0,0),(0,1),(1,0),(1,1)]):pixelcell(d,10+dy,2+3*z+dx,[0]*8 if glyph is None else self.patterns[glyph+q],[0,1,5,6,4,7,5][z-1])
            self.capture_stage();return
        if name=='tile':
            self.m.statement('RUN');self.wait('9 STOP');d=bitmap(self.m)
            for q,(dy,dx) in enumerate([(0,0),(0,1),(1,0),(1,1)]):pixelcell(d,10+dy,15+dx,self.patterns[8+q],6)
            self.capture_stage();return
        self.start();self.capture_stage()
        if unit==2:
            self.m.statement('CLS');self.m.statement('GO SUB 1000');self.m.frames(1200);self.check()
            if name=='player':
                self.m.statement('LET pr = 3: LET pc = 5: GO SUB 1000');self.model.update(pr=3,pc=5);self.check();self.capture_stage('-on-target')
                self.m.statement('LET pr = 6: LET pc = 3: GO SUB 1000');self.model=ref.initial();self.check()
            return
        for k in 'lixkk':self.move(k,180 if k=='l' else 12)
        self.m.call('press_keys',keys=['i','l'],hold_frames=100);self.m.frames(100);self.check()
        if name=='walk':
            # Re-enter a declared open-edge fixture and verify bounds before index.
            self.fixture({60:'LET g(7,4) = 0: LET g(8,4) = 0'}, {**ref.initial(),'grid':[v if i not in [19,27,59] else 0 for i,v in enumerate(ref.initial()['grid'])]})
            for k in 'lkkk':self.move(k)
            self.restore([60]);self.stop();return
        self.restart()
        for k in 'ilklii':self.move(k)
        if name=='push':assert self.model['won']==0 and self.model['grid'][3*8+4]==3
        elif name in ['targets','counter']:assert self.model['won']==0 and self.model['grid'].count(4)==1
        else:assert self.model['won']==1
        self.capture_stage('-delivery')
        if unit<=6:
            self.restart()
            # Two adjacent targets exercise floor/target transitions without
            # an early win; another uncovered target keeps completion inactive.
            g=[int(r in [1,8] or c in [1,8]) for r in range(1,9) for c in range(1,9)]
            cells=[(3,3,3),(3,4,2),(3,5,2),(6,6,3)]
            for r,c,v in cells:g[(r-1)*8+c-1]=v
            self.fixture({60:'LET g(3,3) = 3: LET g(3,4) = 2: LET g(3,5) = 2',70:'LET g(6,6) = 3',80:'LET pr = 3: LET pc = 2: LET moves = 0: LET won = 0'},{'grid':g,'pr':3,'pc':2,'moves':0,'won':0,'room':1})
            for k in 'lllkij':self.move(k)
            self.capture_stage('-target-transitions');self.restore([60,70,80])
        if name=='loader':
            self.restart();self.check();self.record('map-loader-equivalent-to-accepted-room-1')
        if name=='validation':self.invalid_maps()
        if name in ['two-rooms','three-rooms']:
            for room in range(2,3 if name=='two-rooms' else 4):
                self.key('N',180);self.model=ref.initial(room);self.check();self.capture_stage(f'-room-{room}');self.move('n')
                if room==2:
                    for k in 'jil':self.move(k)
                    assert ref.solve(self.model) is None
                    self.restart('R',180)
                else:self.move('i')
                path=ref.solve(ref.initial(room))
                for k in path:self.move(k)
                assert self.model['won']==1;self.capture_stage(f'-room-{room}-solved')
                for k in 'ijkl':self.move(k)
                self.restart();assert self.model['room']==room
                for k in path:self.move(k)
            self.key('n',180);self.model=ref.initial();self.check();self.capture_stage('-new-game')
        self.stop()
    def invalid_maps(self):
        self.stop()
        cases=[('short',{8010:'#-----#'},'Use eight symbols'),('long',{8010:'#-------#'},'Use eight symbols'),('symbol',{8010:'#--X---#'},'Unknown map'),('no-player',{8050:'#------#'},'exactly one player'),('two-players',{8010:'#P-----#'},'exactly one player'),('no-crates',{8040:'#------#'},'at least one crate'),('unequal',{8010:'#C-----#'},'Match crates')]
        for label,edits,text in cases:
            for n,row in edits.items():self.m.statement(f'{n} DATA "{row}"')
            self.m.statement('RUN');self.wait('S starts. Q quits.');self.key('s');self.wait(text);self.wait('9 STOP');assert ref.state(self.m)['won']==0
            self.capture_stage('-invalid-'+label)
            for n in edits:self.m.statement(self.program[n])
        # Empty final row data is a ROM authoring error, not caught by our validator.
        self.m.statement('8070');self.m.statement('RUN');self.wait('S starts. Q quits.');self.key('s');self.wait('Out of DATA');self.capture_stage('-missing-data');self.m.statement(self.program[8070])
        # Combined symbols count towards crate/goal/player totals.
        edits={8020:'#--#*--#',8050:'#-+----#'}
        for n,row in edits.items():self.m.statement(f'{n} DATA "{row}"')
        model=ref.initial();model['grid'][2*8+4]=4;model['grid'][5*8+2]=2
        self.start(model);self.capture_stage('-combined-symbols');self.stop()
        for n in edits:self.m.statement(self.program[n])
        # A structurally valid pre-solved room may finish immediately; an empty
        # room was rejected above. The player must still be present.
        for n,row in {8020:'#--#*--#',8040:'#------#'}.items():self.m.statement(f'{n} DATA "{row}"')
        model=ref.initial();model['grid'][2*8+4]=4;model['grid'][4*8+3]=0;model['won']=1
        self.start(model);self.capture_stage('-already-delivered');self.stop()
        for n in [8020,8040]:self.m.statement(self.program[n])
        self.start();self.record('map-validation-errors-combined-symbols-and-valid-completion')
    def execute(self):
        roster=json.loads((ROOT/'roster.json').read_text());cache=self.output/'cache';cache.mkdir(exist_ok=True)
        for stage in roster:
            self.stage=stage;program=lines(ROOT/stage['source']);tape=cache/(stage['name']+'.tap');meta=tape.with_suffix('.json')
            if tape.exists() and meta.exists() and json.loads(meta.read_text())['source_sha256']==sha(ROOT/stage['source']):
                evidence=json.loads(meta.read_text());assert sha(tape)==evidence['tape_sha256'];self.m.close();self.m=Spectrum(self.executable,self.output)
                self.m.call('load_media',slot='tape-1',kind='tape',path=str(tape));self.m.statement('LOAD "'+evidence.get('tape_name','crateswork')+'"');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('0 OK')
                assert self.m.program_lines()=={int(n):v for n,v in evidence['stored'].items()};self.program=program
            else:self.patch(program);self.save_cache(tape,meta)
            stored=self.m.program_lines();self.run_stage();assert self.m.program_lines()==stored
            self.results.append({'name':stage['name'],'source':stage['source'],'sha256':sha(ROOT/stage['source']),'status':'passed'})
            (self.output/'progress.json').write_text(json.dumps(self.results,indent=2)+'\n');print('PASS checkpoint',stage['name'],flush=True)
        self.m.statement('SAVE "crates" LINE 10');self.m.enter();self.wait('0 OK');tape=self.output/'crates.tap';self.m.call('save_tape',path=str(tape));keep_program(tape,'crates')
        stored=self.m.program_lines();self.m.close();self.m=Spectrum(self.executable,self.output)
        self.m.call('load_media',slot='tape-1',kind='tape',path=str(tape));self.m.statement('LOAD "crates"');self.m.call('media_transport',slot='tape-1',transport='start');self.wait('S starts. Q quits.');assert self.m.program_lines()==stored
        self.capture('final-instructions');self.key('s');self.model=ref.initial();self.check()
        for room in [1,2,3]:
            if room>1:self.key('n',180);self.model=ref.initial(room);self.check()
            for k in ref.solve(ref.initial(room)):self.move(k)
        self.key('n',180);self.model=ref.initial();self.check();self.quit();self.record('final-fresh-load-three-rooms-new-game-exit')
        rom=[]
        for addr in range(0,16384,128):rom+=self.m.call('memory_read',addr=addr,len=128)['bytes']
        (self.output/'results.json').write_text(json.dumps({'status':'passed','configuration':'48K ZX Spectrum PAL; ROM entry and tape save/load; read-only observations','server':self.m.server,'binary_sha256':sha(Path(self.executable)),'rom_sha256':hashlib.sha256(bytes(rom)).hexdigest(),'prototype_sha256':sha(ROOT.parent/'prototype/crates.bas'),'checkpoints':self.results,'checks':self.checks,'trace':self.trace,'tape_sha256':sha(tape),'limits':'No original hardware or learner-comprehension claim. Declared fixtures restored. GOALS cue awaits native review.'},indent=2)+'\n')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True);r=Review(a.emulator,a.output)
    try:r.execute()
    except Exception:r.capture('failure');raise
    finally:r.m.close()
