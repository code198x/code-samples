  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 7; BRIGHT 1; "*** THREE IN A ROW ***"
  30 PRINT AT 8, 5; "You are X. Computer is O."
  40 PRINT AT 10, 5; "Get three in a row to win."
  50 PRINT AT 12, 5; "Pick a position: 1 to 9."
  60 PRINT AT 18, 4; "Press any key to start"
  70 INK 6: PLOT 116, 34: DRAW 0, 36: PLOT 140, 34: DRAW 0, 36: PLOT 104, 46: DRAW 48, 0: PLOT 104, 58: DRAW 48, 0: INK 7
  80 PAUSE 0
  90 RANDOMIZE
 100 DIM b(9)
 110 LET moves = 0
 120 LET wins = 0: LET losses = 0: LET draws = 0
 130 CLS
 140 INVERSE 1: PRINT AT 0, 0; "    *** THREE IN A ROW ***      ": INVERSE 0
 150 PRINT AT 1, 2; "W: "; wins; " L: "; losses; " D: "; draws; "  "
 160 INK 7: FOR i = 0 TO 3: PLOT 80 + i * 32, 79: DRAW 0, 72: NEXT i
 170 FOR i = 0 TO 3: PLOT 80, 79 + i * 24: DRAW 96, 0: NEXT i
 180 FOR n = 1 TO 9
 190 LET row = INT ((n - 1) / 3)
 200 LET col = n - 1 - row * 3
 210 LET cx = 96 + col * 32: LET cy = 139 - row * 24
 220 IF b(n) = 0 THEN PRINT AT 4 + row * 3, 12 + col * 4; CHR$ (48 + n)
 230 IF b(n) = 1 THEN INK 5: PLOT cx - 7, cy - 7: DRAW 14, 14: PLOT cx - 7, cy + 7: DRAW 14, -14: INK 7
 240 IF b(n) = 2 THEN INK 2: CIRCLE cx, cy, 7: INK 7
 250 NEXT n
 260 INPUT "Your move (1-9): "; m
 270 IF m < 1 OR m > 9 THEN GO TO 260
 280 IF b(m) <> 0 THEN PRINT AT 16, 4; "Already taken!": PAUSE 30: GO TO 130
 290 LET b(m) = 1
 300 LET moves = moves + 1
 310 GO SUB 420
 320 IF winner = 1 THEN GO TO 900
 330 IF moves = 9 THEN GO TO 1000
 340 GO SUB 600
 350 LET b(mv) = 2
 360 LET moves = moves + 1
 370 BEEP 0.05, 5
 380 GO SUB 420
 390 IF winner = 2 THEN GO TO 950
 400 IF moves = 9 THEN GO TO 1000
 410 GO TO 130
 420 REM --- Check winner ---
 430 RESTORE 1200
 440 LET winner = 0
 450 FOR w = 1 TO 8
 460 READ p, q, f
 470 IF b(p) <> 0 AND b(p) = b(q) AND b(q) = b(f) THEN LET winner = b(p)
 480 NEXT w
 490 RETURN
 600 REM --- Computer: win, block, strategy ---
 610 LET mv = 0
 620 RESTORE 1200
 630 FOR w = 1 TO 8
 640 READ p, q, f
 650 IF mv = 0 AND b(p) = 2 AND b(q) = 2 AND b(f) = 0 THEN LET mv = f
 660 IF mv = 0 AND b(p) = 2 AND b(f) = 2 AND b(q) = 0 THEN LET mv = q
 670 IF mv = 0 AND b(q) = 2 AND b(f) = 2 AND b(p) = 0 THEN LET mv = p
 680 IF mv = 0 AND b(p) = 1 AND b(q) = 1 AND b(f) = 0 THEN LET mv = f
 690 IF mv = 0 AND b(p) = 1 AND b(f) = 1 AND b(q) = 0 THEN LET mv = q
 700 IF mv = 0 AND b(q) = 1 AND b(f) = 1 AND b(p) = 0 THEN LET mv = p
 710 NEXT w
 720 IF mv > 0 THEN GO TO 800
 730 IF b(5) = 0 THEN LET mv = 5: GO TO 800
 740 IF b(1) = 0 THEN LET mv = 1: GO TO 800
 750 IF b(3) = 0 THEN LET mv = 3: GO TO 800
 760 IF b(7) = 0 THEN LET mv = 7: GO TO 800
 770 IF b(9) = 0 THEN LET mv = 9: GO TO 800
 780 FOR i = 1 TO 9: IF b(i) = 0 THEN LET mv = i
 790 NEXT i
 800 RETURN
 900 CLS: PRINT AT 6, 7; BRIGHT 1; "*** THREE IN A ROW ***"
 910 PRINT AT 9, 10; INK 4; "You win!"
 920 LET wins = wins + 1
 930 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 940 GO TO 1040
 950 CLS: PRINT AT 6, 7; BRIGHT 1; "*** THREE IN A ROW ***"
 960 PRINT AT 9, 8; INK 2; "Computer wins!"
 970 LET losses = losses + 1
 980 BEEP 0.3, -10
 990 GO TO 1040
1000 CLS: PRINT AT 6, 7; BRIGHT 1; "*** THREE IN A ROW ***"
1010 PRINT AT 9, 11; INK 6; "Draw!"
1020 LET draws = draws + 1
1030 BEEP 0.1, 5: BEEP 0.1, 5
1040 PRINT AT 12, 2; INK 7; "W: "; wins; " L: "; losses; " D: "; draws
1050 PRINT AT 18, 4; "Press any key to play again"
1060 PAUSE 0
1070 DIM b(9)
1080 LET moves = 0
1090 GO TO 130
1200 DATA 1,2,3, 4,5,6, 7,8,9
1210 DATA 1,4,7, 2,5,8, 3,6,9
1220 DATA 1,5,9, 3,5,7

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
