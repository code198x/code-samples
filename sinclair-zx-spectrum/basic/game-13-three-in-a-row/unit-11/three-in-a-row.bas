  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET a$ = "*** THREE IN A ROW ***": LET y = 5: GO SUB 9000
  30 PRINT AT 8, 5; "You are X. Computer is O."
  40 PRINT AT 10, 5; "Get three in a row to win."
  50 PRINT AT 12, 5; "Pick a position: 1 to 9."
  60 PRINT AT 18, 4; "Press any key to start": INK 6: PLOT 116, 34: DRAW 0, 36: PLOT 140, 34: DRAW 0, 36: PLOT 104, 46: DRAW 48, 0: PLOT 104, 58: DRAW 48, 0: INK 7
  70 PAUSE 0
  80 RANDOMIZE
  90 DIM b(9)
 100 LET moves = 0
 110 LET wins = 0: LET losses = 0: LET draws = 0
 120 CLS
 130 INVERSE 1: PRINT AT 0, 0; "    *** THREE IN A ROW ***      ": INVERSE 0: PRINT AT 1, 2; "W: "; wins; " L: "; losses; " D: "; draws; "  "
 150 INK 7: FOR i = 0 TO 3: PLOT 80 + i * 32, 55: DRAW 0, 96: NEXT i
 160 FOR i = 0 TO 3: PLOT 80, 55 + i * 32: DRAW 96, 0: NEXT i
 170 FOR n = 1 TO 9
 180 LET row = INT ((n - 1) / 3)
 190 LET col = n - 1 - row * 3
 200 LET cx = 100 + col * 32: LET cy = 131 - row * 32
 210 IF b(n) = 0 THEN PRINT AT 5 + row * 4, 12 + col * 4; CHR$ (48 + n)
 220 IF b(n) = 1 THEN INK 5: PLOT cx - 8, cy - 8: DRAW 16, 16: PLOT cx - 8, cy + 8: DRAW 16, -16: INK 7
 230 IF b(n) = 2 THEN INK 2: CIRCLE cx, cy, 8: INK 7
 240 NEXT n
 250 INPUT "Your move (1-9): "; m
 260 IF m < 1 OR m > 9 THEN GO TO 250
 270 IF b(m) <> 0 THEN PRINT AT 18, 4; "Already taken!": PAUSE 30: GO TO 120
 280 LET b(m) = 1
 290 LET moves = moves + 1
 300 GO SUB 420
 310 IF winner = 1 THEN GO TO 900
 320 IF moves = 9 THEN GO TO 1000
 340 GO SUB 600
 350 LET b(mv) = 2
 360 LET moves = moves + 1
 370 BEEP 0.05, 5
 380 GO SUB 420
 390 IF winner = 2 THEN GO TO 950
 400 IF moves = 9 THEN GO TO 1000
 410 GO TO 120
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
 900 CLS: LET a$ = "*** THREE IN A ROW ***": LET y = 6: GO SUB 9000
 910 PRINT AT 9, 10; INK 4; "You win!"
 920 LET wins = wins + 1
 930 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 940 GO TO 1040
 950 CLS: LET a$ = "*** THREE IN A ROW ***": LET y = 6: GO SUB 9000
 960 PRINT AT 9, 8; INK 2; "Computer wins!"
 970 BEEP 0.3, -10
 980 LET losses = losses + 1
 990 GO TO 1040
1000 CLS: LET a$ = "*** THREE IN A ROW ***": LET y = 6: GO SUB 9000
1010 PRINT AT 9, 11; INK 6; "Draw!"
1020 BEEP 0.1, 5: BEEP 0.1, 5
1030 LET draws = draws + 1
1040 PRINT AT 12, 2; INK 7; "W: "; wins; " L: "; losses; " D: "; draws
1050 PRINT AT 18, 4; "Press any key to play again"
1060 PAUSE 0
1070 DIM b(9)
1080 LET moves = 0
1090 GO TO 120
1200 DATA 1,2,3, 4,5,6, 7,8,9
1210 DATA 1,4,7, 2,5,8, 3,6,9
1220 DATA 1,5,9, 3,5,7
9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
