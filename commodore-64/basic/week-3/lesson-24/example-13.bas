STATE=1              : REM 1=title, 2=gameplay, 3=game over
ON STATE GOTO 1000,2000,3000
DMG=RULEDMG(ROOM)    : REM per-room hazard damage
PRINT DIALOG$(I)     : REM dialogue lines for UI
CUE$=MUSIC$(ROOM)    : REM cue identifier
