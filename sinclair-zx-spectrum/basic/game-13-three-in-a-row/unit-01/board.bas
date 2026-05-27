  55 DIM b(9)
  75 CLS
  85 PRINT AT 0, 7; "*** THREE IN A ROW ***"
  90 FOR n = 1 TO 9
  91 LET row = INT ((n - 1) / 3)
  92 LET col = n - 1 - row * 3
  93 PRINT AT 3 + row * 2, 11 + col * 4;
  94 IF b(n) = 0 THEN PRINT CHR$ (48 + n);
  97 NEXT n
  98 PRINT AT 4, 10; "---+---+---"
  99 PRINT AT 6, 10; "---+---+---"
