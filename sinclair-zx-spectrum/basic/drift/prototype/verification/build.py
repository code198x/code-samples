#!/usr/bin/env python3
"""Enter the maintained source via ROM keys and record a self-starting TAP."""
import argparse,json,hashlib
from pathlib import Path
from entry import Spectrum,ROOT
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args();a.output.mkdir(parents=True,exist_ok=True)
m=Spectrum(a.emulator,a.output)
try:
 m.load_source(ROOT/'drift.bas');stored=m.program_lines()
 m.statement('SAVE "drift" LINE 10');m.enter()
 for _ in range(1500):
  if any('0 OK' in s for s in m.screen()):break
  m.frames(20)
 else:raise AssertionError(m.screen())
 m.call('save_tape',path=str((a.output/'drift.tap').resolve()))
 (a.output/'stored.json').write_text(json.dumps(stored)+'\n')
 (a.output/'build.json').write_text(json.dumps({'source_sha256':hashlib.sha256((ROOT/'drift.bas').read_bytes()).hexdigest(),'tape_sha256':hashlib.sha256((a.output/'drift.tap').read_bytes()).hexdigest(),'entry':'ROM keyboard; SAVE "drift" LINE 10; no source injection'},indent=2)+'\n')
finally:m.close()
