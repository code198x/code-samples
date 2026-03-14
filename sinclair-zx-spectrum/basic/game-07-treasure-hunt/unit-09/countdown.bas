10 CLS
20 LET r = 10
30 LET c = 15
40 LET n = 0
50 LET v = 3
60 LET l = 1
70 GO SUB 500
80 GO SUB 600
90 LET m = 500
100 LET t = PEEK 23672 + 256 * PEEK 23673
110 REM game loop
120 GO SUB 800
130 GO SUB 700
140 LET k$ = INKEY$
150 IF k$ = "" THEN GO TO 200
160 PRINT AT r, c; " "
170 IF k$ = "q" AND r > 1 THEN LET r = r - 1
180 IF k$ = "a" AND r < 20 THEN LET r = r + 1
190 IF k$ = "o" AND c > 0 THEN LET c = c - 1
195 IF k$ = "p" AND c < 31 THEN LET c = c + 1
200 LET a = ATTR (r, c)
210 IF a = 49 THEN LET n = n + 1: BEEP 0.05, 20: LET f = f - 1
220 IF a = 58 THEN GO SUB 900
230 GO SUB 800
240 IF v = 0 THEN GO TO 400
250 IF f = 0 THEN GO SUB 1000
260 LET e = PEEK 23672 + 256 * PEEK 23673
270 LET d = INT ((e - t) / 50)
280 IF d >= m THEN GO TO 400
290 GO TO 130
400 REM game over
410 CLS
420 PRINT AT 8, 10; "GAME OVER"
430 PRINT AT 10, 8; "Level: "; l
440 PRINT AT 11, 8; "Coins: "; n
450 BEEP 0.5, -10
460 STOP
500 REM === place coins ===
510 LET g = 5 + l
520 LET f = g
530 FOR i = 1 TO g
540 LET y = INT (RND * 19) + 2
550 LET x = INT (RND * 32)
560 INK 6: PRINT AT y, x; "*": INK 0
570 NEXT i
580 RETURN
600 REM === place hazards ===
610 FOR i = 1 TO 1 + l
620 LET y = INT (RND * 19) + 2
630 LET x = INT (RND * 32)
640 INK 2: PRINT AT y, x; "#": INK 0
650 NEXT i
660 RETURN
700 REM === draw HUD ===
710 LET e = PEEK 23672 + 256 * PEEK 23673
720 LET d = INT ((e - t) / 50)
730 LET w = m - d
740 IF w < 0 THEN LET w = 0
750 PRINT AT 0, 0; "L:"; l; " C:"; f; " V:"; v; " T:"; w; "  "
760 RETURN
800 REM === draw player ===
810 INK 4: PRINT AT r, c; "O": INK 0
820 RETURN
900 REM === lose life ===
910 LET v = v - 1
920 BEEP 0.2, -5
930 LET r = 10: LET c = 15
940 RETURN
1000 REM === next level ===
1010 LET l = l + 1
1020 BEEP 0.2, 12: BEEP 0.2, 16: BEEP 0.3, 19
1030 CLS
1040 PRINT AT 10, 8; "Level "; l; "!"
1050 PAUSE 50
1060 CLS
1070 LET r = 10: LET c = 15
1080 GO SUB 500
1090 GO SUB 600
1100 LET t = PEEK 23672 + 256 * PEEK 23673
1110 RETURN
