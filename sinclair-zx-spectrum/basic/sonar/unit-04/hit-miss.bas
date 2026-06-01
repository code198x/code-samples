  10 BORDER 0: PAPER 0: INK 7: CLS
 110 RANDOMIZE
 120 DIM g(8,8)
 130 FOR i = 1 TO 3
 140 LET r = INT (RND * 8) + 1: LET c = INT (RND * 8) + 1
 150 IF g(r,c) = 9 THEN GO TO 140
 160 LET g(r,c) = 9
 170 NEXT i
 190 CLS
 200 LET a$ = "*** SONAR ***": LET y = 0: GO SUB 9000
 240 PRINT AT 3, 11; "12345678"
 250 FOR r = 1 TO 8
 260 PRINT AT 3 + r, 9; r;
 270 FOR c = 1 TO 8
 280 LET v = g(r,c)
 290 IF v = 9 THEN PRINT "X";
 300 IF v = 0 THEN PRINT ".";
 310 IF v = -1 THEN PRINT "*";
 320 NEXT c
 370 NEXT r
 380 INPUT "Row (1-8): "; r
 390 INPUT "Col (1-8): "; c
 400 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 380
 460 IF g(r,c) = 9 THEN PRINT AT 13, 2; "HIT!       ": LET g(r,c) = -1: PAUSE 30: GO TO 190
 470 PRINT AT 13, 2; "Miss       "
 490 PAUSE 30
 510 GO TO 190

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
