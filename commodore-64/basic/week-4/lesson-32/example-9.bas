ON STATE GOTO 1000,2000,3000
DMG=RULEDMG(ROOM)         : REM room hazard damage
BONUS=RULEBONUS(ROOM)     : REM target score for progression
SPEED=RULESPEED(ROOM)     : REM enemy step delay
TI$="000000"              : REM reset timer for each run
