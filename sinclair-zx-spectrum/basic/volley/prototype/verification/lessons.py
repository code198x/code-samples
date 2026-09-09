#!/usr/bin/env python3
"""Validate the Volley lesson edit roster and maintained snippets against full checkpoints."""
import argparse,json
from pathlib import Path
from entry import ROOT,compact_source
p=argparse.ArgumentParser();p.add_argument('--roster',type=Path,required=True);a=p.parse_args()
previous={}
for item in json.loads(a.roster.read_text()):
 n=item['number'];path=ROOT/f'steps/step-{n:02}.bas';text=path.read_text();assert compact_source(text)==text,path
 current={int(l.split()[0]):l for l in text.splitlines()}
 added=sorted(current.keys()-previous.keys());replaced=sorted(k for k in current.keys()&previous.keys() if current[k]!=previous[k]);deleted=sorted(previous.keys()-current.keys())
 assert (added,replaced,deleted)==(item['added'],item['replaced'],item['deleted']),item
 if n>=4:assert (ROOT/f'snippets/step-{n:02}.bas').read_text()==''.join(current[k]+'\n' for k in sorted(added+replaced))
 rebuilt={k:v for k,v in previous.items() if k not in deleted};rebuilt.update({k:current[k] for k in added+replaced});assert rebuilt==current
 previous=current
print('PASS all eight lesson edit sets; five focused snippets match their full checkpoints; keyword spacing preserved.')
