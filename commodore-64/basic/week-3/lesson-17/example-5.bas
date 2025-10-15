SCREEN=1024:COLOR=55296
LOC=SCREEN+ROW*40+COL          : REM character address
POKE LOC,CHAR                  : REM draw
POKE COLOR+ROW*40+COL,COLVAL   : REM colour
X=X+VX : Y=Y+VY                : REM velocity update
