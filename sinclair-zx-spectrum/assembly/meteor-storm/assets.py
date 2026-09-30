"""Original 24x16 artwork; prepare eight pixel offsets on the host, not in play."""
from pathlib import Path
ROOT=Path(__file__).resolve().parent
SHIP=[0x000000,0x001800,0x001800,0x003C00,0x003C00,0x007E00,0x00FF00,0x01DB80,0x03FFC0,0x07FFE0,0x0FFFF0,0x0CFF30,0x00FF00,0x006600,0x004200,0x000000]
METEOR=[0x007E00,0x03FF80,0x0FDFC0,0x1F87E0,0x3F03F0,0x7F83F8,0x7FE7FC,0xFFFDFC,0xF9FFFC,0xF0FFF8,0xF1F7F8,0x7FF3F0,0x3FFFE0,0x1FFFC0,0x07FF00,0x00F800]
METEOR=[METEOR[i] for i in [0,1,2,4,5,7,8,10,11,13,14,15]]+[0]*4
# A reproducible scattered field: each event is (x, speed, next delay).
import random
rng=random.Random(1986)
EVENTS=[(rng.randrange(8,225,2),rng.choice([2,3,4,5]),rng.randrange(6,11),rng.choice([-1,0,1]),2 if i%6==3 else 1) for i in range(120)]
STAR=[0x001800,0x001800,0x003C00,0x00FF00,0x03FFC0,0x00FF00,0x007E00,0x00E700,0x018180,0x0300C0,0,0,0,0,0,0]
# One debris piece, three rows in the ship's centre columns, so it shares the ship's X.
DEBRIS=[0x001C00,0x003E00,0x001A00]+[0]*13

def assets(n):
 names=[('ship',SHIP)]+([('meteor',METEOR)] if n>=3 else [])+([('star',STAR)] if n>=8 else [])+([('debris',DEBRIS)] if n>=17 else [])
 lines=['; Eight horizontal shifts; each shift has 16 rows of four bytes.']
 for name,rows in names:
  lines.append(name+'_sprites:')
  for shift in range(8):
   lines.append('; shift '+str(shift))
   for row in rows:
    v=(row<<8)>>shift;lines.append(' defb '+','.join('$%02X'%((v>>b)&255) for b in (24,16,8,0)))
 # object-pool starts its three meteors in code; the event table begins with fixed-course.
 if n>=6:
  events=[e for e in EVENTS if e[4]==1] if n<8 else EVENTS
  lines.append('meteor_events:')
  for x,speed,delay,drift,kind in events:
   fields=[x,speed,delay]+([drift&255] if n>=7 else [])+([kind] if n>=8 else [])
   lines.append(' defb '+','.join(map(str,fields)))
 return '\n'.join(lines)+'\n'

# These checkpoints use the same generated data as the stage named.
SAME_DATA = {'object-records': 'object-pool', 'star-pickups': 'stars', 'elapsed-time': 'timed-course'}

CHECKPOINTS = ['pixel-motion', 'clocked-steering', 'one-meteor', 'first-dodge',
               'object-pool', 'fixed-course', 'drift', 'stars', 'timed-course',
               'boost', 'render-budget', 'records', 'finished',
               'tone', 'sound-table', 'sound-frames', 'debris']
if __name__ == '__main__':
    for number, name in enumerate(CHECKPOINTS, 1):
        (ROOT / 'checkpoints' / name / 'assets.inc').write_text(assets(number))

    (ROOT / 'checkpoints/draw-ship/assets.inc').write_text(assets(1))
    (ROOT / 'checkpoints/phases/assets.inc').write_text(assets(4))
    for name, stage in SAME_DATA.items():
        (ROOT / 'checkpoints' / name / 'assets.inc').write_text(assets(CHECKPOINTS.index(stage) + 1))
