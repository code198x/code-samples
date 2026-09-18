20 DIM b(9): LET moves = 0
320 LET b(n) = 1: LET moves = moves + 1: GO SUB 2000
330 GO SUB 3000
340 IF winner > 0 OR moves = 9 THEN GO TO 4900
600 PRINT AT 18,2; INK 6; "O is choosing...             "
610 GO SUB 4000
620 LET n = mv: LET b(n) = 2: LET moves = moves + 1: GO SUB 2000
630 PRINT AT 19,2; INK 5; "O chose "; mv; ": "; a$; "        "
640 GO SUB 3000
650 IF winner > 0 OR moves = 9 THEN GO TO 4900
660 PRINT AT 18,2; INK 7; "Your move: choose 1-9.        "
670 GO TO 250
1060 PRINT AT 18,2; INK 7; "Your move: choose 1-9."
4000 LET mv = 0
4010 FOR j = 1 TO 9
4020 IF mv = 0 AND b(j) = 0 THEN LET mv = j
4030 NEXT j: LET a$ = "first empty": RETURN
