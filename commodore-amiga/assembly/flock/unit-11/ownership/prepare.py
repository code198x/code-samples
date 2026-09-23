"""Make two inspectable experiment sources; never overwrite the game."""
import argparse
import hashlib
from pathlib import Path

HERE = Path(__file__).resolve().parent
BASELINE = '71361e15c6cf329ec274dc2959caa76d9dcd8a9c9236625253eec0fbea173cdb'


def replace_once(source, old, new):
    assert source.count(old) == 1, old
    return source.replace(old, new)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--spaced', action='store_true', help='use the spaced-request comparison')
    args = parser.parse_args()
    base = (HERE.parent / 'flock.asm').read_text()
    assert hashlib.sha256(base.encode()).hexdigest() == BASELINE, 'Review the changed baseline before applying this experiment'
    source = replace_once(base, '            bsr     steer               ; Read the stick, maybe hop\n            bsr     drivelanes          ; All the traffic, one mover\n            bsr     checksquash         ; Did the lane win?\n            bsr     soundtick           ; Wobble, and fall silent on time',
                          '            bsr     soundtick\n            tst.w   trialdone\n            bne.s   .trialfinished\n            bsr     experiment\n.trialfinished:')
    # Ownership ends at the same point as the existing timer/volume stop.
    source = replace_once(source, '            move.w  #0,AUD0VOL(a5)\n            rts',
                          '            move.w  #0,AUD0VOL(a5)\n            clr.w   sndpriority\n            rts')
    source = replace_once(source, '\nplaysound:\n', '\n' + (HERE / 'requestsound.asm').read_text() + '\n' + (HERE / ('spaced.asm' if args.spaced else 'experiment.asm')).read_text() + '\nplaysound:\n')
    source += '''
            even
ownership_marker: dc.b "FLOCK-OWNERSHIP1"
observations: ds.w 15
trialdone:   dc.w 0
sndpriority: dc.w 0
accepted:   dc.w 0
rejected:   dc.w 0
trialframe: dc.w 0
recordoffset: dc.w 0
'''
    if args.spaced:
        source = source.replace('observations: ds.w 15', 'observations: ds.w 55')
    args.output.mkdir(parents=True, exist_ok=True)
    for name, mode in [('latest', 0), ('priority', 1)]:
        (args.output / (name + '.asm')).write_text(f'USE_PRIORITY equ {mode}\n' + source)


if __name__ == '__main__':
    main()
