"""Move one cosmetic draw across the first spawn, reusing the correct C07b fixture."""
import argparse
from pathlib import Path
import subprocess
import sys
import tempfile

HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('output', type=Path)
args = parser.parse_args()
args.output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory() as work:
    subprocess.run([sys.executable,str(HERE.parent/'position/prepare.py'),work],check=True)
    source = (Path(work)/'baseline.asm').read_text()

def once(text, old, new):
    assert text.count(old) == 1, old
    return text.replace(old,new)

# C07b's correct spawn/position routine and twelve five-byte records stay intact.
source = once(source,'        jsr spawn_enemy\n        ldy record_offset',
              '        jsr spawn_enemy\n        lda #1                  ; Consumer 1 = enemy position\n        jsr log_draw\n        ldy record_offset')
source = once(source,'hex_digits: !byte', (HERE/'cosmetic.asm').read_text()+'\nhex_digits: !byte')
source += '''
draw_offset: !byte 0
cosmetic_byte: !byte 0
draws: !fill 26,0
'''
# Show the first three spawns: the first is where this experiment differs.
source = source.replace('records+45,x', 'records,x')
source = source.replace('Show the last three records', 'Show the first three records')
for old,new in [('10','1'),('11','2'),('12','3')]:
    source = once(source, '!byte '+','.join(str(ord(c)) for c in old.ljust(40))+'\n',
                  '!byte '+','.join(str(ord(c)) for c in new.ljust(40))+'\n')
# Move exactly one draw: both variants consume 13 bytes in total.
before = once(source,'position_next:\n','        jsr cosmetic_draw\nposition_next:\n')
after = once(source,'        inc trial_index\n', '''        lda trial_index
        bne cosmetic_done
        jsr cosmetic_draw
cosmetic_done:
        inc trial_index
''')
for name,body in [('before',before),('after',after)]:
    (args.output/(name+'.asm')).write_text(body)
