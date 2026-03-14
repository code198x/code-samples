10 CLS
20 DIM m(8, 8)
30 REM fill with test pattern
40 FOR r = 1 TO 8
50 FOR c = 1 TO 8
60 LET m(r, c) = INT (RND * 4)
70 NEXT c
80 NEXT r
90 REM draw grid
100 PRINT AT 0, 8; "Grid Display"
110 FOR r = 1 TO 8
120 FOR c = 1 TO 8
130 PRINT AT r + 2, c * 3; m(r, c)
140 NEXT c
150 NEXT r
160 REM draw borders
170 FOR c = 1 TO 8
180 PRINT AT 2, c * 3; "-"
190 PRINT AT 11, c * 3; "-"
200 NEXT c
