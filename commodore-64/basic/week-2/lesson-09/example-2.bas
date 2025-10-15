DIM MAP(9,9)            : REM 10×10 grid (0..9)
MAP(R,C) = VALUE        : REM store tile data
FOR R=0 TO MAX
FOR C=0 TO MAX
LOC = 1024 + R*40 + C
POKE LOC, CHARCODE
NEXT C
NEXT R
