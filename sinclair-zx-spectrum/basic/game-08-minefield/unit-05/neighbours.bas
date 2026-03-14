10 CLS
20 PRINT "Counting Neighbours"
30 PRINT
40 DIM m(5, 5)
50 REM place mines at known positions
60 LET m(1, 1) = 9
70 LET m(1, 3) = 9
80 LET m(3, 2) = 9
90 REM count neighbours for cell (2,2)
100 LET r = 2: LET c = 2
110 LET n = 0
120 FOR i = r - 1 TO r + 1
130 FOR j = c - 1 TO c + 1
140 IF i < 1 OR i > 5 THEN GO TO 180
150 IF j < 1 OR j > 5 THEN GO TO 180
160 IF i = r AND j = c THEN GO TO 180
170 IF m(i, j) = 9 THEN LET n = n + 1
180 NEXT j
190 NEXT i
200 PRINT "Grid:"
210 FOR r = 1 TO 5
220 FOR c = 1 TO 5
230 IF m(r, c) = 9 THEN PRINT "*";
240 IF m(r, c) = 0 THEN PRINT ".";
250 NEXT c
260 PRINT
270 NEXT r
280 PRINT
290 PRINT "Cell (2,2) has "; n; " mine neighbours"
