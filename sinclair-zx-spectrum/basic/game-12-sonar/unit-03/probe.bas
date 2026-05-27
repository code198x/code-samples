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
 260 IF g(r,c) = 9 THEN PRINT "X";
 270 IF g(r,c) = 0 THEN PRINT ".";
 290 NEXT c
 340 NEXT r
 350 INPUT "Row (1-8): "; r
 360 INPUT "Col (1-8): "; c
 370 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 350
 400 PRINT AT 13, 2; "Probed ("; r; ","; c; ")  "
 410 PAUSE 30
 420 GO TO 180
