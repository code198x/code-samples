10 CLS
20 DIM m(8, 8)
30 DIM s(8, 8)
40 REM m = mine grid, s = state (0=hidden, 1=revealed)
50 REM place 10 mines
60 FOR i = 1 TO 10
70 LET r = INT (RND * 8) + 1
80 LET c = INT (RND * 8) + 1
90 IF m(r, c) = 9 THEN GO TO 70
100 LET m(r, c) = 9
110 NEXT i
120 REM calculate counts
130 FOR r = 1 TO 8
140 FOR c = 1 TO 8
150 IF m(r, c) = 9 THEN GO TO 225
160 LET n = 0
170 FOR i = r - 1 TO r + 1
180 FOR j = c - 1 TO c + 1
190 IF i < 1 OR i > 8 OR j < 1 OR j > 8 THEN GO TO 210
200 IF m(i, j) = 9 THEN LET n = n + 1
210 NEXT j
212 NEXT i
220 LET m(r, c) = n
225 NEXT c
230 NEXT r
240 REM reveal a few cells
250 LET s(1, 1) = 1
260 LET s(4, 4) = 1
270 LET s(7, 2) = 1
280 REM draw grid
290 PRINT "Hidden grid (. = hidden):"
300 FOR r = 1 TO 8
310 FOR c = 1 TO 8
320 IF s(r, c) = 0 THEN PRINT ".";
330 IF s(r, c) = 1 AND m(r, c) = 9 THEN PRINT "*";
340 IF s(r, c) = 1 AND m(r, c) <> 9 THEN PRINT m(r, c);
350 NEXT c
360 PRINT
370 NEXT r
380 PRINT
390 PRINT "Revealed grid (answer key):"
400 FOR r = 1 TO 8
410 FOR c = 1 TO 8
420 IF m(r, c) = 9 THEN PRINT "*";
430 IF m(r, c) <> 9 THEN PRINT m(r, c);
440 NEXT c
450 PRINT
460 NEXT r
