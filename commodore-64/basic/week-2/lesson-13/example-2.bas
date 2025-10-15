IF X<MIN OR X>MAX THEN RETURN        : REM guard prowling off-screen
CELL=MAP(NY,NX)                      : REM peek destination tile
IF CELL=1 THEN RETURN                : REM block walls
IF CELL=3 THEN LIVES=LIVES-1         : REM hazard effect
IF (SCORE>=200 AND LIVES>0) OR KEY=1 THEN ...
