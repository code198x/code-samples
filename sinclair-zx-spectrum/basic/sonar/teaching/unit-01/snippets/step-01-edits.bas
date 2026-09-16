10 BORDER 1: PAPER 0: INK 7: CLS
20 LET r = 1
30 FOR c = 1 TO 8
40 LET y = 4 + 2 * (r - 1): LET x = 5 + 3 * (c - 1)
50 PAPER 1: INK 7
60 IF r + c = 2 * INT ((r + c) / 2) THEN PAPER 5: INK 0
70 PRINT AT y, x; " . "; AT y + 1, x; "   "
80 NEXT c
90 STOP
