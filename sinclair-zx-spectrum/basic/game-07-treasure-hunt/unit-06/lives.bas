10 CLS
20 LET r = 10
30 LET c = 15
40 LET n = 0
50 LET v = 3
60 LET f = 5
70 GO SUB 500
80 GO SUB 600
90 GO SUB 700
100 REM game loop
110 GO SUB 800
120 LET k$ = INKEY$
130 IF k$ = "" THEN GO TO 120
140 PRINT AT r, c; " "
150 IF k$ = "q" AND r > 1 THEN LET r = r - 1
160 IF k$ = "a" AND r < 20 THEN LET r = r + 1
170 IF k$ = "o" AND c > 0 THEN LET c = c - 1
180 IF k$ = "p" AND c < 31 THEN LET c = c + 1
190 LET a = ATTR (r, c)
200 IF a = 49 THEN LET n = n + 1: BEEP 0.05, 20: GO SUB 700
210 IF a = 58 THEN GO SUB 900
220 GO SUB 800
230 IF v = 0 THEN GO TO 400
240 GO TO 120
400 REM game over
410 PRINT AT 10, 10; "GAME OVER"
420 PRINT AT 12, 8; "Coins: "; n
430 BEEP 0.5, -10
440 STOP
500 REM === place coins ===
510 FOR i = 1 TO f
520 LET y = INT (RND * 19) + 2
530 LET x = INT (RND * 32)
540 INK 6: PRINT AT y, x; "*": INK 0
550 NEXT i
560 RETURN
600 REM === place hazards ===
610 FOR i = 1 TO 3
620 LET y = INT (RND * 19) + 2
630 LET x = INT (RND * 32)
640 INK 2: PRINT AT y, x; "#": INK 0
650 NEXT i
660 RETURN
700 REM === draw HUD ===
710 PRINT AT 0, 0; "Coins: "; n; "  Lives: "; v; "  "
720 RETURN
800 REM === draw player ===
810 INK 4: PRINT AT r, c; "O": INK 0
820 RETURN
900 REM === lose life ===
910 LET v = v - 1
920 BEEP 0.2, -5
930 GO SUB 700
940 LET r = 10: LET c = 15
950 RETURN
