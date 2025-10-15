REM Velocity handling
VX=VX+DX
VY=VY+DY
X=X+VX
Y=Y+VY

REM Bounds check (screen safe zone)
IF X<24 THEN X=24:VX=0
IF Y>233 THEN Y=233:VY=0

REM Friction
IF VX>0 THEN VX=VX-1
