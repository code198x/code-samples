10 CLS
20 DIM m(8, 8)
30 DIM s(8, 8)
40 LET r = 1: LET c = 1
50 REM place 10 mines
60 FOR i = 1 TO 10
70 LET y = INT (RND * 8) + 1
80 LET x = INT (RND * 8) + 1
90 IF m(y, x) = 9 THEN GO TO 70
100 IF y = 1 AND x = 1 THEN GO TO 70
110 LET m(y, x) = 9
120 NEXT i
130 GO SUB 500
135 LET r = 1: LET c = 1
140 GO SUB 600
150 REM game loop
160 REM highlight cursor
170 PRINT AT r + 2, c * 2; INK 4; BRIGHT 1; "[": PRINT AT r + 2, c * 2 + 2; "]"
180 LET k$ = INKEY$
190 IF k$ = "" THEN GO TO 180
200 REM clear cursor
210 GO SUB 600
220 IF k$ = "q" AND r > 1 THEN LET r = r - 1
230 IF k$ = "a" AND r < 8 THEN LET r = r + 1
240 IF k$ = "o" AND c > 1 THEN LET c = c - 1
250 IF k$ = "p" AND c < 8 THEN LET c = c + 1
260 GO TO 160
270 STOP
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
610 FOR r = 1 TO 8
620 FOR c = 1 TO 8
630 IF s(r, c) = 0 THEN PRINT AT r + 2, c * 2 + 1; INK 5; "."
640 IF s(r, c) = 1 AND m(r, c) = 0 THEN PRINT AT r + 2, c * 2 + 1; " "
650 IF s(r, c) = 1 AND m(r, c) > 0 AND m(r, c) < 9 THEN PRINT AT r + 2, c * 2 + 1; INK 6; m(r, c)
660 IF s(r, c) = 1 AND m(r, c) = 9 THEN PRINT AT r + 2, c * 2 + 1; INK 2; "*"
670 NEXT c
680 NEXT r
690 RETURN
