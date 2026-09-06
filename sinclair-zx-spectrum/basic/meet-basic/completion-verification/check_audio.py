#!/usr/bin/env python3
"""Measure sustained notes in the MCP captures; this is not a listening test."""
import argparse,hashlib,json,struct,wave
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('directory',type=Path);a=p.parse_args();captures=[]
for f in sorted(a.directory.glob('*.wav')):
 with wave.open(str(f)) as w:
  assert w.getnchannels()==1 and w.getsampwidth()==2
  rate=w.getframerate();values=struct.unpack('<'+'h'*w.getnframes(),w.readframes(w.getnframes()))
 windows=[(1.92,1.95,261.6)] if 'cue' in f.name else [(.41,.47,261.6),(1.50,1.56,130.8),(2.56,2.62,523.3)]
 notes=[]
 for start,end,expected in windows:
  segment=values[int(start*rate):int(end*rate)];mean=sum(segment)/len(segment)
  crossings=sum(segment[i-1]<mean<=segment[i] for i in range(1,len(segment)))
  measured=crossings/(len(segment)/rate)
  assert abs(measured-expected)<35,(f,measured,expected)
  notes.append({'window_seconds':[start,end],'estimated_hz':measured,'expected_hz_approximately':expected})
 captures.append({'file':f.name,'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'notes':notes,'peak':max(abs(v) for v in values)})
assert len(captures)==3, 'Expected two feedback recordings and one Oracle cue'
print(json.dumps({'status':'passed','method':'Positive zero crossings in short sustained-note windows from the verified MCP input sequence. Not listening, exact pitch measurement, or native audio output verification.','captures':captures},indent=2))
