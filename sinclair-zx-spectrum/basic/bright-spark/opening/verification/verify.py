#!/usr/bin/env python3
"""Check opening lesson checkpoints and exact editing continuity in 48K BASIC."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('prototype',ROOT.parent/'prototype/verification/verify.py')
module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True)
a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=module.Spectrum(a.emulator,a.output);previous={};sources={}
try:
 for unit,count in [(1,4),(2,3)]:
  for step in range(1,count+1):
   source=ROOT/f'unit-{unit:02}/steps/step-{step:02}.bas'
   current={int(l.split()[0]):l for l in source.read_text().splitlines()}
   # ROM automatic listing/redrawing must settle before the next entry.
   # This is host-driven typing pace, not a delay in the learner program.
   for number in sorted(previous.keys()-current.keys()):m.statement(str(number));m.frames(60)
   for number,line in current.items():
    if previous.get(number)!=line:
     m.statement(line);m.frames(60)
   m.statement('RUN');m.frames(350)
   m.labels(1 if unit==1 and step<4 else 4)
   expected_star=[(5,23)] if (unit,step)==(2,1) else []
   assert m.stars()==expected_star,(unit,step,m.stars())
   m.check(f'unit-{unit:02}-step-{step:02}',['BRIGHT SPARK','9 STOP'])
   sources[str(source.relative_to(ROOT))]=hashlib.sha256(source.read_bytes()).hexdigest()
   previous=current
 # Return the four-cue demonstration to the one-cue caller.
 m.statement('300 LET p=2');m.statement('320 STOP');m.statement('330')
 m.statement('RUN');m.frames(160);m.labels();assert not m.stars()
 m.check('single-cue-restored',['9 STOP'],capture=False)
 (a.output/'results.json').write_text(json.dumps({'status':'passed','server':m.server,'sources':sources,'checks':m.evidence,'limits':'ROM entry and MCP display checks; no native keyboard or listening acceptance.'},indent=2)+'\n')
finally:m.close()
