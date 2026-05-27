  10 BORDER 0: PAPER 0: INK 7: CLS
  90 DIM b(9)
 120 CLS
 130 PRINT AT 0, 7; BRIGHT 1; "*** THREE IN A ROW ***"
 150 FOR n = 1 TO 9
 160 LET row = INT ((n - 1) / 3)
 170 LET col = n - 1 - row * 3
 180 PRINT AT 3 + row * 2, 11 + col * 4;
 190 IF b(n) = 0 THEN PRINT CHR$ (48 + n);
 200 IF b(n) = 1 THEN INK 5: PRINT "X";: INK 7
 220 NEXT n
 230 PRINT AT 4, 10; "---+---+---"
 240 PRINT AT 6, 10; "---+---+---"
 250 INPUT "Your move (1-9): "; m
 260 IF m < 1 OR m > 9 THEN GO TO 250
 270 IF b(m) <> 0 THEN PRINT AT 10, 4; "Already taken!": PAUSE 30: GO TO 120
 280 LET b(m) = 1
 300 GO TO 120

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
