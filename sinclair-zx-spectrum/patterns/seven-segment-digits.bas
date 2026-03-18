  10 REM Seven-segment digit renderer
  20 REM Pattern: reusable across games
  30 REM
  40 REM Usage:
  50 REM   LET d=5: LET px=100: LET py=140
  60 REM   INK 6: GO SUB 2000
  70 REM
  80 REM Parameters:
  90 REM   d  = digit value (0-9)
 100 REM   px = x pixel coordinate (left edge)
 110 REM   py = y pixel coordinate (top edge)
 120 REM   INK colour set before calling
 130 REM
 140 REM Dimensions: 40x56 pixels (5x7 character cells)
 150 REM Each segment inset 1px from cell boundary
 160 REM Segment gap: 1 character cell (8 pixels)
 170 REM
 180 REM For two digits centred on screen:
 190 REM   Digit 1: px=92, Digit 2: px=140 (gap=8)
 200 REM For one digit centred: px=108
 210 REM
2000 REM === Draw digit d at px,py ===
2010 RESTORE 9000+d
2020 READ s$
2030 IF s$(1)="1" THEN FOR i=1 TO 6: PLOT px+9,py-i: DRAW 21,0: NEXT i
2040 IF s$(2)="1" THEN FOR i=1 TO 6: PLOT px+i,py-9: DRAW 0,-13: NEXT i
2050 IF s$(3)="1" THEN FOR i=1 TO 6: PLOT px+33+i,py-9: DRAW 0,-13: NEXT i
2060 IF s$(4)="1" THEN FOR i=1 TO 6: PLOT px+9,py-25-i: DRAW 21,0: NEXT i
2070 IF s$(5)="1" THEN FOR i=1 TO 6: PLOT px+i,py-33: DRAW 0,-13: NEXT i
2080 IF s$(6)="1" THEN FOR i=1 TO 6: PLOT px+33+i,py-33: DRAW 0,-13: NEXT i
2090 IF s$(7)="1" THEN FOR i=1 TO 6: PLOT px+9,py-49-i: DRAW 21,0: NEXT i
2100 RETURN
9000 DATA "1110111"
9001 DATA "0010010"
9002 DATA "1011101"
9003 DATA "1011011"
9004 DATA "0111010"
9005 DATA "1101011"
9006 DATA "1101111"
9007 DATA "1010010"
9008 DATA "1111111"
9009 DATA "1111011"
