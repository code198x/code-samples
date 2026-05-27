  50 RANDOMIZE
  55 DIM g(8,8)
  60 FOR i = 1 TO 3
  62 LET r = INT (RND * 8) + 1: LET c = INT (RND * 8) + 1
  64 IF g(r,c) = 9 THEN GO TO 62
  66 LET g(r,c) = 9
  68 NEXT i
  75 CLS
  85 PRINT AT 0, 10; "*** SONAR ***"
  90 PRINT AT 3, 11; "12345678"
  95 FOR r = 1 TO 8
  96 PRINT AT 3 + r, 9; r;
  99 FOR c = 1 TO 8
 101 IF g(r,c) = 9 THEN PRINT "X";
 102 IF g(r,c) = 0 THEN PRINT ".";
 104 NEXT c
 109 NEXT r
 120 INPUT "Row (1-8): "; r
 122 INPUT "Col (1-8): "; c
 125 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 120
 130 PRINT AT 13, 2; "Probed ("; r; ","; c; ")  "
 135 PAUSE 30
 140 GO TO 75
