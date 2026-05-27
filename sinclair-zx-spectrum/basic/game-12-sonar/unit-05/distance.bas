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
 100 LET v = g(r,c)
 101 IF v = 9 THEN PRINT "X";
 102 IF v = 0 THEN PRINT ".";
 103 IF v = -1 THEN PRINT "*";
 105 IF v >= 1 AND v < 9 THEN PRINT v;
 104 NEXT c
 109 NEXT r
 120 INPUT "Row (1-8): "; r
 122 INPUT "Col (1-8): "; c
 125 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 120
 200 IF g(r,c) = 9 THEN PRINT AT 13, 2; "HIT!       ": LET g(r,c) = -1: PAUSE 30: GO TO 75
 210 LET dist = 99
 215 FOR a = 1 TO 8: FOR b = 1 TO 8
 220 IF g(a,b) <> 9 THEN GO TO 240
 225 LET d = ABS (r - a) + ABS (c - b)
 230 IF d < dist THEN LET dist = d
 240 NEXT b: NEXT a
 250 LET g(r,c) = dist
 260 PRINT AT 13, 2; "Distance: "; dist; "  "
 265 PAUSE 30
 270 GO TO 75
