#!/usr/bin/env python3
"""Check final lesson variations and a distinct named final tape from a saved game."""
import argparse
import hashlib
import json
from pathlib import Path
from completion import Check, ROOT

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--emulator',required=True)
p.add_argument('--tape',required=True,type=Path)
p.add_argument('--tape-name',default='spark16')
p.add_argument('--output',required=True,type=Path)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
c=Check(a.emulator,a.output)
try:
    c.m.call('load_media',slot='tape-1',kind='tape',path=str(a.tape))
    c.m.statement(f'LOAD "{a.tape_name}"');c.m.call('media_transport',slot='tape-1',transport='start')
    c.m.frames(12000);c.m.check('load-for-experiments',['0 OK'],capture=False)
    # Save under the exact distinct name used in lesson 7, before test-only edits.
    c.m.statement('SAVE "spark16"');c.m.enter();c.m.frames(12000)
    c.m.check('save-spark16',['0 OK'],capture=False)
    final_tape=a.output/'spark16.tap';c.m.call('save_tape',path=str(final_tape))
    # Short cap is explicitly a boundary experiment; fixed 2s isolate repeated inputs.
    c.m.statement('287 LET cap=2');c.m.frames(60)
    c.m.statement('980 LET s$=s$+"2"');c.m.frames(60)
    c.run();c.wait(lambda:c.has('then s to start.'));c.record('title-screen',capture=True)
    c.tap('s');c.tick(30);assert c.watch()=='2'
    for invalid in ['0','5','x']:
        c.tap(invalid);c.tick(30);assert c.has('YOUR TURN') and c.last is None
    c.answer('2');c.wait(lambda:c.has('WATCH'));c.wait(lambda:c.has('YOUR TURN'))
    c.answer('2');c.answer('2');c.wait(lambda:c.has('r replay, q quit.'))
    c.record('short-cap-and-fresh-repeated-taps',['Challenge complete.','Rounds completed: 2'])
    c.key('r',True);c.tick(100);assert c.has('Challenge complete.')
    c.key('r',False);c.tick(30);c.wait(lambda:c.has('WATCH'))
    c.wait(lambda:c.last is not None);start=c.frame;c.quit()
    c.record('held-replay-release-and-final-playback-quit',['Finished.'])
    c.cases[-1]['q_exit_frames']=c.frame-start-20
    # Vary the third note and duration as the lesson suggests, observing cues.
    c.m.statement('610 LET note=9');c.m.frames(60)
    c.m.statement('920 BEEP 0.1,note');c.m.frames(60)
    c.m.statement('980 LET s$=s$+"3"');c.m.frames(60)
    c.run();c.wait(lambda:c.has('then s to start.'));c.tap('s');c.tick(30)
    c.m.call('start_audio_recording',path=str(a.output/'alternate-note.wav'))
    assert c.watch()=='3';c.answer('3')
    c.wait(lambda:c.has('WATCH'));c.wait(lambda:c.has('YOUR TURN'))
    c.m.call('stop_audio_recording');c.quit()
    c.record('alternate-note-shorter-cue',['Finished.'])
    # Load the pristine export into a fresh process: experiments must not leak.
    c.m.close();from completion import Spectrum
    c.m=Spectrum(a.emulator,a.output)
    c.m.call('load_media',slot='tape-1',kind='tape',path=str(final_tape))
    c.m.statement('LOAD "spark16"');c.m.call('media_transport',slot='tape-1',transport='start')
    c.m.frames(12000);c.m.check('load-spark16',['0 OK'],capture=False)
    c.run(seed=1234);c.wait(lambda:c.has('then s to start.'));c.tap('s');c.tick(30)
    sequence=c.watch();assert len(sequence)==1
    c.answer(str(int(sequence)%4+1));c.wait(lambda:c.has('r replay, q quit.'))
    c.record('named-final-first-round-failure',['Rounds completed: 0'])
    c.tap('r');c.tick(30);c.wait(lambda:c.has('YOUR TURN'));c.quit()
    c.record('named-final-replay-quit',['Finished.'])
    (a.output/'results.json').write_text(json.dumps({
        'status':'passed','server':c.m.server,'checks':c.cases,
        'final_source_sha256':hashlib.sha256((ROOT/'unit-07/steps/step-02.bas').read_bytes()).hexdigest(),
        'input_tape_sha256':hashlib.sha256(a.tape.read_bytes()).hexdigest(),
        'final_tape_sha256':hashlib.sha256(final_tape.read_bytes()).hexdigest(),
        'method':'Named ROM load of completion-run tape; pristine export as spark16; declared ROM edits for cap=2, repeated-digit input and note/duration experiments; final fresh-process LOAD spark16, play, replay and quit.',
        'limits':'No native host events or subjective listening; alternate audio capture demonstrates execution only.'
    },indent=2)+'\n')
finally:c.m.close()
