  90 DIM b(9)
 120 CLS
 130 PRINT AT 0, 7; "*** THREE IN A ROW ***"
 150 FOR n = 1 TO 9
 160 LET row = INT ((n - 1) / 3)
 170 LET col = n - 1 - row * 3
 180 PRINT AT 3 + row * 2, 11 + col * 4;
 190 IF b(n) = 0 THEN PRINT CHR$ (48 + n);
 200 IF b(n) = 1 THEN INK 5: PRINT "X";: INK 7
 220 NEXT n
 230 PRINT AT 4, 10; "---+---+---"
 240 PRINT AT 6, 10; "---+---+---"
 250 INPUT "Your move (1-9): "; m
 260 IF m < 1 OR m > 9 THEN GO TO 250
 270 IF b(m) <> 0 THEN PRINT AT 10, 4; "Already taken!": PAUSE 30: GO TO 120
 280 LET b(m) = 1
 300 GO SUB 420
 310 IF winner = 1 THEN PRINT AT 10, 4; "You win!": STOP
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
