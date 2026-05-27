  50 RANDOMIZE
  55 DIM b(9)
  60 LET moves = 0
  75 CLS
  85 PRINT AT 0, 7; "*** THREE IN A ROW ***"
  90 FOR n = 1 TO 9
  91 LET row = INT ((n - 1) / 3)
  92 LET col = n - 1 - row * 3
  93 PRINT AT 3 + row * 2, 11 + col * 4;
  94 IF b(n) = 0 THEN PRINT CHR$ (48 + n);
  95 IF b(n) = 1 THEN INK 5: PRINT "X";: INK 7
  96 IF b(n) = 2 THEN INK 2: PRINT "O";: INK 7
  97 NEXT n
  98 PRINT AT 4, 10; "---+---+---"
  99 PRINT AT 6, 10; "---+---+---"
 120 INPUT "Your move (1-9): "; m
 125 IF m < 1 OR m > 9 THEN GO TO 120
 127 IF b(m) <> 0 THEN PRINT AT 10, 4; "Already taken!": PAUSE 30: GO TO 75
 130 LET b(m) = 1
 132 LET moves = moves + 1
 135 GO SUB 200
 140 IF winner = 1 THEN PRINT AT 10, 4; "You win!": STOP
 148 IF moves = 9 THEN PRINT AT 10, 4; "Draw!": STOP
 150 GO SUB 300
 155 LET b(mv) = 2
 160 LET moves = moves + 1
 165 BEEP 0.05, 5
 170 GO SUB 200
 175 IF winner = 2 THEN PRINT AT 10, 4; "Computer wins!": STOP
 180 GO TO 75
 200 REM --- Check winner ---
 205 RESTORE 900
 210 LET winner = 0
 215 FOR w = 1 TO 8
 220 READ p, q, f
 225 IF b(p) <> 0 AND b(p) = b(q) AND b(q) = b(f) THEN LET winner = b(p)
 230 NEXT w
 235 RETURN
 300 REM --- Computer: random ---
 305 LET mv = INT (RND * 9) + 1
 310 IF b(mv) <> 0 THEN GO TO 305
 360 RETURN
 900 DATA 1,2,3, 4,5,6, 7,8,9
 905 DATA 1,4,7, 2,5,8, 3,6,9
 910 DATA 1,5,9, 3,5,7
