  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
 110 LET a = INT (RND * 13) + 1
 120 LET streak = 0
 130 CLS
 140 PRINT AT 1, 10; "*** HI-LO ***"
 150 PRINT AT 3, 8; "Number: "; a; "   "
 160 PRINT AT 5, 8; "Streak: "; streak; "   "
 180 PRINT AT 9, 4;
 190 INPUT "Higher or lower (H/L)? "; g$
 200 LET b = INT (RND * 13) + 1
 210 PRINT AT 11, 8; "Next: "; b; "   "
 220 LET ok = 0
 230 IF g$ = "H" AND b > a THEN LET ok = 1
 240 IF g$ = "L" AND b < a THEN LET ok = 1
 250 IF b = a THEN LET ok = 1
 260 IF ok = 0 THEN PRINT "Wrong!": STOP
 270 LET streak = streak + 1
 290 PRINT AT 13, 8; "Correct!"
 330 LET a = b
 340 GO TO 130
