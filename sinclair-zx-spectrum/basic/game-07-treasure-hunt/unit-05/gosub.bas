10 CLS
20 LET r = 10
30 LET c = 15
40 LET n = 0
50 LET f = 5
60 GO SUB 300
70 GO SUB 400
80 REM game loop
90 GO SUB 500
100 LET k$ = INKEY$
110 IF k$ = "" THEN GO TO 100
120 PRINT AT r, c; " "
130 IF k$ = "q" AND r > 1 THEN LET r = r - 1
140 IF k$ = "a" AND r < 20 THEN LET r = r + 1
150 IF k$ = "o" AND c > 0 THEN LET c = c - 1
160 IF k$ = "p" AND c < 31 THEN LET c = c + 1
170 IF ATTR (r, c) = 49 THEN LET n = n + 1: BEEP 0.05, 20: GO SUB 400
180 GO SUB 500
190 GO TO 100
200 STOP
300 REM === place coins ===
310 FOR i = 1 TO f
320 LET y = INT (RND * 19) + 2
330 LET x = INT (RND * 32)
340 INK 6: PRINT AT y, x; "*": INK 0
350 NEXT i
360 RETURN
400 REM === draw HUD ===
410 PRINT AT 0, 0; "Coins: "; n; "  "
420 RETURN
500 REM === draw player ===
510 INK 4: PRINT AT r, c; "O": INK 0
520 RETURN
