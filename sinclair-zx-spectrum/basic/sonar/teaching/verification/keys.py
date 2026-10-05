#!/usr/bin/env python3
"""Check lesson 10's single-key entry: one press is one choice, nothing scrolls.

Run on its own against a built tape, or from verify.py after the lesson 10
edits are entered through the ROM editor. The lesson 8 game fails this check:
it waits for typed answers and ENTER, so a single key press makes no choice.
"""
import argparse, json, sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from bands import Bands, clue
from entry import Spectrum
from verify import sha

ROW='Row (1-8, Q):'
COLUMN='Column (1-8, Q):'
REPLAY='R another round, Q quits:'
START='Any key to search, Q quits.'

class Keys(Bands):
    def press(self,key,hold=6):
        # A real press: the key goes down for `hold` frames, then up. INKEY$
        # reads the keyboard live, so the program must see both edges.
        self.machine.call('press_key',key=key,hold_frames=hold)
        self.machine.frames(20)
    def lower(self):
        rows=self.machine.screen();return rows[22].rstrip(),rows[23].rstrip()
    def until(self,test,limit=2000):
        for _ in range(limit//10):
            if test():return
            self.machine.frames(10)
        raise AssertionError(self.machine.screen())
    def row_prompt(self):
        self.until(lambda:self.lower()==(ROW,''))
    def reset_model(self):
        self.known={};self.latest=None
        self.row_prompt();self.board_state()
        assert 'N=1-2, M=3-4, F=5+ steps.' in self.machine.screen()[21]
    def probe(self,row,col,hold=6):
        target=self.numeric();expected=clue((row,col),(target['tr'],target['tc']))
        repeated=(row,col) in self.known;before=self.numeric()['n']
        self.row_prompt();self.press(str(row))
        # The row is echoed beside its prompt and the column prompt appears below.
        self.until(lambda:self.lower()==(f'{ROW} {row}',COLUMN))
        self.press(str(col),hold)
        if expected==0:self.until(lambda:self.lower()==(REPLAY,''))
        else:self.row_prompt()
        self.known[(row,col)]=expected;self.latest=(row,col)
        self.board_state()
        assert self.numeric()['n']==before+(0 if repeated else 1)
        status=(f'Found in {len(self.known)} distinct probes.' if expected==0
                else 'Already probed. No extra count.' if repeated
                else ['','Near: 1 or 2 steps away.','Medium: 3 or 4 steps away.','Far: at least 5 steps away.'][expected])
        assert status in self.machine.screen()[21],self.machine.screen()
        return expected
    def replay(self,key='r'):
        self.press(key);self.reset_model()
    def quit(self,key='q'):
        self.press(key);self.wait('9 STOP')
        assert self.has('Finished.'),self.machine.screen()
    def invalid(self,key,lower):
        before=self.numeric()
        self.press(key);self.machine.frames(30)
        assert 'Use one digit from 1 to 8.' in self.machine.screen()[21],self.machine.screen()
        assert self.lower()==lower,self.machine.screen()
        self.board_state()
        after=self.numeric()
        for name in ['tr','tc','n','lr','lc','pr']:assert before[name]==after[name],(name,before,after)
    def check_keys(self,capture=True,limit=2000):
        """From the instructions: keys, echo, release, invalid keys, round, retry, quit."""
        self.until(lambda:self.has(START) or self.has('ENTER to search'),limit)
        instructions=self.machine.screen()
        if capture:self.capture('keys-instructions')
        self.press('enter')
        self.until(lambda:any(line.startswith(ROW) for line in self.lower()))
        self.known={};self.latest=None;self.board_state()
        # One press, no ENTER: the row is chosen and echoed beside its prompt.
        self.press('3')
        self.until(lambda:self.lower()==(f'{ROW} 3',COLUMN))
        assert self.numeric()['pr']==3
        # The instructions describe the keys, and the unused stage variable is gone.
        assert START in instructions[22] and 'Press a row key, then a column.' in instructions[7],instructions
        assert 'stage' not in self.numeric(),self.numeric()
        if capture:self.capture('keys-column')
        self.invalid('x',(f'{ROW} 3',COLUMN))
        # Hold the column key for three seconds. Without the release wait the
        # same key would be read again as the next row.
        target=self.numeric();expected=clue((3,6),(target['tr'],target['tc']))
        self.press('6',hold=150)
        self.until(lambda:self.lower()==((REPLAY,'') if expected==0 else (ROW,'')))
        self.known[(3,6)]=expected;self.latest=(3,6);self.board_state()
        values=self.numeric();assert (values['pr'],values['pc'],values['n'])==(3,6,1),values
        # (A one-in-64 target at 3,6 ends the round here; start another.)
        if expected==0:self.replay()
        # Keys outside 1-8 are refused without moving the prompt or the board.
        for key in ['0','9','x','enter','space']:self.invalid(key,(ROW,''))
        self.record('single-key-entry-echo-release-invalid-keys')
        # Repeat a probe, then finish the search key by key from the displayed clues.
        if self.known:
            self.probe(3,6)
            assert 'Already probed. No extra count.' in self.machine.screen()[21]
        self.solve()
        assert self.lower()==(REPLAY,''),self.machine.screen()
        if capture:self.capture('keys-found')
        self.press('x');self.machine.frames(30)
        assert 'Press R for another round or Q.' in self.machine.screen()[21],self.machine.screen()
        assert self.lower()==(REPLAY,''),self.machine.screen()
        self.replay()
        self.quit()
        self.record('keyed-round-replay-reminder-retry-quit')

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('--emulator',required=True);parser.add_argument('--tape',type=Path,required=True);parser.add_argument('--output',type=Path,required=True);parser.add_argument('--capture',action='store_true',help='save screenshots of the instructions, column prompt and discovery')
    a=parser.parse_args();a.output=a.output.resolve();a.output.mkdir(parents=True,exist_ok=True)
    review=Keys(a.emulator,a.output)
    try:
        review.machine.call('load_media',slot='tape-1',kind='tape',path=str(a.tape.resolve()));review.machine.statement('LOAD ""');review.machine.call('media_transport',slot='tape-1',transport='start')
        review.check_keys(capture=a.capture,limit=16000)
        (a.output/'keys-results.json').write_text(json.dumps({'status':'passed','tape_sha256':sha(a.tape),'checks':review.cases},indent=2)+'\n')
    except Exception:review.capture('keys-failure');raise
    finally:review.machine.close()
