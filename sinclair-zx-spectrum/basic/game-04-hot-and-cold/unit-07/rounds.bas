10 CLS
20 LET s = 0
30 FOR g = 1 TO 5
40 CLS
50 LET tr = INT (RND * 22)
60 LET tc = INT (RND * 32)
70 LET r = 10
80 LET c = 15
90 LET m = 0
100 REM === game loop ===
110 PRINT AT r, c; "+"
120 LET d = ABS (r - tr) + ABS (c - tc)
130 IF d = 0 THEN GO TO 270
140 IF d <= 3 THEN BORDER 6
150 IF d > 3 AND d <= 7 THEN BORDER 2
160 IF d > 7 AND d <= 14 THEN BORDER 3
170 IF d > 14 AND d <= 24 THEN BORDER 1
180 IF d > 24 THEN BORDER 0
190 LET k$ = INKEY$
200 IF k$ = "" THEN GO TO 190
210 PRINT AT r, c; " "
220 IF k$ = "q" AND r > 0 THEN LET r = r - 1
230 IF k$ = "a" AND r < 21 THEN LET r = r + 1
240 IF k$ = "o" AND c > 0 THEN LET c = c - 1
250 IF k$ = "p" AND c < 31 THEN LET c = c + 1
260 LET m = m + 1
265 GO TO 110
270 REM === found it ===
280 BEEP 0.3, 12
290 BEEP 0.3, 16
300 PRINT AT r, c; "*"
310 BORDER 7
320 LET s = s + m
330 PRINT AT 23, 0; "Round "; g; " — "; m; " moves"
340 PAUSE 100
350 NEXT g
360 CLS
370 PRINT "Game over!"
380 PRINT
390 PRINT "Total moves: "; s
