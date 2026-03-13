10 CLS
20 LET tr = INT (RND * 22)
30 LET tc = INT (RND * 32)
40 LET r = 10
50 LET c = 15
60 REM === game loop ===
70 PRINT AT r, c; "+"
80 LET d = ABS (r - tr) + ABS (c - tc)
90 IF d = 0 THEN GO TO 230
100 IF d <= 3 THEN BORDER 6
110 IF d > 3 AND d <= 7 THEN BORDER 2
120 IF d > 7 AND d <= 14 THEN BORDER 3
130 IF d > 14 AND d <= 24 THEN BORDER 1
140 IF d > 24 THEN BORDER 0
150 LET k$ = INKEY$
160 IF k$ = "" THEN GO TO 150
170 PRINT AT r, c; " "
180 IF k$ = "q" AND r > 0 THEN LET r = r - 1
190 IF k$ = "a" AND r < 21 THEN LET r = r + 1
200 IF k$ = "o" AND c > 0 THEN LET c = c - 1
210 IF k$ = "p" AND c < 31 THEN LET c = c + 1
220 GO TO 70
230 REM === found it ===
240 BEEP 0.5, 12
250 PRINT AT r, c; "*"
260 BORDER 7
270 PRINT AT 23, 0; "You found it!"
