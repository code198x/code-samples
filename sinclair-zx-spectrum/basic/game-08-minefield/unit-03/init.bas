10 CLS
20 PRINT "Array Initialisation"
30 PRINT
40 DIM m(8, 8)
50 REM fill entire grid with zeros
60 FOR r = 1 TO 8
70 FOR c = 1 TO 8
80 LET m(r, c) = 0
90 NEXT c
100 NEXT r
110 REM set a diagonal to 1
120 FOR i = 1 TO 8
130 LET m(i, i) = 1
140 NEXT i
150 REM set a border to 5
160 FOR i = 1 TO 8
170 LET m(1, i) = 5
180 LET m(8, i) = 5
190 LET m(i, 1) = 5
200 LET m(i, 8) = 5
210 NEXT i
220 REM display
230 FOR r = 1 TO 8
240 FOR c = 1 TO 8
250 PRINT m(r, c);
260 NEXT c
270 PRINT
280 NEXT r
