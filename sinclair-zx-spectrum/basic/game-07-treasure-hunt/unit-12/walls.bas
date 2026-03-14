10 CLS
20 LET r = 10
30 LET c = 15
40 LET n = 0
50 LET v = 3
60 LET f = 5
70 REM draw walls
80 INK 1
90 FOR i = 0 TO 31
100 PRINT AT 1, i; "="
110 PRINT AT 21, i; "="
120 NEXT i
130 FOR i = 1 TO 21
140 PRINT AT i, 0; "|"
150 PRINT AT i, 31; "|"
160 NEXT i
170 REM inner walls
180 FOR i = 5 TO 15
190 PRINT AT 7, i; "="
200 PRINT AT 14, i + 10; "="
210 NEXT i
220 INK 0
230 REM place coins
240 FOR i = 1 TO f
250 LET y = INT (RND * 18) + 2
260 LET x = INT (RND * 29) + 1
270 IF ATTR (y, x) = 56 THEN INK 6: PRINT AT y, x; "*": INK 0: GO TO 290
280 GO TO 250
290 NEXT i
300 GO SUB 700
310 REM game loop
320 GO SUB 800
330 LET k$ = INKEY$
340 IF k$ = "" THEN GO TO 330
350 LET u = r: LET w = c
360 IF k$ = "q" THEN LET u = r - 1
370 IF k$ = "a" THEN LET u = r + 1
380 IF k$ = "o" THEN LET w = c - 1
390 IF k$ = "p" THEN LET w = c + 1
400 LET a = ATTR (u, w)
410 IF a = 57 THEN GO TO 330
420 PRINT AT r, c; " "
430 LET r = u: LET c = w
440 IF a = 49 THEN LET n = n + 1: LET f = f - 1: BEEP 0.05, 20: GO SUB 700
450 GO SUB 800
460 IF v = 0 THEN GO TO 500
470 IF f = 0 THEN GO TO 500
480 GO TO 330
500 CLS
510 IF f = 0 THEN PRINT AT 10, 9; "LEVEL CLEAR!"
520 IF f > 0 THEN PRINT AT 10, 10; "GAME OVER"
530 PRINT AT 12, 8; "Coins: "; n
540 STOP
700 REM === draw HUD ===
710 PRINT AT 0, 0; "Coins:"; f; " Lives:"; v; "  "
720 RETURN
800 REM === draw player ===
810 INK 4: PRINT AT r, c; "O": INK 0
820 RETURN
