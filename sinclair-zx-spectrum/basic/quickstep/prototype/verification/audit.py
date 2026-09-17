#!/usr/bin/env python3
"""Audit retained source, ROM-stored lines, TAP checksums and execution/capture identities."""
import argparse,json,hashlib,functools
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--evidence',type=Path,default=ROOT/'verification/evidence');a=p.parse_args();out=a.evidence
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
build=json.loads((out/'build.json').read_text());model=json.loads((out/'results.json').read_text());frames=json.loads((out/'frames.json').read_text())
source=sha(ROOT/'quickstep.bas');tape=sha(out/'quickstep.tap')
for item in [build,model,frames]:assert item['source_sha256']==source and item['tape_sha256']==tape
assert model['status']==frames['status']=='passed'
assert set(map(int,json.loads((out/'stored.json').read_text())))=={int(l.split()[0]) for l in (ROOT/'quickstep.bas').read_text().splitlines()}
data=(out/'quickstep.tap').read_bytes();offset=0;blocks=[]
while offset<len(data):
 size=int.from_bytes(data[offset:offset+2],'little');block=data[offset+2:offset+2+size]
 assert len(block)==size and functools.reduce(int.__xor__,block)==0
 blocks.append(size);offset+=size+2
assert offset==len(data) and len(blocks)==2
assert len(frames['captures'])==4
for c in frames['captures']:assert sha(out/(c['name']+'.png'))==c['sha256']
record=dict(status='passed',source_sha256=source,tape_sha256=tape,tape_blocks=blocks,execution_checks=len(model['checks'])+len(frames['checks']),model_checks=model['checks'],normal_frame_checks=frames['checks'],timing=frames['timing'],captures=frames['captures'],configuration='Stock 48K PAL, Emu198x Spectrum 0.25.0',entry=build['entry'],limits='CPU-stepped model traces are not timing evidence. Normal-frame commit intervals vary with work. Native user approval and original-hardware measurements remain pending.')
(out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n');print('PASS',record['execution_checks'],'execution check groups, checksum-valid tape, stored lines and original capture hashes')
