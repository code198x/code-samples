  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 10; "*** SONAR ***"
  25 PRINT AT 8, 4; "Find 3 hidden targets on"
  27 PRINT AT 9, 4; "an 8x8 grid."
  30 PRINT AT 11, 4; "Hits show *"
  32 PRINT AT 12, 4; "Misses show distance."
  35 PRINT AT 14, 4; "Red = close. Blue = far."
  40 PRINT AT 18, 4; "Press any key to start"
  45 PAUSE 0
  50 RANDOMIZE
  55 DIM g(8,8)
  60 FOR i = 1 TO 3
  62 LET r = INT (RND * 8) + 1: LET c = INT (RND * 8) + 1
  64 IF g(r,c) = 9 THEN GO TO 62
  66 LET g(r,c) = 9
  68 NEXT i
  70 LET hits = 0: LET guesses = 0
  75 CLS
  85 PRINT AT 0, 10; "*** SONAR ***"
  87 PRINT AT 1, 2; "Found: "; hits; "/3  Guesses: "; guesses; "  "
  90 PRINT AT 3, 11; "12345678"
  95 FOR r = 1 TO 8
  96 PRINT AT 3 + r, 9; r;
  99 FOR c = 1 TO 8
 100 LET v = g(r,c)
 101 IF v = 9 OR v = 0 THEN INK 7: PRINT ".";
 103 IF v = -1 THEN INK 4: PRINT "*";
 105 IF v >= 1 AND v <= 2 THEN INK 2: PRINT v;
 106 IF v >= 3 AND v <= 4 THEN INK 6: PRINT v;
 107 IF v >= 5 AND v < 9 THEN INK 5: PRINT v;
 104 NEXT c
 108 INK 7
 109 NEXT r
 120 INPUT "Row (1-8): "; r
 122 INPUT "Col (1-8): "; c
 125 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 120
 127 IF g(r,c) > 0 AND g(r,c) < 9 THEN PRINT AT 13, 2; "Already probed!  ": PAUSE 50: GO TO 75
 128 IF g(r,c) = -1 THEN PRINT AT 13, 2; "Already found!   ": PAUSE 50: GO TO 75
 130 LET guesses = guesses + 1
 135 IF guesses > 30 THEN GO TO 450
 200 IF g(r,c) = 9 THEN GO TO 300
 210 LET dist = 99
 215 FOR a = 1 TO 8: FOR b = 1 TO 8
 220 IF g(a,b) <> 9 THEN GO TO 240
 225 LET d = ABS (r - a) + ABS (c - b)
 230 IF d < dist THEN LET dist = d
 240 NEXT b: NEXT a
 250 LET g(r,c) = dist
 260 BEEP 0.1, -5
 270 GO TO 75
 300 LET g(r,c) = -1
 310 LET hits = hits + 1
 320 BEEP 0.1, 10: BEEP 0.1, 15
 330 IF hits = 3 THEN GO TO 400
 340 GO TO 75
 400 CLS
 410 PRINT AT 6, 10; "*** SONAR ***"
 420 PRINT AT 9, 6; INK 4; "All targets found!"
 430 PRINT AT 11, 6; INK 7; "Guesses: "; guesses
 440 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 445 STOP
 450 CLS
 460 PRINT AT 6, 10; "*** SONAR ***"
 465 PRINT AT 9, 6; INK 2; "Out of probes!"
 467 PRINT AT 11, 6; INK 7; "Targets were at:"
 468 LET n = 12
 469 FOR a = 1 TO 8: FOR b = 1 TO 8
 470 IF g(a,b) = 9 THEN PRINT AT n, 8; "("; a; ","; b; ")": LET n = n + 1
 472 NEXT b: NEXT a
 475 BEEP 0.3, -10
