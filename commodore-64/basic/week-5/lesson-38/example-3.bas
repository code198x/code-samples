REM Collision registers
COLB=PEEK(53278) : REM sprite vs background
COLS=PEEK(53279) : REM sprite vs sprite

REM Bit masks
1 = sprite 0
2 = sprite 1
4 = sprite 2

REM Typical responses
IF COLB AND 1 THEN RESTORE_POSITION
IF COLS AND 2 THEN COLLECT_ITEM
IF COLS AND 4 THEN TAKE_DAMAGE
