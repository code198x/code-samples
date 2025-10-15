ON TILE-1 GOSUB 6000,6100     : REM route exits/hazards
DMG=RULEDMG(ROOM)             : REM current room's damage
BONUS=RULEBONUS(ROOM)         : REM exit reward
SPEED=RULESPEED(ROOM)         : REM enemy step delay
RESTORE 9000                  : REM load room-specific DATA
