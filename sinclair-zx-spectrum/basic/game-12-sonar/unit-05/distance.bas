 100 RANDOMIZE
 110 DIM g(8,8)
 120 FOR i = 1 TO 3
 130 LET r = INT (RND * 8) + 1: LET c = INT (RND * 8) + 1
 140 IF g(r,c) = 9 THEN GO TO 130
 150 LET g(r,c) = 9
 160 NEXT i
 180 CLS
 190 PRINT AT 0, 10; "*** SONAR ***"
 210 PRINT AT 3, 11; "12345678"
 220 FOR r = 1 TO 8
 230 PRINT AT 3 + r, 9; r;
 240 FOR c = 1 TO 8
 250 LET v = g(r,c)
 260 IF v = 9 THEN PRINT "X";
 270 IF v = 0 THEN PRINT ".";
 280 IF v = -1 THEN PRINT "*";
 290 NEXT c
 300 IF v >= 1 AND v < 9 THEN PRINT v;
 340 NEXT r
 350 INPUT "Row (1-8): "; r
 360 INPUT "Col (1-8): "; c
 370 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 350
 500 IF g(r,c) = 9 THEN PRINT AT 13, 2; "HIT!       ": LET g(r,c) = -1: PAUSE 30: GO TO 180
 510 LET dist = 99
 520 FOR a = 1 TO 8: FOR b = 1 TO 8
 530 IF g(a,b) <> 9 THEN GO TO 560
 540 LET d = ABS (r - a) + ABS (c - b)
 550 IF d < dist THEN LET dist = d
 560 NEXT b: NEXT a
 570 LET g(r,c) = dist
 580 PRINT AT 13, 2; "Distance: "; dist; "  "
 590 PAUSE 30
 600 GO TO 180
