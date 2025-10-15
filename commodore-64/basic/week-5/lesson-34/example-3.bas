REM Reading tile data
FOR R=0 TO HEIGHT-1
  FOR C=0 TO WIDTH-1
    READ MAP(R,C)
  NEXT C
NEXT R

REM Turning tile IDs into art
IF TILE=0 THEN CHAR$=" "
IF TILE=1 THEN CHAR$="#"
IF TILE=2 THEN CHAR$="*"
IF TILE=3 THEN CHAR$="~"

REM Accessing a tile
t = MAP(y,x)
