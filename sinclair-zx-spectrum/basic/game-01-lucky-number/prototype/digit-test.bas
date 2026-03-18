  10 REM Seven-segment digits — chunky with outline
  20 BORDER 0: PAPER 0: INK 7: CLS
  30 FOR d=0 TO 4
  40 LET px=d*48+12
  50 LET py=160
  60 INK 6
  70 GO SUB 2000
  80 NEXT d
  90 FOR d=5 TO 9
 100 LET px=(d-5)*48+12
 110 LET py=88
 120 INK 6
 130 GO SUB 2000
 140 NEXT d
 150 STOP
2000 REM === Draw digit d at px,py ===
2001 REM 5 cells wide x 7 cells tall (40x56 px)
2002 REM 1px inset from cell boundary, no chamfer
2010 RESTORE 9000+d
2020 READ s$
2030 REM Seg 0: top bar
2040 IF s$(1)="1" THEN FOR i=1 TO 6: PLOT px+9,py-i: DRAW 21,0: NEXT i
2050 REM Seg 1: upper left
2060 IF s$(2)="1" THEN FOR i=1 TO 6: PLOT px+i,py-9: DRAW 0,-13: NEXT i
2070 REM Seg 2: upper right
2080 IF s$(3)="1" THEN FOR i=1 TO 6: PLOT px+33+i,py-9: DRAW 0,-13: NEXT i
2090 REM Seg 3: middle bar
2100 IF s$(4)="1" THEN FOR i=1 TO 6: PLOT px+9,py-25-i: DRAW 21,0: NEXT i
2110 REM Seg 4: lower left
2120 IF s$(5)="1" THEN FOR i=1 TO 6: PLOT px+i,py-33: DRAW 0,-13: NEXT i
2130 REM Seg 5: lower right
2140 IF s$(6)="1" THEN FOR i=1 TO 6: PLOT px+33+i,py-33: DRAW 0,-13: NEXT i
2150 REM Seg 6: bottom bar
2160 IF s$(7)="1" THEN FOR i=1 TO 6: PLOT px+9,py-49-i: DRAW 21,0: NEXT i
2170 RETURN
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
