#!/usr/bin/env python3
"""Count sustained tone bursts in the repeated-panel playback recordings."""
import argparse
import json
import math
import struct
import wave
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('directory',type=Path)
a=p.parse_args();results=[]
for mode in ['none','tapping','held','quit']:
    path=a.directory/f'22-{mode}.wav'
    with wave.open(str(path)) as w:
        assert w.getnchannels()==1 and w.getsampwidth()==2
        rate=w.getframerate()
        values=struct.unpack('<'+'h'*w.getnframes(),w.readframes(w.getnframes()))
    width=rate//100;active=[]
    for i in range(0,len(values),width):
        window=values[i:i+width]
        active.append(math.sqrt(sum(x*x for x in window)/len(window))>5000)
    groups=[]
    for i,on in enumerate(active):
        if on and (i==0 or not active[i-1]):groups.append([i,i+1])
        elif on:groups[-1][1]=i+1
    groups=[g for g in groups if g[1]-g[0]>=5]
    assert len(groups)==(1 if mode=='quit' else 2),(path,groups)
    results.append({'file':path.name,'tone_windows_seconds':[[s*.01,e*.01] for s,e in groups]})
(a.directory/'audio-separation.json').write_text(json.dumps({
    'status':'passed',
    'method':'10 ms RMS windows above 5000 for at least 50 ms identify sustained tones. Signal measurement, not listening.',
    'checks':results},indent=2)+'\n')
