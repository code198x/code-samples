10 CLS
20 LET tr = INT (RND * 22)
30 LET tc = INT (RND * 32)
40 LET r = 10
50 LET c = 15
60 PRINT AT r, c; "+"
70 LET k$ = INKEY$
80 IF k$ = "" THEN GO TO 70
90 PRINT AT r, c; " "
100 IF k$ = "q" AND r > 0 THEN LET r = r - 1
110 IF k$ = "a" AND r < 21 THEN LET r = r + 1
120 IF k$ = "o" AND c > 0 THEN LET c = c - 1
130 IF k$ = "p" AND c < 31 THEN LET c = c + 1
140 PRINT AT r, c; "+"
150 IF r = tr AND c = tc THEN GO TO 170
160 GO TO 70
170 BEEP 0.5, 12
180 PRINT AT r, c; "*"
190 PRINT AT 23, 0; "You found it!"
