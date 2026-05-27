  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 10; BRIGHT 1; "*** SONAR ***"
  30 PRINT AT 8, 4; "Find 3 hidden targets on"
  40 PRINT AT 9, 4; "an 8x8 grid."
  50 PRINT AT 11, 4; "Hits show *"
  60 PRINT AT 12, 4; "Misses show distance."
  70 PRINT AT 14, 4; "Red = close. Blue = far."
  80 PRINT AT 18, 4; "Press any key to start"
  90 PAUSE 0
 100 RANDOMIZE
 110 DIM g(8,8)
 120 FOR i = 1 TO 3
 130 LET r = INT (RND * 8) + 1: LET c = INT (RND * 8) + 1
 140 IF g(r,c) = 9 THEN GO TO 130
 150 LET g(r,c) = 9
 160 NEXT i
 170 LET hits = 0: LET guesses = 0
 180 CLS
 190 INVERSE 1: PRINT AT 0, 0; "        *** SONAR ***           ": INVERSE 0
 200 PRINT AT 1, 2; "Found: "; hits; "/3  Guesses: "; guesses; "  "
 210 PRINT AT 3, 11; "12345678"
 220 FOR r = 1 TO 8
 230 PRINT AT 3 + r, 9; r;
 240 FOR c = 1 TO 8
 250 LET v = g(r,c)
 260 IF v = 9 OR v = 0 THEN INK 7: PRINT ".";
 280 IF v = -1 THEN INK 4: PRINT "*";
 290 NEXT c
 300 IF v >= 1 AND v <= 2 THEN INK 2: PRINT v;
 310 IF v >= 3 AND v <= 4 THEN INK 6: PRINT v;
 320 IF v >= 5 AND v < 9 THEN INK 5: PRINT v;
 330 INK 7
 340 NEXT r
 350 INPUT "Row (1-8): "; r
 360 INPUT "Col (1-8): "; c
 370 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 350
 380 IF g(r,c) > 0 AND g(r,c) < 9 THEN PRINT AT 13, 2; "Already probed!  ": PAUSE 50: GO TO 180
 390 IF g(r,c) = -1 THEN PRINT AT 13, 2; "Already found!   ": PAUSE 50: GO TO 180
 400 LET guesses = guesses + 1
 410 IF guesses > 30 THEN GO TO 800
 500 IF g(r,c) = 9 THEN GO TO 610
 510 LET dist = 99
 520 FOR a = 1 TO 8: FOR b = 1 TO 8
 530 IF g(a,b) <> 9 THEN GO TO 560
 540 LET d = ABS (r - a) + ABS (c - b)
 550 IF d < dist THEN LET dist = d
 560 NEXT b: NEXT a
 570 LET g(r,c) = dist
 580 BEEP 0.1, -5
 600 GO TO 180
 610 LET g(r,c) = -1
 620 LET hits = hits + 1
 630 BEEP 0.1, 10: BEEP 0.1, 15
 640 IF hits = 3 THEN GO TO 700
 650 GO TO 180
 700 CLS
 710 PRINT AT 6, 10; BRIGHT 1; "*** SONAR ***"
 720 PRINT AT 9, 6; INK 4; "All targets found!"
 730 PRINT AT 11, 6; INK 7; "Guesses: "; guesses
 740 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 750 IF guesses <= 10 THEN INK 4: PRINT AT 14, 8; "Expert tracker!": GO TO 890
 760 IF guesses <= 20 THEN INK 5: PRINT AT 14, 10; "Not bad": GO TO 890
 780 INK 6: PRINT AT 14, 8; "Keep searching"
 790 GO TO 890
 800 CLS
 810 PRINT AT 6, 10; BRIGHT 1; "*** SONAR ***"
 820 PRINT AT 9, 6; INK 2; "Out of probes!"
 830 PRINT AT 11, 6; INK 7; "Targets were at:"
 840 LET n = 12
 850 FOR a = 1 TO 8: FOR b = 1 TO 8
 860 IF g(a,b) = 9 THEN PRINT AT n, 8; "("; a; ","; b; ")": LET n = n + 1
 870 NEXT b: NEXT a
 880 BEEP 0.3, -10
 890 INK 7
 900 PRINT AT 18, 4; "Press any key to play again"
 910 PAUSE 0
 920 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
