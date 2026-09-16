#!/usr/bin/env python3
"""Execute all teaching states with ROM keyboard entry; save and reload endpoint."""
import argparse, hashlib, json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from bands import Bands, clue, CELLS
from entry import Spectrum
from verify import sha

class Teaching(Bands):
    def __init__(self,executable,output):
        super().__init__(executable,output)
        self.old={};self.roster=json.loads((ROOT/'roster.json').read_text());self.sources={}
    def edit(self,item):
        source=ROOT/item['source'];new={int(s.split()[0]):s for s in source.read_text().splitlines()}
        for n in self.old.keys()-new.keys():self.machine.statement(str(n))
        for n,s in new.items():
            if self.old.get(n)!=s:self.machine.statement(s)
        assert set(self.machine.program_lines())==set(new),(item,self.machine.screen())
        self.old=new;self.sources[item['source']]=sha(source)
        print('ENTERED',item['name'],flush=True)
    def capture(self,name):
        self.machine.frames(100)
        super().capture(name)
    def simple_probe(self,row,col,kind):
        self.answer(str(row));self.wait('Column (1-8, Q):');self.answer(str(col));self.wait('Row (1-8, Q):')
        target=self.numeric();distance=abs(row-target['tr'])+abs(col-target['tc'])
        value=int(distance) if kind=='distance' else clue((row,col),(target['tr'],target['tc'])) if kind=='bands' else int(distance!=0)
        glyph=' *' if value==0 else f'{value:2}' if kind=='distance' else [' *',' N',' M',' F'][value] if kind=='bands' else ' -'
        rows=self.machine.screen();y,x=4+2*(row-1),5+3*(col-1)
        assert rows[y][x:x+3]=='>'+glyph,rows
        self.board()
        return value
    def remembered_probe(self,row,col,ending=False,count=True):
        target=self.numeric();expected=clue((row,col),(target['tr'],target['tc']))
        self.answer(str(row));self.wait('Column (1-8, Q):');self.answer(str(col));self.wait('R another round, Q quits:' if ending and expected==0 else 'Row (1-8, Q):')
        self.known[row,col]=expected;self.latest=(row,col)
        rows=self.machine.screen();self.board()
        for r,c in CELLS:
            glyph='. ' if (r,c) not in self.known else [' *',' N',' M',' F'][self.known[r,c]]
            marker='>' if (r,c)==self.latest else ' '
            assert rows[4+2*(r-1)][5+3*(c-1):8+3*(c-1)]==marker+glyph,(r,c,rows)
        if count:assert self.numeric()['n']==len(self.known)
    def check_invalid(self):
        before=self.numeric()
        for prompt in ['Row','Column']:
            if prompt=='Column':self.answer('3');self.wait('Column (1-8, Q):')
            for value in ['', '0','9','x','1.5','1+1','1'*80]:
                self.answer(value);self.wait(prompt+' (1-8, Q):');self.board()
                assert 'Use one digit from 1 to 8.' in self.machine.screen()[21]
            if prompt=='Column':assert self.numeric()['pr']==3
        self.answer('6');self.wait('Row (1-8, Q):')
        after=self.numeric();assert (before['tr'],before['tc'])==(after['tr'],after['tc'])
    def execute(self,baseline):
        rom=[]
        for address in range(0,16384,128):rom+=self.machine.call('memory_read',addr=address,len=128)['bytes']
        for item in self.roster:
            self.edit(item);name=item['name'];self.machine.statement('RUN')
            if name in ['row','board','array-lab']:
                self.wait('9 STOP')
                rows=self.machine.screen()
                if name=='row':assert rows[4][5:29]==' . '*8,rows
                elif name=='board':self.board();assert rows[8][20:23]==' X ',rows
                else:
                    text='\n'.join(rows[:4]);assert rows[0].strip()=='0' and rows[1].strip()=='-1 -1' and rows[2].strip()=='3 -1',text
                self.capture(name);self.record(name);continue
            ending=name in ['round','random']
            if ending:self.wait('ENTER to search, Q quits:');self.capture(name+'-instructions');self.answer('')
            self.wait('Row (1-8, Q):')
            if name=='row-input':
                for value in ['','0','9','x','1'*80]:self.answer(value);self.wait('Row (1-8, Q):');self.board()
                self.answer('5');self.wait('Row (1-8, Q):');assert self.numeric()['pr']==5
            elif name in ['probe','distance','bands']:
                for r,c in [(1,2),(8,8),(3,6)]:self.simple_probe(r,c,name)
                self.check_invalid()
                if name=='bands':
                    self.quit();self.machine.statement('20 LET tr = 1: LET tc = 1');self.machine.statement('RUN');self.wait('Row (1-8, Q):')
                    for r,c in [(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),(8,8)]:self.simple_probe(r,c,'bands')
                    self.quit();self.machine.statement(self.old[20]);self.machine.statement('RUN');self.wait('Row (1-8, Q):');self.simple_probe(1,2,'bands')
            elif name in ['memory','count']:
                self.known={};self.latest=None
                probes=CELLS+[(1,2)] if name=='memory' else [(1,2),(8,8),(1,2),(3,6),(3,6)]
                for r,c in probes:self.remembered_probe(r,c,count=name=='count')
                before=self.numeric();self.answer('1'*80);self.wait('Row (1-8, Q):')
                self.remembered_probe(1,2,count=name=='count')
                self.quit();self.machine.statement('CLS');self.machine.statement('GO SUB 1000');self.machine.frames(500)
                if name=='count':self.board_state()
                for key in ['tr','tc','lr','lc']:assert before[key]==self.numeric()[key] or key in ['lr','lc']
                self.machine.statement('GO TO 100');self.wait('Row (1-8, Q):')
            else:
                self.stage=6;self.reset_model()
                for _ in range(4):self.solve();self.replay()
                self.solve()
            self.capture(name);self.quit();self.record(name)
        stored=self.machine.program_lines()
        self.machine.statement('SAVE "sonarteach" LINE 10');self.machine.enter();self.wait('0 OK',limit=16000)
        tape=self.output/'sonar-teaching.tap';self.machine.call('save_tape',path=str(tape));self.machine.close()
        self.machine=Spectrum(self.executable,self.output)
        self.machine.call('load_media',slot='tape-1',kind='tape',path=str(tape));self.machine.statement('LOAD "sonarteach"');self.machine.call('media_transport',slot='tape-1',transport='start');self.wait('ENTER to search, Q quits:',limit=16000)
        assert self.machine.program_lines()==stored
        self.answer('');self.reset_model();self.solve();self.capture('final-found');self.replay();self.quit()
        self.record('fresh-load-play-retry-exit')
        self.machine.close();self.machine=Spectrum(self.executable,self.output)
        self.machine.call('load_media',slot='tape-1',kind='tape',path=str(baseline));self.machine.statement('LOAD "sonarband"');self.machine.call('media_transport',slot='tape-1',transport='start');self.wait('ENTER to search, Q quits:',limit=16000)
        assert self.machine.program_lines()==stored
        self.record('stored-program-identical-to-accepted-game',baseline_sha256=sha(baseline))
        result={'status':'passed','server':self.machine.server,'binary_sha256':sha(Path(self.executable)),'rom_sha256':hashlib.sha256(bytes(rom)).hexdigest(),'configuration':'48K Spectrum PAL; source entered through ROM keyboard events','sources':self.sources,'tape_sha256':sha(tape),'checks':self.cases,'limits':'Scripted execution and inspected captures. No new human play, audio or original-hardware claim.'}
        (self.output/'results.json').write_text(json.dumps(result,indent=2)+'\n')

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--emulator',required=True);parser.add_argument('--baseline',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);a=parser.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True)
    review=Teaching(a.emulator,a.output)
    try:review.execute(a.baseline.resolve())
    except Exception:review.capture('failure');raise
    finally:review.machine.close()
