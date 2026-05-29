  10 BORDER 0: PAPER 0: INK 7: CLS
  90 DIM b(9)
 120 CLS
 130 INVERSE 1: PRINT AT 0, 0; "    *** THREE IN A ROW ***      ": INVERSE 0
 150 INK 7: FOR i = 0 TO 3: PLOT 80 + i * 32, 55: DRAW 0, 96: NEXT i
 160 FOR i = 0 TO 3: PLOT 80, 55 + i * 32: DRAW 96, 0: NEXT i
 170 FOR n = 1 TO 9
 180 LET row = INT ((n - 1) / 3)
 190 LET col = n - 1 - row * 3
 200 LET cx = 100 + col * 32: LET cy = 131 - row * 32
 210 IF b(n) = 0 THEN PRINT AT 5 + row * 4, 12 + col * 4; CHR$ (48 + n)
 220 IF b(n) = 1 THEN INK 5: PLOT cx - 8, cy - 8: DRAW 16, 16: PLOT cx - 8, cy + 8: DRAW 16, -16: INK 7
 240 NEXT n
 250 INPUT "Your move (1-9): "; m
 260 IF m < 1 OR m > 9 THEN GO TO 250
 270 IF b(m) <> 0 THEN PRINT AT 18, 4; "Already taken!": PAUSE 30: GO TO 120
 280 LET b(m) = 1
 300 GO SUB 420
 310 IF winner = 1 THEN PRINT AT 18, 4; "You win!": STOP
 320 GO TO 120
 420 REM --- Check winner ---
 430 RESTORE 1200
 440 LET winner = 0
 450 FOR w = 1 TO 8
 460 READ p, q, f
 470 IF b(p) <> 0 AND b(p) = b(q) AND b(q) = b(f) THEN LET winner = b(p)
 480 NEXT w
 490 RETURN
1200 DATA 1,2,3, 4,5,6, 7,8,9
1210 DATA 1,4,7, 2,5,8, 3,6,9
1220 DATA 1,5,9, 3,5,7
