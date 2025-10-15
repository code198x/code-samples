POKE 53248,X    : REM sprite 0 X position
POKE 53249,Y    : REM sprite 0 Y position
X=X+VX          : REM update position by velocity
IF X<MIN OR X>MAX THEN VX=-VX : REM bounce
FOR D=1 TO 40:NEXT D          : REM crude delay
