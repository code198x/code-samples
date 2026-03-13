10 CLS
20 LET r = 10
30 LET c = 15
40 PRINT AT r, c; "+"
50 LET k$ = INKEY$
60 IF k$ = "" THEN GO TO 50
70 PRINT AT r, c; " "
80 IF k$ = "q" AND r > 0 THEN LET r = r - 1
90 IF k$ = "a" AND r < 21 THEN LET r = r + 1
100 IF k$ = "o" AND c > 0 THEN LET c = c - 1
110 IF k$ = "p" AND c < 31 THEN LET c = c + 1
120 PRINT AT r, c; "+"
130 GO TO 50
