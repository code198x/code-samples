10 REM Minefield
20 BORDER 0: PAPER 0: INK 7: CLS
30 INK 6: PRINT AT 3, 10; "MINEFIELD": INK 7
40 PRINT AT 7, 3; "Reveal all safe cells to win."
50 PRINT AT 8, 3; "Hit a mine and its game over!"
60 PRINT AT 11, 3; "Controls:"
70 PRINT AT 12, 5; INK 5; "Q"; INK 7; " Up    "; INK 5; "A"; INK 7; " Down"
80 PRINT AT 13, 5; INK 5; "O"; INK 7; " Left   "; INK 5; "P"; INK 7; " Right"
90 PRINT AT 14, 5; INK 5; "SPACE"; INK 7; " Reveal  "; INK 5; "F"; INK 7; " Flag"
100 PRINT AT 17, 3; "Difficulty:"
110 PRINT AT 18, 5; "1. Easy (5)  2. Medium (10)"
120 PRINT AT 19, 5; "3. Hard (15)"
130 INK 3: PRINT AT 21, 5; "Press 1, 2 or 3 to start": INK 7
140 LET k$ = INKEY$
150 IF k$ < "1" OR k$ > "3" THEN GO TO 140
160 LET d = VAL k$
170 IF d = 1 THEN LET n = 5
180 IF d = 2 THEN LET n = 10
190 IF d = 3 THEN LET n = 15
200 CLS
210 DIM m(8, 8)
220 DIM s(8, 8)
230 LET r = 1: LET c = 1
240 LET s(1, 1) = 1
250 LET f = 0: LET w = 64 - n - 1
260 LET v = 0
270 REM place mines
280 FOR i = 1 TO n
290 LET y = INT (RND * 8) + 1
300 LET x = INT (RND * 8) + 1
310 IF m(y, x) = 9 THEN GO TO 290
320 IF y = 1 AND x = 1 THEN GO TO 290
330 LET m(y, x) = 9
340 NEXT i
350 GO SUB 1000
355 LET r = 1: LET c = 1
360 REM draw headers
370 INK 5
380 FOR i = 1 TO 8
390 PRINT AT 2, i * 2 + 1; i
400 PRINT AT i + 2, 0; i
410 NEXT i
420 INK 7
430 GO SUB 1100
440 GO SUB 1200
450 REM === game loop ===
460 PRINT AT r + 2, c * 2; INK 4; BRIGHT 1; "[": PRINT AT r + 2, c * 2 + 2; "]"
470 LET k$ = INKEY$
480 IF k$ = "" THEN GO TO 470
490 GO SUB 1100
500 IF k$ = "q" AND r > 1 THEN LET r = r - 1
510 IF k$ = "a" AND r < 8 THEN LET r = r + 1
520 IF k$ = "o" AND c > 1 THEN LET c = c - 1
530 IF k$ = "p" AND c < 8 THEN LET c = c + 1
540 IF k$ <> " " THEN GO TO 580
550 IF s(r, c) <> 0 THEN GO TO 580
560 LET s(r, c) = 1: LET w = w - 1: LET v = v + 1: BEEP 0.05, 15
570 IF m(r, c) = 9 THEN GO TO 700
580 IF k$ = "f" AND s(r, c) = 0 THEN LET s(r, c) = 2: LET f = f + 1: BEEP 0.05, 5
590 IF k$ = "f" AND s(r, c) = 2 THEN LET s(r, c) = 0: LET f = f - 1: BEEP 0.05, 5
600 GO SUB 1200
610 IF w = 0 THEN GO TO 750
620 GO TO 450
700 REM === game over ===
710 FOR y = 1 TO 8
720 FOR x = 1 TO 8
730 LET s(y, x) = 1
740 NEXT x
745 NEXT y
750 GO SUB 1100
755 IF w = 0 THEN GO TO 800
760 CLS
770 INK 2: PRINT AT 5, 9; "GAME OVER": INK 7
780 PRINT AT 8, 7; "You hit a mine!"
790 PRINT AT 10, 7; "Moves: "; v
795 IF n = 5 THEN PRINT AT 11, 7; "Difficulty: Easy"
796 IF n = 10 THEN PRINT AT 11, 7; "Difficulty: Medium"
797 IF n = 15 THEN PRINT AT 11, 7; "Difficulty: Hard"
798 BEEP 0.2, 0: BEEP 0.2, -3: BEEP 0.3, -7
799 GO TO 900
800 REM === win ===
810 CLS
820 INK 4: PRINT AT 5, 9; "YOU WIN!": INK 7
830 PRINT AT 8, 5; "All safe cells revealed!"
840 PRINT AT 10, 7; "Moves: "; v
845 IF n = 5 THEN PRINT AT 11, 7; "Difficulty: Easy"
846 IF n = 10 THEN PRINT AT 11, 7; "Difficulty: Medium"
847 IF n = 15 THEN PRINT AT 11, 7; "Difficulty: Hard"
850 IF v < n * 3 THEN PRINT AT 13, 6; "Master minesweeper!"
860 IF v >= n * 3 AND v < n * 5 THEN PRINT AT 13, 8; "Well done!"
870 IF v >= n * 5 THEN PRINT AT 13, 5; "Better luck next time!"
880 BEEP 0.15, 12: BEEP 0.15, 16: BEEP 0.3, 19
900 REM === end screen ===
910 INK 3: PRINT AT 20, 5; "Press any key to exit": INK 7
920 IF INKEY$ <> "" THEN GO TO 920
930 IF INKEY$ = "" THEN GO TO 930
940 BORDER 7: PAPER 7: INK 0: CLS
950 STOP
1000 REM === calculate counts ===
1010 FOR r = 1 TO 8
1020 FOR c = 1 TO 8
1030 IF m(r, c) = 9 THEN GO TO 1090
1040 LET g = 0
1050 FOR i = r - 1 TO r + 1
1060 FOR j = c - 1 TO c + 1
1070 IF i < 1 OR i > 8 OR j < 1 OR j > 8 THEN GO TO 1082
1080 IF m(i, j) = 9 THEN LET g = g + 1
1082 NEXT j
1084 NEXT i
1086 LET m(r, c) = g
1090 NEXT c
1095 NEXT r
1098 RETURN
1100 REM === draw grid ===
1110 FOR y = 1 TO 8
1120 FOR x = 1 TO 8
1130 IF s(y, x) = 0 THEN PRINT AT y + 2, x * 2 + 1; INK 1; "."
1140 IF s(y, x) = 1 AND m(y, x) = 0 THEN PRINT AT y + 2, x * 2 + 1; INK 5; "-"
1150 IF s(y, x) = 1 AND m(y, x) > 0 AND m(y, x) < 9 THEN PRINT AT y + 2, x * 2 + 1; INK 6; m(y, x)
1160 IF s(y, x) = 1 AND m(y, x) = 9 THEN PRINT AT y + 2, x * 2 + 1; INK 2; "*"
1170 IF s(y, x) = 2 THEN PRINT AT y + 2, x * 2 + 1; INK 3; "F"
1180 NEXT x
1190 NEXT y
1195 RETURN
1200 REM === draw HUD ===
1210 PRINT AT 0, 0; INK 7; "Safe:"; w; " Flags:"; f; " Mines:"; n; "  "
1220 PRINT AT 1, 0; INK 7; "Moves:"; v; "  "
1230 RETURN
