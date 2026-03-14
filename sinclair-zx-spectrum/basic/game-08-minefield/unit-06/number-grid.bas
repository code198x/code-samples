10 CLS
20 DIM m(8, 8)
30 REM place 10 mines
40 FOR i = 1 TO 10
50 LET r = INT (RND * 8) + 1
60 LET c = INT (RND * 8) + 1
70 IF m(r, c) = 9 THEN GO TO 50
80 LET m(r, c) = 9
90 NEXT i
100 REM calculate neighbour counts
110 FOR r = 1 TO 8
120 FOR c = 1 TO 8
130 IF m(r, c) = 9 THEN GO TO 220
140 LET n = 0
150 FOR i = r - 1 TO r + 1
160 FOR j = c - 1 TO c + 1
170 IF i < 1 OR i > 8 OR j < 1 OR j > 8 THEN GO TO 190
180 IF m(i, j) = 9 THEN LET n = n + 1
190 NEXT j
200 NEXT i
210 LET m(r, c) = n
220 NEXT c
230 NEXT r
240 REM display
250 PRINT "Mine counts:"
260 FOR r = 1 TO 8
270 FOR c = 1 TO 8
280 IF m(r, c) = 9 THEN PRINT "*";
290 IF m(r, c) <> 9 THEN PRINT m(r, c);
300 NEXT c
310 PRINT
320 NEXT r
