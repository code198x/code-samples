#!/usr/bin/env python3
"""Trace fixed playback, key interference and release hand-off through ROM entry."""
import argparse
import hashlib
import json
from pathlib import Path
from verify import Spectrum, ROOT

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--emulator',required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output)
results=[]
def key(name,pressed):
    m.call('input',events=[{'Key':{'name':name,'pressed':pressed}}])
try:
    source=ROOT/'steps/step-04.bas'
    for line in source.read_text().splitlines():m.statement(line)
    for sequence,mode in [('314','none'),('22','none'),('1234','none'),('22','tapping'),('22','held'),('22','quit')]:
        m.statement(f'140 LET s$="{sequence}"')
        m.statement('RUN')
        # Board construction precedes playback. Input starts before the first cue.
        states=[];changes=[];last=None;quit_start=None
        m.call('start_audio_recording',path=str(a.output/f'{sequence}-{mode}.wav'))
        for frame in range(500):
            if mode=='held' and frame==0:key('2',True)
            if mode=='tapping' and frame%4==0:key('2',True)
            if mode=='tapping' and frame%4==2:key('2',False)
            m.frames(1)
            rows=m.screen()
            if any('WATCH' in r for r in rows):m.labels()
            stars=m.stars()
            panel={(5,7):1,(5,23):2,(14,7):3,(14,23):4}.get(stars[0]) if stars else None
            states.append(panel)
            if panel!=last:
                changes.append({'frame':frame,'panel':panel});last=panel
            if mode=='quit' and panel and quit_start is None:
                key('q',True);quit_start=frame
            if any('YOUR TURN' in r or 'Release the keys.' in r or 'Finished.' in r for r in rows):break
        else:raise AssertionError((sequence,mode,'did not finish'))
        m.call('stop_audio_recording')
        observed=[c['panel'] for c in changes if c['panel']]
        if mode=='quit':
            assert observed==[2],observed
            assert any('Finished.' in r for r in rows),rows
            key('q',False)
        else:
            assert observed==list(map(int,sequence)),(sequence,mode,changes)
            gaps=[changes[j+1]['frame']-c['frame'] for j,c in enumerate(changes[:-1]) if c['panel'] is None]
            assert all(g>=8 for g in gaps),(mode,gaps)
            key('2',False);m.frames(20)
            assert any('YOUR TURN' in r for r in m.screen()),m.screen()
            assert not any('Read:' in r for r in m.screen()),m.screen()
            m.key('3');m.check(f'{sequence}-{mode}-fresh-input',['Read: 3'],capture=False)
        results.append({'sequence':sequence,'input':mode,'transitions':changes,
                        'frames_to_exit_after_q':frame-quit_start if quit_start is not None else None})
        print('PASS playback',sequence,mode,changes,flush=True)
    (a.output/'playback.json').write_text(json.dumps({'status':'passed','server':m.server,
       'source_sha256':hashlib.sha256(source.read_bytes()).hexdigest(),
       'method':'ROM key entry; one screen-memory observation per advanced frame; key events injected through MCP. Rest gaps measure absent active marker, not completed raster repaint. Tapping alternates two frames down/two up. Held input released only after playback.',
       'checks':results},indent=2)+'\n')
finally:m.close()
