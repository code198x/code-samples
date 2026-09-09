#!/usr/bin/env python3
"""Execute Bright Spark checkpoints and complete games through the 48K ROM.

All source and test-only edits use keyboard entry. Inputs use MCP key events;
this is not native host-event or subjective listening acceptance.
"""
import argparse
import hashlib
import importlib.util
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('prototype', ROOT.parent / 'prototype/verification/verify.py')
prototype = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prototype)


class Spectrum(prototype.Spectrum):
    def statement(self, line):
        normal = {'PRINT':'p','LET':'l','RUN':'r','SAVE':'s','LOAD':'j','INPUT':'i',
                  'CLS':'v','IF':'u','GO TO':'g','GO SUB':'h','RETURN':'y','BORDER':'b',
                  'FOR':'f','NEXT':'n','PAUSE':'m','RANDOMIZE':'t'}
        symbol = {'THEN':'g','<>':'w','STOP':'a','AT':'i','TO':'f'}
        extended = {'INKEY$':'n','LEN':'k','VAL':'j','STR$':'y','INT':'r','RND':'t'}
        shifted = {'PAPER':'c','INK':'x','BEEP':'z','BRIGHT':'b'}
        tokens = sorted([*normal,*symbol,*extended,*shifted], key=len, reverse=True)
        for part in re.split(r'("[^"]*"|'+'|'.join(re.escape(t) for t in tokens)+')', line):
            if part in normal: self.key(normal[part])
            elif part in symbol: self.key('symbol',symbol[part])
            elif part in extended: self.key('caps','symbol'); self.key(extended[part])
            elif part in shifted: self.key('caps','symbol'); self.key('symbol',shifted[part])
            else: self.text(part)
        self.enter()


class Check:
    def __init__(self, binary, output):
        self.m = Spectrum(binary, output)
        self.previous = {}
        self.hashes = {}
        self.history = []
        self.last = None
        self.frame = 0
        self.rows = self.m.screen()
        self.cases = []

    def key(self, name, down):
        self.m.call('input', events=[{'Key': {'name': name, 'pressed': down}}])

    def tick(self, count=1):
        for _ in range(count):
            self.m.frames(1)
            self.frame += 1
            self.rows = self.m.screen()
            positions = [(r,c) for r,row in enumerate(self.rows) for c,ch in enumerate(row) if ch=='*']
            panel = {(5,7):1,(5,23):2,(14,7):3,(14,23):4}.get(positions[0]) if positions else None
            if panel != self.last:
                self.history.append({'frame':self.frame,'panel':panel,'phase':self.rows[18].strip()})
                self.last = panel
            # CLS on replay clears the bitmap before the old status text has
            # necessarily disappeared. Require labels during cues, not during
            # that intentional transition. Check the resting board at YOUR TURN.
            if panel is not None:
                self.m.labels()
        return self.rows

    def has(self, text):
        return any(text in row for row in self.rows)

    def wait(self, predicate, limit=2500):
        for _ in range(limit):
            if predicate(): return
            self.tick()
        raise AssertionError(('timeout',self.rows,self.history[-10:]))

    def edit(self, relative):
        path = ROOT / relative
        current = {int(line.split()[0]):line for line in path.read_text().splitlines()}
        for number in sorted(self.previous.keys()-current.keys()):
            self.m.statement(str(number)); self.m.frames(60)
        for number,line in current.items():
            if self.previous.get(number)!=line:
                self.m.statement(line); self.m.frames(60)
        self.previous = current
        self.hashes[relative] = hashlib.sha256(path.read_bytes()).hexdigest()

    def run(self, seed=None):
        if seed is not None: self.m.statement(f'RANDOMIZE {seed}')
        self.m.statement('RUN')
        self.history=[]; self.last=None; self.frame=0
        self.rows=self.m.screen()

    def tap(self, key, frames=2):
        self.key(key,True); self.tick(frames); self.key(key,False)

    def answer(self, digit, hold=2):
        self.tap(str(digit),hold)
        self.wait(lambda:self.last is not None,150)
        assert self.last==int(digit),(digit,self.last)
        self.wait(lambda:self.last is None,150)
        self.tick(35)

    def watch(self):
        self.wait(lambda:self.has('YOUR TURN'))
        self.m.labels()
        return ''.join(str(h['panel']) for h in self.history if h['panel'] and h['phase'].startswith('WATCH'))

    def record(self, name, expected=(), capture=False):
        self.m.check(name, list(expected),capture=capture)
        self.cases.append({'name':name,'transitions':self.history.copy()})

    def quit(self):
        self.key('q',True)
        self.wait(lambda:self.has('9 STOP'),250)
        self.key('q',False); self.tick(20)
        assert self.has('Finished.'),self.rows

    def stop(self):
        if not self.has('9 STOP'):self.quit()

    def playback_only(self, sequence, mode='none'):
        self.m.statement(f'280 LET s$="{sequence}"')
        self.run()
        if mode=='held':self.key('2',True)
        start=None
        for n in range(1500):
            if mode=='tapping' and n%4==0:self.key('2',True)
            if mode=='tapping' and n%4==2:self.key('2',False)
            self.tick()
            if mode=='quit' and self.last and start is None:
                self.key('q',True);start=self.frame
            if self.has('9 STOP'):break
        else:raise AssertionError(self.rows)
        for key in ['2','q']:self.key(key,False)
        seen=[h['panel'] for h in self.history if h['panel']]
        assert seen==([int(sequence[0])] if mode=='quit' else list(map(int,sequence))),seen
        gaps=[b['frame']-a['frame'] for a,b in zip(self.history,self.history[1:]) if a['panel'] is None]
        if gaps:assert min(gaps)>=8,gaps
        self.record(f'playback-{sequence}-{mode}')
        if start:self.cases[-1]['q_exit_frames']=self.frame-start


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--emulator',required=True)
    p.add_argument('--output',required=True,type=Path)
    a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
    c=Check(a.emulator,a.output)
    try:
        c.edit('unit-03/steps/step-03.bas');c.run();c.wait(lambda:c.has('9 STOP'))
        for unit in range(4,8):
            for step in [1,2]:
                relative=f'unit-{unit:02}/steps/step-{step:02}.bas'
                c.edit(relative);c.run(seed=1234 if unit>=6 else None)
                if unit==4:
                    c.wait(lambda:c.has('9 STOP'))
                    assert [h['panel'] for h in c.history if h['panel']]==[3,1,4]
                elif (unit,step)==(5,1):
                    c.wait(lambda:c.has('YOUR TURN'));c.tap('x');c.tick(30)
                    assert c.has('YOUR TURN') and not c.last
                    c.answer(2);c.wait(lambda:c.has('9 STOP'))
                    assert c.has('You chose 2')
                else:
                    if unit==7:
                        c.wait(lambda:c.has('then s to start.'))
                        c.tap('s');c.tick(30)
                    sequence=c.watch()
                    assert sequence and set(sequence)<=set('1234'),sequence
                    for digit in sequence:c.answer(digit)
                    if unit==5 or (unit,step)==(6,1):c.wait(lambda:c.has('9 STOP'))
                    else:c.quit()
                c.record(f'checkpoint-{unit}-{step}',capture=True)
        # Playback checks on the actual lesson checkpoint, with declared line edits.
        c.edit('unit-04/steps/step-02.bas')
        for sequence,mode in [('314','none'),('22','none'),('1234','none'),('22','held'),('22','tapping'),('22','quit')]:
            c.playback_only(sequence,mode)
        c.m.statement('280 LET s$="314"')
        # Fixed comparisons: first, middle and last mismatch; then correct.
        c.edit('unit-05/steps/step-02.bas')
        for response in ['114','324','311','314']:
            c.run();assert c.watch()=='314'
            for expected,digit in zip('314',response):
                c.answer(digit)
                if expected!=digit:break
            c.wait(lambda:c.has('9 STOP'))
            c.record('fixed-response-'+response,['Order complete.' if response=='314' else 'Different choice.'])
        # Repeated input, irrelevant input, idle readiness and a held phase key.
        c.m.statement('280 LET s$="22"');c.run();c.key('2',True)
        c.wait(lambda:c.has('Release the keys.'))
        c.tick(80);assert not c.has('YOUR TURN')
        c.key('2',False);c.wait(lambda:c.has('YOUR TURN'))
        before=len(c.history);c.tick(100);c.tap('x');c.tick(50)
        assert len(c.history)==before and c.has('YOUR TURN')
        c.key('2',True);c.wait(lambda:c.last==2);c.tick(150)
        assert c.has('YOUR TURN') and not c.has('Order complete.')
        c.key('2',False);c.tick(35);c.answer('2')
        c.wait(lambda:c.has('9 STOP'));c.record('held-repeated-and-phase-release',['Order complete.'])
        # Ordinary quit while waiting for a choice.
        c.run();c.watch();c.quit();c.record('quit-input',['Finished.'])
        c.m.statement('280 LET s$="314"')
        # Final unchanged source, all 16 rounds, observing random playback to answer.
        c.edit('unit-07/steps/step-02.bas')
        c.run(seed=1234);c.wait(lambda:c.has('then s to start.'));c.quit();c.record('quit-title')
        c.run(seed=1234);c.wait(lambda:c.has('then s to start.'))
        c.tap('x');c.tick(30);assert c.has('then s to start.')
        c.key('s',True);c.tick(80);assert not any(h['panel'] for h in c.history)
        c.key('s',False)
        prefix='';offset=0
        for round_number in range(1,17):
            all_seen=c.watch();sequence=all_seen[offset:];offset=len(all_seen)
            assert len(sequence)==round_number and sequence.startswith(prefix),(round_number,sequence,prefix)
            assert set(sequence)<=set('1234')
            for digit in sequence:c.answer(digit)
            prefix=sequence
            if round_number<16:c.wait(lambda:c.has('WATCH'))
            print('PASS full round',round_number,sequence,flush=True)
        c.wait(lambda:c.has('r replay, q quit.'))
        assert c.has('Challenge complete.') and c.has('Rounds completed: 16')
        last_count=len(c.history);c.tick(300);assert len(c.history)==last_count
        c.record('sixteen-round-ending',['Challenge complete.','Rounds completed: 16'],capture=True)
        c.tap('r');c.tick(30)
        # A replay starts without returning through RUN or reseeding.
        c.wait(lambda:c.has('YOUR TURN'))
        all_seen=''.join(str(h['panel']) for h in c.history if h['panel'] and h['phase'].startswith('WATCH'))
        sequence=all_seen[-1:]
        assert c.has('Rounds completed: 0')
        c.answer(str(int(sequence)%4+1));c.wait(lambda:c.has('r replay, q quit.'))
        c.record('replay-first-round-failure',['Different choice.','Rounds completed: 0'],capture=True)
        c.tap('r');c.tick(25)
        # Complete three rounds, then fail the fourth.
        for round_number in range(1,5):
            c.wait(lambda:c.has('YOUR TURN'))
            seen=''.join(str(h['panel']) for h in c.history if h['panel'] and h['phase'].startswith('WATCH'))
            sequence=seen[-round_number:]
            if round_number==4:c.answer(str(int(sequence[0])%4+1))
            else:
                for digit in sequence:c.answer(digit)
                c.wait(lambda:c.has('WATCH'))
        c.wait(lambda:c.has('r replay, q quit.'))
        c.record('fourth-round-failure',['Rounds completed: 3','Different choice.'])
        c.quit();c.record('quit-result')
        # Named SAVE and LOAD in a fresh emulator process, with the final source intact.
        c.m.statement('SAVE "spark16"');c.m.enter();c.m.frames(12000)
        c.m.check('save-final',['0 OK'],capture=False)
        tape=a.output/'spark16.tap';c.m.call('save_tape',path=str(tape))
        c.m.close();c.m=Spectrum(a.emulator,a.output)
        c.m.call('load_media',slot='tape-1',kind='tape',path=str(tape))
        c.m.statement('LOAD "spark16"');c.m.call('media_transport',slot='tape-1',transport='start')
        c.m.frames(12000);c.m.check('load-final',['0 OK'],capture=False)
        c.run();c.wait(lambda:c.has('then s to start.'));c.tap('s');c.tick(30)
        sequence=c.watch();assert len(sequence)==1
        c.answer(str(int(sequence)%4+1));c.wait(lambda:c.has('r replay, q quit.'))
        c.tap('r');c.tick(30);c.wait(lambda:c.has('YOUR TURN'));c.quit()
        c.record('fresh-tape-play-replay-quit',['Finished.'])
        (a.output/'results.json').write_text(json.dumps({
            'status':'passed','server':c.m.server,'source_hashes':c.hashes,
            'binary_sha256':hashlib.sha256(Path(a.emulator).read_bytes()).hexdigest(),
            'method':'48K, 50 Hz; ROM entry and sequential edits; MCP key events and frame-by-frame screen-memory observations. Random game seeded with RANDOMIZE 1234, no game variables injected. Declared fixed-sequence tests edit line 280 then restore it. Final tape saved and loaded in a fresh process.',
            'checks':c.cases,'screens':c.m.evidence,
            'limits':'No original hardware, native host-event testing or subjective listening. Marker transitions observe screen memory, not completed raster output.'
        },indent=2)+'\n')
    finally:c.m.close()


if __name__=='__main__':main()
