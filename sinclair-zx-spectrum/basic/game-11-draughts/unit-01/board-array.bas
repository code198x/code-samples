10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM b(8, 8)
30 REM set up starting pieces
40 FOR r = 1 TO 3
50 FOR c = 1 TO 8
60 IF (r + c) / 2 = INT ((r + c) / 2) THEN LET b(r, c) = 1
70 NEXT c
80 NEXT r
90 FOR r = 6 TO 8
100 FOR c = 1 TO 8
110 IF (r + c) / 2 = INT ((r + c) / 2) THEN LET b(r, c) = 2
120 NEXT c
130 NEXT r
140 REM display the array
150 PRINT "Board array values:"
160 PRINT
170 FOR r = 1 TO 8
180 FOR c = 1 TO 8
190 PRINT b(r, c);
200 NEXT c
210 PRINT
220 NEXT r
