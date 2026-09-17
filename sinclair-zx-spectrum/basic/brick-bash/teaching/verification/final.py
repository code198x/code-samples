#!/usr/bin/env python3
"""Run endpoint checks against the teaching tape, validating captured pixels."""
import argparse,subprocess,sys
from pathlib import Path
from check import Check,proto
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
assert (ROOT/'unit-09/brick-bash.bas').read_bytes()==(ROOT.parent/'prototype/brick-bash.bas').read_bytes()
class Final(proto.Review):
 capture=Check.capture
r=Final(a.emulator,a.output.resolve()/'unit-09')
try:r.execute()
except Exception:r.capture('failure');raise
finally:r.m.close()
subprocess.run([sys.executable,str(ROOT.parent/'prototype/verification/controls.py'),'--emulator',a.emulator,'--output',str(a.output.resolve()/'unit-09')],check=True)
