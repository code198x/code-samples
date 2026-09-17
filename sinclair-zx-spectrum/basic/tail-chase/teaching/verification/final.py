#!/usr/bin/env python3
"""Reuse the prototype's full-round model for the byte-identical taught endpoint."""
import argparse,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT.parent/'prototype/verification'))
from verify import Review,line
class FinalReview(Review):
 def capture(self,name):
  if 4000<=line(self.m)<=4060:self.m.frames(2)
  super().capture(name)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--emulator',required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
 assert (ROOT/'unit-09/steps/step-01.bas').read_bytes()==(ROOT.parent/'prototype/tail-chase.bas').read_bytes()
 r=FinalReview(a.emulator,a.output.resolve()/'eight-foods')
 try:r.execute()
 except Exception:r.capture('failure');raise
 finally:r.m.close()
