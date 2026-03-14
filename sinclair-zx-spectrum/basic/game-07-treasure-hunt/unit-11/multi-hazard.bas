10 CLS
20 LET r = 10
30 LET c = 15
40 LET n = 0
50 LET v = 3
60 DIM b(3)
70 DIM d(3)
80 REM hazard starting rows
90 LET b(1) = 4: LET d(1) = 1
100 LET b(2) = 10: LET d(2) = -1
110 LET b(3) = 16: LET d(3) = 1
120 REM place coins
130 FOR i = 1 TO 5
140 LET y = INT (RND * 19) + 2
150 LET x = INT (RND * 32)
160 INK 6: PRINT AT y, x; "*": INK 0
170 NEXT i
180 LET f = 5
190 GO SUB 700
200 REM game loop
210 GO SUB 800
220 REM move hazards
230 FOR j = 1 TO 3
240 PRINT AT b(j), 0; "                                "
250 LET b(j) = b(j) + d(j)
260 IF b(j) > 20 OR b(j) < 2 THEN LET d(j) = -d(j): LET b(j) = b(j) + d(j)
270 INK 2: PRINT AT b(j), 0; "--------------------------------": INK 0
280 NEXT j
290 REM check hazard collision
300 FOR j = 1 TO 3
310 IF r = b(j) THEN GO SUB 900: GO TO 340
320 NEXT j
330 GO TO 350
340 REM fell through from collision
350 LET k$ = INKEY$
360 IF k$ = "" THEN GO TO 400
370 PRINT AT r, c; " "
380 IF k$ = "q" AND r > 1 THEN LET r = r - 1
385 IF k$ = "a" AND r < 20 THEN LET r = r + 1
390 IF k$ = "o" AND c > 0 THEN LET c = c - 1
395 IF k$ = "p" AND c < 31 THEN LET c = c + 1
400 IF ATTR (r, c) = 49 THEN LET n = n + 1: LET f = f - 1: BEEP 0.05, 20: GO SUB 700
410 GO SUB 800
420 IF v = 0 THEN GO TO 500
430 GO TO 200
500 CLS
510 PRINT AT 10, 10; "GAME OVER"
520 PRINT AT 12, 8; "Coins: "; n
530 BEEP 0.5, -10
540 STOP
700 REM === draw HUD ===
710 PRINT AT 0, 0; "Coins:"; f; " Lives:"; v; "  "
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
