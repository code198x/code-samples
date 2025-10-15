REM Clear fine scroll bits but keep mode flags
BASE=PEEK(53270) AND 248

REM Horizontal fine scroll (0-7)
FOR SHIFT=0 TO 7
  POKE 53270,BASE OR SHIFT
NEXT SHIFT

REM Shift screen one column left
FOR COL=0 TO 38
  POKE 1024+COL,PEEK(1025+COL)
NEXT COL
