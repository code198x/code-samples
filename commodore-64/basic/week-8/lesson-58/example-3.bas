REM Cache string lookup
TILECODE=ASC(TILE$(ROW(Y)))
FOR X=0 TO 39:POKE BASE+X,TILECODE:NEXT

REM Unroll when pattern is static
POKE BASE, CODE:POKE BASE+1, CODE : REM etc.
