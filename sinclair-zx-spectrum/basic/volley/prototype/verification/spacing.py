#!/usr/bin/env python3
"""Re-enter final Volley and prove stored program equivalence without post-token spaces."""
import argparse,hashlib,json
from pathlib import Path
from entry import Spectrum,ROOT,compact_source
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--input-tape',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
def program(path):
 b=path.read_bytes();h=b[2:21];assert h[:2]==b'\0\0';length=int.from_bytes(h[16:18],'little');return b[24:24+length]
def normalise(data,strict=False):
 result=[];i=0
 while i<len(data):
  n=int.from_bytes(data[i:i+2],'big');size=int.from_bytes(data[i+2:i+4],'little');body=data[i+4:i+4+size];i+=4+size;j=0;quoted=False;out=[]
  while j<len(body):
   v=body[j]
   if v==34:quoted=not quoted
   if not quoted and v==14:
    out.extend(body[j:j+6]);j+=6;continue
   if strict and not quoted and v>=165:assert body[j+1:j+2]!=b' ',(n,v,j)
   if quoted or v!=32:out.append(v)
   j+=1
  result.append((n,bytes(out)))
 return result
m=Spectrum(a.emulator,a.output)
def key(k,b):m.call('input',events=[{'Key':{'name':k,'pressed':b}}])
def has(s):return any(s in r for r in m.screen())
def wait(s):
 for _ in range(3000):
  if has(s):m.frames(30);return
  m.frames(1)
 raise AssertionError((s,m.screen()))
try:
 m.call('load_media',slot='tape-1',kind='tape',path=str(a.input_tape));m.statement('LOAD "volley"');m.call('media_transport',slot='tape-1',transport='start');m.frames(6000);assert has('0 OK')
 for line in (ROOT/'steps/step-08.bas').read_text().splitlines():m.statement(line);m.frames(60)
 m.statement('SAVE "volley"');m.enter();m.frames(6000);assert has('0 OK');tape=a.output/'volley.tap';m.call('save_tape',path=str(tape))
 old=program(a.input_tape);new=program(tape)
 assert normalise(old)==normalise(new,strict=True)
 print('PASS stored tokens have no trailing literal spaces; program is identical apart from unquoted spaces',flush=True)
 m.close();m=Spectrum(a.emulator,a.output)
 m.call('load_media',slot='tape-1',kind='tape',path=str(tape));m.statement('LOAD "volley"');m.call('media_transport',slot='tape-1',transport='start');m.frames(6000);assert has('0 OK')
 m.statement('RUN');wait('S to serve');key('s',True);m.frames(8);key('s',False);wait('Miss.');key('r',True);m.frames(40);key('r',False);wait('S to serve');key('q',True)
 for _ in range(100):
  m.frames(1)
  if has('Finished.'):break
 key('q',False);m.frames(30);assert has('9 STOP')
 result={'status':'passed','checks':['No literal spaces immediately after stored keyword tokens outside strings','Tokenised program identical apart from unquoted spaces, preserving numeric payloads and strings','Fresh tape load, run, serve, miss, held retry and quit'],'old_program_bytes':len(old),'new_program_bytes':len(new),'source_sha256':hashlib.sha256((ROOT/'steps/step-08.bas').read_bytes()).hexdigest(),'input_tape_sha256':hashlib.sha256(a.input_tape.read_bytes()).hexdigest(),'tape_sha256':hashlib.sha256(tape.read_bytes()).hexdigest(),'configuration':m.server}
 (a.output/'spacing-results.json').write_text(json.dumps(result,indent=2)+'\n');print('PASS fresh-load-play-retry-quit',flush=True)
finally:m.close()
