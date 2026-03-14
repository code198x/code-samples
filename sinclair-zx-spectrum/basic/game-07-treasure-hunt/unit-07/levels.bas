10 CLS
20 LET r = 10
30 LET c = 15
40 LET n = 0
50 LET v = 3
60 LET l = 1
70 LET f = 5
80 LET h = 2
90 GO SUB 500
100 GO SUB 600
110 GO SUB 700
120 REM game loop
130 GO SUB 800
140 LET k$ = INKEY$
150 IF k$ = "" THEN GO TO 140
160 PRINT AT r, c; " "
170 IF k$ = "q" AND r > 1 THEN LET r = r - 1
180 IF k$ = "a" AND r < 20 THEN LET r = r + 1
190 IF k$ = "o" AND c > 0 THEN LET c = c - 1
200 IF k$ = "p" AND c < 31 THEN LET c = c + 1
210 LET a = ATTR (r, c)
220 IF a = 49 THEN LET n = n + 1: BEEP 0.05, 20: LET f = f - 1: GO SUB 700
230 IF a = 58 THEN GO SUB 900
240 GO SUB 800
250 IF v = 0 THEN GO TO 400
260 IF f = 0 THEN GO SUB 1000
270 GO TO 140
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
610 FOR i = 1 TO h
620 LET y = INT (RND * 19) + 2
630 LET x = INT (RND * 32)
640 INK 2: PRINT AT y, x; "#": INK 0
650 NEXT i
660 RETURN
700 REM === draw HUD ===
710 PRINT AT 0, 0; "L:"; l; " Coins:"; f; "  Lives:"; v; "  "
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
1000 REM === next level ===
1010 LET l = l + 1
1020 LET h = h + 1
1030 BEEP 0.2, 12: BEEP 0.2, 16: BEEP 0.3, 19
1040 CLS
1050 PRINT AT 10, 8; "Level "; l; "!"
1060 PAUSE 50
1070 CLS
1080 LET r = 10: LET c = 15
1090 GO SUB 500
1100 GO SUB 600
1110 GO SUB 700
1120 RETURN
