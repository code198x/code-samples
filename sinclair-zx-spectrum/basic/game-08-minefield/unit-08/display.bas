10 CLS
20 DIM m(8, 8)
30 DIM s(8, 8)
40 REM place 10 mines
50 FOR i = 1 TO 10
60 LET r = INT (RND * 8) + 1
70 LET c = INT (RND * 8) + 1
80 IF m(r, c) = 9 THEN GO TO 60
90 LET m(r, c) = 9
100 NEXT i
110 REM calculate counts
120 GO SUB 500
130 REM draw grid
140 GO SUB 600
150 STOP
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
610 PRINT AT 1, 2;
620 FOR c = 1 TO 8
630 PRINT " "; c;
640 NEXT c
650 FOR r = 1 TO 8
660 PRINT AT r + 2, 0; r; " ";
670 FOR c = 1 TO 8
680 IF s(r, c) = 0 THEN PRINT INK 5; ".";
690 IF s(r, c) = 0 THEN GO TO 720
700 IF m(r, c) = 9 THEN PRINT INK 2; "*";
710 IF m(r, c) <> 9 THEN PRINT m(r, c);
720 PRINT " ";
730 NEXT c
740 NEXT r
750 RETURN
