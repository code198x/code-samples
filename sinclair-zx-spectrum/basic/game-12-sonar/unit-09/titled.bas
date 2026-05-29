  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET a$ = "*** SONAR ***": LET y = 5: GO SUB 9000
  30 PRINT AT 8, 4; "Find 3 hidden targets on"
  50 PRINT AT 9, 4; "an 8x8 grid."
  60 PRINT AT 11, 4; "Hits show *"
  70 PRINT AT 12, 4; "Misses show distance."
  80 PRINT AT 14, 4; "Red = close. Blue = far."
  90 PRINT AT 18, 4; "Press any key to start"
 100 PAUSE 0
 110 RANDOMIZE
 120 DIM g(8,8)
 130 FOR i = 1 TO 3
 140 LET r = INT (RND * 8) + 1: LET c = INT (RND * 8) + 1
 150 IF g(r,c) = 9 THEN GO TO 140
 160 LET g(r,c) = 9
 170 NEXT i
 180 LET hits = 0: LET guesses = 0
 190 CLS
 200 INVERSE 1: PRINT AT 0, 0; "        *** SONAR ***           ": INVERSE 0
 210 PRINT AT 1, 2; "Found: "; hits; "/3  Guesses: "; guesses; "  "
 240 PRINT AT 3, 11; "12345678"
 250 FOR r = 1 TO 8
 260 PRINT AT 3 + r, 9; r;
 270 FOR c = 1 TO 8
 280 LET v = g(r,c)
 290 IF v = 9 OR v = 0 THEN INK 7: PRINT ".";
 300 IF v = -1 THEN INK 4: PRINT "*";

 310 IF v >= 1 AND v <= 2 THEN INK 2: PRINT v;
 320 IF v >= 3 AND v <= 4 THEN INK 6: PRINT v;
 330 IF v >= 5 AND v < 9 THEN INK 5: PRINT v;
 340 NEXT c
 350 INK 7
 370 NEXT r
 380 INPUT "Row (1-8): "; r
 390 INPUT "Col (1-8): "; c
 400 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 380
 410 IF g(r,c) > 0 AND g(r,c) < 9 THEN PRINT AT 13, 2; "Already probed!  ": PAUSE 50: GO TO 190
 420 IF g(r,c) = -1 THEN PRINT AT 13, 2; "Already found!   ": PAUSE 50: GO TO 190
 430 LET guesses = guesses + 1
 440 IF guesses > 30 THEN GO TO 720
 460 IF g(r,c) = 9 THEN GO TO 570
 470 LET dist = 99
 480 FOR a = 1 TO 8: FOR b = 1 TO 8
 490 IF g(a,b) <> 9 THEN GO TO 520
 500 LET d = ABS (r - a) + ABS (c - b)
 510 IF d < dist THEN LET dist = d
 520 NEXT b: NEXT a: IF dist > 8 THEN LET dist = 8
 530 LET g(r,c) = dist
 540 BEEP 0.1, -5
 560 GO TO 190
 570 LET g(r,c) = -1
 580 LET hits = hits + 1
 590 BEEP 0.1, 10: BEEP 0.1, 15
 600 IF hits = 3 THEN GO TO 620
 610 GO TO 190
 620 CLS
 630 LET a$ = "*** SONAR ***": LET y = 6: GO SUB 9000
 640 PRINT AT 9, 6; INK 4; "All targets found!"
 650 PRINT AT 11, 6; INK 7; "Guesses: "; guesses
 660 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 690 STOP
 720 CLS
 730 LET a$ = "*** SONAR ***": LET y = 6: GO SUB 9000
 740 PRINT AT 9, 6; INK 2; "Out of probes!"
 750 PRINT AT 11, 6; INK 7; "Targets were at:"
 760 LET n = 12
 770 FOR a = 1 TO 8: FOR b = 1 TO 8
 780 IF g(a,b) = 9 THEN PRINT AT n, 8; "("; a; ","; b; ")": LET n = n + 1
 790 NEXT b: NEXT a
 800 BEEP 0.3, -10
 810 STOP

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
