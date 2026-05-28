  10 BORDER 0: PAPER 0: INK 7: CLS
  90 DIM b(9)
 120 CLS
 130 LET a$ = "*** THREE IN A ROW ***": LET y = 0: GO SUB 9000
 150 INK 7: FOR i = 0 TO 3: PLOT 80 + i * 32, 55: DRAW 0, 96: NEXT i
 160 FOR i = 0 TO 3: PLOT 80, 55 + i * 32: DRAW 96, 0: NEXT i
 170 FOR n = 1 TO 9
 180 LET row = INT ((n - 1) / 3)
 190 LET col = n - 1 - row * 3
 200 LET cx = 100 + col * 32: LET cy = 131 - row * 32
 210 IF b(n) = 0 THEN PRINT AT 5 + row * 4, 12 + col * 4; CHR$ (48 + n)
 240 NEXT n

 250 STOP
9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
