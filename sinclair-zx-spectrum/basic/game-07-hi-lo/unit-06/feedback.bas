  20 RANDOMIZE
 110 LET a = INT (RND * 13) + 1
 120 LET streak = 0
 130 CLS
 140 PRINT AT 1, 10; BRIGHT 1; "*** HI-LO ***"
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
 280 BORDER 4: BEEP 0.1, 10
 290 PRINT AT 13, 8; INK 4; "Correct!        "
 300 PAUSE 30
 310 BORDER 0
 320 PRINT AT 13, 8; "                "
 330 LET a = b
 340 GO TO 130

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
