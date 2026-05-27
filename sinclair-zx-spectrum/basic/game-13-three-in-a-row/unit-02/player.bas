  55 DIM b(9)
  75 CLS
  85 PRINT AT 0, 7; "*** THREE IN A ROW ***"
  90 FOR n = 1 TO 9
  91 LET row = INT ((n - 1) / 3)
  92 LET col = n - 1 - row * 3
  93 PRINT AT 3 + row * 2, 11 + col * 4;
  94 IF b(n) = 0 THEN PRINT CHR$ (48 + n);
  95 IF b(n) = 1 THEN INK 5: PRINT "X";: INK 7
  97 NEXT n
  98 PRINT AT 4, 10; "---+---+---"
  99 PRINT AT 6, 10; "---+---+---"
 120 INPUT "Your move (1-9): "; m
 125 IF m < 1 OR m > 9 THEN GO TO 120
 127 IF b(m) <> 0 THEN PRINT AT 10, 4; "Already taken!": PAUSE 30: GO TO 75
 130 LET b(m) = 1
 135 GO TO 75
