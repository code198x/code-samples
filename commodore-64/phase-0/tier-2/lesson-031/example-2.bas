IF EX<PX THEN EX=EX+1    : REM chase right
IF EX>PX THEN EX=EX-1    : REM chase left
IF EY<PY THEN EY=EY+1    : REM chase down
IF EY>PY THEN EY=EY-1    : REM chase up
IF STEP MOD SPEED=0      : REM throttle enemy move rate
