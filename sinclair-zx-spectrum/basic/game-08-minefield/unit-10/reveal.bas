10 CLS
20 DIM m(8, 8)
30 DIM s(8, 8)
40 LET r = 1: LET c = 1
50 LET s(1, 1) = 1
60 REM place 10 mines
70 FOR i = 1 TO 10
80 LET y = INT (RND * 8) + 1
90 LET x = INT (RND * 8) + 1
100 IF m(y, x) = 9 THEN GO TO 80
110 IF y = 1 AND x = 1 THEN GO TO 80
120 LET m(y, x) = 9
130 NEXT i
140 GO SUB 500
145 LET r = 1: LET c = 1
150 GO SUB 600
160 PRINT AT 0, 0; "Q/A/O/P=move  SPACE=reveal"
170 REM game loop
180 PRINT AT r + 2, c * 2; INK 4; BRIGHT 1; "[": PRINT AT r + 2, c * 2 + 2; "]"
190 LET k$ = INKEY$
200 IF k$ = "" THEN GO TO 190
210 GO SUB 600
220 IF k$ = "q" AND r > 1 THEN LET r = r - 1
230 IF k$ = "a" AND r < 8 THEN LET r = r + 1
240 IF k$ = "o" AND c > 1 THEN LET c = c - 1
250 IF k$ = "p" AND c < 8 THEN LET c = c + 1
260 IF k$ = " " AND s(r, c) = 0 THEN LET s(r, c) = 1: BEEP 0.05, 15
270 IF k$ = " " AND m(r, c) = 9 THEN GO TO 400
280 GO TO 170
400 REM game over
410 REM reveal all
420 FOR y = 1 TO 8
430 FOR x = 1 TO 8
440 LET s(y, x) = 1
450 NEXT x
460 NEXT y
470 GO SUB 600
480 PRINT AT 12, 6; INK 2; "BOOM! Game Over"
490 BEEP 0.2, 0: BEEP 0.2, -3: BEEP 0.3, -7
495 STOP
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
670 NEXT x
680 NEXT y
690 RETURN
