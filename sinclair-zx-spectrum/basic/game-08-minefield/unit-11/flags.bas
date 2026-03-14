10 CLS
20 DIM m(8, 8)
30 DIM s(8, 8)
40 LET r = 1: LET c = 1
50 LET s(1, 1) = 1
60 LET f = 0
70 REM place 10 mines
80 FOR i = 1 TO 10
90 LET y = INT (RND * 8) + 1
100 LET x = INT (RND * 8) + 1
110 IF m(y, x) = 9 THEN GO TO 90
120 IF y = 1 AND x = 1 THEN GO TO 90
130 LET m(y, x) = 9
140 NEXT i
150 GO SUB 500
155 LET r = 1: LET c = 1
160 GO SUB 600
170 PRINT AT 0, 0; "SPACE=reveal F=flag"
180 PRINT AT 1, 0; "Flags: "; f; " / 10"
190 REM game loop
200 PRINT AT r + 2, c * 2; INK 4; BRIGHT 1; "[": PRINT AT r + 2, c * 2 + 2; "]"
210 LET k$ = INKEY$
220 IF k$ = "" THEN GO TO 210
230 GO SUB 600
240 IF k$ = "q" AND r > 1 THEN LET r = r - 1
250 IF k$ = "a" AND r < 8 THEN LET r = r + 1
260 IF k$ = "o" AND c > 1 THEN LET c = c - 1
270 IF k$ = "p" AND c < 8 THEN LET c = c + 1
280 IF k$ = " " AND s(r, c) = 0 THEN LET s(r, c) = 1: BEEP 0.05, 15
290 IF k$ = " " AND m(r, c) = 9 THEN GO TO 400
300 IF k$ = "f" AND s(r, c) = 0 THEN LET s(r, c) = 2: LET f = f + 1: BEEP 0.05, 5
310 IF k$ = "f" AND s(r, c) = 2 THEN LET s(r, c) = 0: LET f = f - 1: BEEP 0.05, 5
320 PRINT AT 1, 7; f; " "
330 GO TO 190
400 REM game over
410 FOR y = 1 TO 8
420 FOR x = 1 TO 8
430 LET s(y, x) = 1
440 NEXT x
450 NEXT y
460 GO SUB 600
470 PRINT AT 12, 6; INK 2; "BOOM! Game Over"
480 BEEP 0.2, 0: BEEP 0.2, -3: BEEP 0.3, -7
490 STOP
500 REM === calculate counts ===
510 FOR r = 1 TO 8
520 FOR c = 1 TO 8
530 IF m(r, c) = 9 THEN GO TO 590
540 LET n = 0
550 FOR i = r - 1 TO r + 1
560 FOR j = c - 1 TO c + 1
570 IF i < 1 OR i > 8 OR j < 1 OR j > 8 THEN GO TO 582
580 IF m(i, j) = 9 THEN LET n = n + 1
582 NEXT j
584 NEXT i
586 LET m(r, c) = n
590 NEXT c
595 NEXT r
598 RETURN
600 REM === draw grid ===
610 FOR y = 1 TO 8
620 FOR x = 1 TO 8
630 IF s(y, x) = 0 THEN PRINT AT y + 2, x * 2 + 1; INK 5; "."
640 IF s(y, x) = 1 AND m(y, x) = 0 THEN PRINT AT y + 2, x * 2 + 1; " "
650 IF s(y, x) = 1 AND m(y, x) > 0 AND m(y, x) < 9 THEN PRINT AT y + 2, x * 2 + 1; INK 6; m(y, x)
660 IF s(y, x) = 1 AND m(y, x) = 9 THEN PRINT AT y + 2, x * 2 + 1; INK 2; "*"
670 IF s(y, x) = 2 THEN PRINT AT y + 2, x * 2 + 1; INK 3; "F"
680 NEXT x
690 NEXT y
695 RETURN
