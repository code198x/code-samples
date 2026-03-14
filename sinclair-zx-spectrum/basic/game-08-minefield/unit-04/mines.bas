10 CLS
20 PRINT "Placing Mines"
30 PRINT
40 DIM m(8, 8)
50 LET n = 10
60 REM place n mines
70 FOR i = 1 TO n
80 LET r = INT (RND * 8) + 1
90 LET c = INT (RND * 8) + 1
100 IF m(r, c) = 9 THEN GO TO 80
110 LET m(r, c) = 9
120 NEXT i
130 REM display grid
140 FOR r = 1 TO 8
150 FOR c = 1 TO 8
160 IF m(r, c) = 9 THEN PRINT "*";
170 IF m(r, c) = 0 THEN PRINT ".";
180 NEXT c
190 PRINT
200 NEXT r
210 PRINT
220 PRINT n; " mines placed"
