  10 BORDER 0: PAPER 0: INK 7: CLS
  90 DIM b(9)
 120 CLS
 130 PRINT AT 0, 7; BRIGHT 1; "*** THREE IN A ROW ***"
 150 FOR n = 1 TO 9
 160 LET row = INT ((n - 1) / 3)
 170 LET col = n - 1 - row * 3
 180 PRINT AT 3 + row * 2, 11 + col * 4;
 190 IF b(n) = 0 THEN PRINT CHR$ (48 + n);
 220 NEXT n
 230 PRINT AT 4, 10; "---+---+---"
 240 PRINT AT 6, 10; "---+---+---"

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
