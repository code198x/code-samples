REM Fixed update cadence
IF TI>=NEXTT THEN NEXTT=TI+FIX: GOSUB 3400

REM Easing toward zero
VX=VX-VX/FRICTION

REM Toggle trace
TRACE=1-TRACE
