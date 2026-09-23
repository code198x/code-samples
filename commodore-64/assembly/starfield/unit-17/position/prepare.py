"""Generate a fixed-seed position trial with one isolated display-bit fault."""
import argparse
import hashlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASELINE = '97ad08dadc14948dc88ebd8ac00c74e3bf0d5340b531021deebdfb4736411fb4'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
args = parser.parse_args()
source = (HERE.parent/'steps/step-04.asm').read_text()
assert hashlib.sha256(source.encode()).hexdigest() == BASELINE, 'Review changed baseline first'
anchor = '        ; Open on the title screen\n        jsr enter_title'
assert source.count(anchor) == 1
source = source.replace(anchor, '        jmp position_trial')
fault_line = "        jsr set_enemy_hibit     ; and its 9th X bit"
assert source.count(fault_line) == 1
fault = source.replace(fault_line, '        nop                     ; FAULT: omit the sprite high-bit handoff\n        nop\n        nop')
trial = (HERE/'trial.asm').read_text()
for row in ['CALL  SEED LOW  HIGH VICX D010 (HEX)', '10', '11', '12']:
    codes = [ord(c)-64 if 'A' <= c <= 'Z' else ord(c) for c in row.ljust(40)]
    trial += '!byte '+','.join(map(str,codes))+'\n'
trial += '''
*= $3800
trial_done: !byte 0
trial_index: !byte 0
record_offset: !byte 0
records: !fill 60,0
'''
args.output.mkdir(parents=True, exist_ok=True)
for name, body in [('baseline',source),('faulty',fault),('repaired',source)]:
    (args.output/(name+'.asm')).write_text(body+'\n'+trial)
