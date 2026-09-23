"""Generate baseline, one-fault and repaired restart fixtures."""
import argparse
import hashlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASELINE = '97ad08dadc14948dc88ebd8ac00c74e3bf0d5340b531021deebdfb4736411fb4'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
args = parser.parse_args()
source = (HERE.parent / 'steps/step-04.asm').read_text()
assert hashlib.sha256(source.encode()).hexdigest() == BASELINE, 'Review the changed baseline first'
anchor = '        ; Open on the title screen\n        jsr enter_title'
assert source.count(anchor) == 1
source = source.replace(anchor, '        jmp restart_trial')
trial = (HERE / 'trial.asm').read_text()
for row in ['RESTART TRIAL - ENEMY COUNT', 'GAME 1:                ?',
            'GAME 2:                ?', 'GAME 3:                ?']:
    codes = [ord(c)-64 if 'A' <= c <= 'Z' else ord(c) for c in row.ljust(40)]
    trial += '!byte ' + ','.join(map(str,codes)) + '\n'
trial += '''
*= $3800
trial_done: !byte 0
trial_index: !byte 0
growth_left: !byte 0
records: !fill 27,0
'''
assert source.count('        sta enemy_count\n') == 1
fault = source.replace('        sta enemy_count\n', '        nop                     ; FAULT: missing per-game reset\n        nop\n')
args.output.mkdir(parents=True, exist_ok=True)
for name, body in [('baseline', source), ('faulty', fault), ('repaired', source)]:
    (args.output / (name + '.asm')).write_text(body + '\n' + trial)
