10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM m(8, 8)
30 DIM s(8, 8)
40 LET r = 1: LET c = 1
50 LET s(1, 1) = 1
60 LET f = 0: LET w = 53: LET n = 10
70 REM place mines
80 FOR i = 1 TO n
90 LET y = INT (RND * 8) + 1
100 LET x = INT (RND * 8) + 1
110 IF m(y, x) = 9 THEN GO TO 90
120 IF y = 1 AND x = 1 THEN GO TO 90
130 LET m(y, x) = 9
140 NEXT i
150 GO SUB 500
155 LET r = 1: LET c = 1
160 REM draw column headers
170 INK 5
180 FOR i = 1 TO 8
190 PRINT AT 2, i * 2 + 1; i
200 NEXT i
210 REM draw row headers
220 FOR i = 1 TO 8
230 PRINT AT i + 2, 0; i
240 NEXT i
250 INK 7
260 GO SUB 600
270 GO SUB 700
280 REM game loop
290 PRINT AT r + 2, c * 2; INK 4; BRIGHT 1; "[": PRINT AT r + 2, c * 2 + 2; "]"
300 LET k$ = INKEY$
310 IF k$ = "" THEN GO TO 300
320 GO SUB 600
330 IF k$ = "q" AND r > 1 THEN LET r = r - 1
340 IF k$ = "a" AND r < 8 THEN LET r = r + 1
350 IF k$ = "o" AND c > 1 THEN LET c = c - 1
360 IF k$ = "p" AND c < 8 THEN LET c = c + 1
370 IF k$ <> " " THEN GO TO 395
380 IF s(r, c) <> 0 THEN GO TO 395
390 LET s(r, c) = 1: LET w = w - 1: BEEP 0.05, 15: IF m(r, c) = 9 THEN GO TO 800
395 IF k$ = "f" AND s(r, c) = 0 THEN LET s(r, c) = 2: LET f = f + 1: BEEP 0.05, 5
396 IF k$ = "f" AND s(r, c) = 2 THEN LET s(r, c) = 0: LET f = f - 1: BEEP 0.05, 5
398 GO SUB 700
399 IF w = 0 THEN GO TO 850
400 GO TO 280
500 REM === calculate counts ===
510 FOR r = 1 TO 8
520 FOR c = 1 TO 8
530 IF m(r, c) = 9 THEN GO TO 590
540 LET g = 0
550 FOR i = r - 1 TO r + 1
560 FOR j = c - 1 TO c + 1
570 IF i < 1 OR i > 8 OR j < 1 OR j > 8 THEN GO TO 582
580 IF m(i, j) = 9 THEN LET g = g + 1
582 NEXT j
584 NEXT i
586 LET m(r, c) = g
590 NEXT c
595 NEXT r
598 RETURN
600 REM === draw grid ===
610 FOR y = 1 TO 8
620 FOR x = 1 TO 8
630 IF s(y, x) = 0 THEN PRINT AT y + 2, x * 2 + 1; INK 1; "."
640 IF s(y, x) = 1 AND m(y, x) = 0 THEN PRINT AT y + 2, x * 2 + 1; INK 5; "-"
650 IF s(y, x) = 1 AND m(y, x) > 0 AND m(y, x) < 9 THEN PRINT AT y + 2, x * 2 + 1; INK 6; m(y, x)
660 IF s(y, x) = 1 AND m(y, x) = 9 THEN PRINT AT y + 2, x * 2 + 1; INK 2; "*"
670 IF s(y, x) = 2 THEN PRINT AT y + 2, x * 2 + 1; INK 3; "F"
680 NEXT x
690 NEXT y
695 RETURN
700 REM === draw HUD ===
710 PRINT AT 0, 0; INK 7; "Safe:"; w; " Flags:"; f; " Mines:10  "
720 RETURN
800 REM === game over ===
810 FOR y = 1 TO 8
820 FOR x = 1 TO 8
830 LET s(y, x) = 1
840 NEXT x
842 NEXT y
844 GO SUB 600
846 PRINT AT 13, 6; INK 2; "BOOM! Game Over"
848 BEEP 0.2, 0: BEEP 0.2, -3: BEEP 0.3, -7
849 STOP
850 REM === win ===
860 CLS
870 PRINT AT 8, 8; INK 4; "YOU WIN!"
880 PRINT AT 10, 6; "All safe cells revealed"
890 BEEP 0.15, 12: BEEP 0.15, 16: BEEP 0.3, 19
895 STOP
