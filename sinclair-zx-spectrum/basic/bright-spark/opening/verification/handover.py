#!/usr/bin/env python3
"""Verify C01c: held-q timing, full game, repeated replay and fresh TAP load."""
import argparse
import hashlib
import json
from pathlib import Path
from completion import Check, Spectrum, ROOT

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--emulator', required=True)
p.add_argument('--output', required=True, type=Path)
a=p.parse_args()
a.output=a.output.resolve()
a.output.mkdir(parents=True, exist_ok=True)
c=Check(a.emulator,a.output)
try:
    c.edit('unit-04/steps/step-02.bas')
    delays=[]
    for duration in ['0.15','0.45','0.15']:
        c.m.statement(f'920 BEEP {duration},note');c.m.frames(60)
        c.run()
        c.wait(lambda:c.last==3)
        start=c.frame
        c.key('q',True)
        c.wait(lambda:c.has('9 STOP'),250)
        delay=c.frame-start
        c.key('q',False);c.tick(20)
        assert c.has('Finished.') and not c.last
        assert [h['panel'] for h in c.history if h['panel']]==[3]
        delays.append(delay)
        c.record('held-q-'+duration,['Finished.'],capture=True)
        c.cases[-1]['exit_frames_after_first_asterisk']=delay
    assert delays[1]>delays[0]+10,delays
    assert abs(delays[2]-delays[0])<=2,delays
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
        'tape_sha256':hashlib.sha256(tape.read_bytes()).hexdigest(),
        'configuration':'Spectrum 48K PAL default, configured ROM, Emu198x MCP',
        'checks':c.cases,'screens':c.m.evidence,
        'limits':'Frame-by-frame screen-memory and MCP key evidence. Native UI evidence recorded separately. No original hardware or subjective listening claim.'
    },indent=2)+'\n')
finally:
    c.m.close()
