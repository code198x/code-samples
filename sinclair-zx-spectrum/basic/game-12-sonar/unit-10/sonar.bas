  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET a$ = "*** SONAR ***": LET y = 5: GO SUB 9000
  30 PRINT AT 8, 4; "Find 3 hidden targets on"
  40 CIRCLE 128, 100, 12: CIRCLE 128, 100, 20: PLOT 128, 100: DRAW 14, 14: PLOT 128, 100: DRAW 0, 20
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
 220 INK 5: FOR i = 0 TO 8: PLOT 68, 139 - i * 16: DRAW 128, 0: NEXT i
 230 FOR i = 0 TO 8: PLOT 68 + i * 16, 139: DRAW 0, -128: NEXT i: INK 7
 240 PRINT AT 3, 9; "1 2 3 4 5 6 7 8"
 250 FOR r = 1 TO 8
 260 LET pr = 3 + 2 * r: PRINT AT pr, 7; r
 270 FOR c = 1 TO 8: LET pc = 7 + 2 * c
 280 LET v = g(r,c)
 290 IF v = 9 OR v = 0 THEN INK 7: PRINT AT pr, pc; "."
 300 IF v = -1 THEN INK 4: PRINT AT pr, pc; "*"
 310 IF v >= 1 AND v <= 2 THEN INK 2: PRINT AT pr, pc; v
 320 IF v >= 3 AND v <= 4 THEN INK 6: PRINT AT pr, pc; v
 330 IF v >= 5 AND v < 9 THEN INK 5: PRINT AT pr, pc; v
 340 NEXT c
 350 INK 7
 360 NEXT r
 370 INPUT "Row (1-8): "; r
 380 INPUT "Col (1-8): "; c
 390 IF r < 1 OR r > 8 OR c < 1 OR c > 8 THEN GO TO 370
 400 IF g(r,c) > 0 AND g(r,c) < 9 THEN PRINT AT 2, 2; "Already probed!  ": PAUSE 50: GO TO 190
 410 IF g(r,c) = -1 THEN PRINT AT 2, 2; "Already found!   ": PAUSE 50: GO TO 190
 420 LET guesses = guesses + 1
 430 IF guesses > 30 THEN GO TO 680
 440 IF g(r,c) = 9 THEN GO TO 540
 450 LET dist = 99
 460 FOR a = 1 TO 8: FOR b = 1 TO 8
 470 IF g(a,b) <> 9 THEN GO TO 500
 480 LET d = ABS (r - a) + ABS (c - b)
 490 IF d < dist THEN LET dist = d
 500 NEXT b: NEXT a
 510 LET g(r,c) = dist
 520 BEEP 0.1, -5
 530 GO TO 190
 540 LET g(r,c) = -1
 550 LET hits = hits + 1
 560 BEEP 0.1, 10: BEEP 0.1, 15
 570 IF hits = 3 THEN GO TO 590
 580 GO TO 190
 590 CLS
 600 LET a$ = "*** SONAR ***": LET y = 6: GO SUB 9000
 610 PRINT AT 9, 6; INK 4; "All targets found!"
 620 PRINT AT 11, 6; INK 7; "Guesses: "; guesses
 630 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 640 IF guesses <= 10 THEN INK 4: PRINT AT 14, 8; "Expert tracker!": GO TO 770
 650 IF guesses <= 20 THEN INK 5: PRINT AT 14, 10; "Not bad": GO TO 770
 660 INK 6: PRINT AT 14, 8; "Keep searching"
 670 GO TO 770
 680 CLS
 690 LET a$ = "*** SONAR ***": LET y = 6: GO SUB 9000
 700 PRINT AT 9, 6; INK 2; "Out of probes!"
 710 PRINT AT 11, 6; INK 7; "Targets were at:"
 720 LET n = 12
 730 FOR a = 1 TO 8: FOR b = 1 TO 8
 740 IF g(a,b) = 9 THEN PRINT AT n, 8; "("; a; ","; b; ")": LET n = n + 1
 750 NEXT b: NEXT a
 760 BEEP 0.3, -10
 770 INK 7
 780 PRINT AT 18, 4; "Press any key to play again"
 790 PAUSE 0
 800 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
