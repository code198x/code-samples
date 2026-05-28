  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
 110 LET a = INT (RND * 13) + 1
 120 LET streak = 0
 130 CLS
 150 PRINT "Number: "; a
 160 PRINT "Streak: "; streak
 190 INPUT "Higher or lower (H/L)? "; g$
 200 LET b = INT (RND * 13) + 1
 210 PRINT "Next:   "; b
 220 LET ok = 0
 230 IF g$ = "H" AND b > a THEN LET ok = 1
 240 IF g$ = "L" AND b < a THEN LET ok = 1
 250 IF b = a THEN LET ok = 1
 260 IF ok = 0 THEN PRINT "Wrong!": STOP
 270 LET streak = streak + 1
 290 PRINT "Correct!"
 330 LET a = b
 340 GO TO 130

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
