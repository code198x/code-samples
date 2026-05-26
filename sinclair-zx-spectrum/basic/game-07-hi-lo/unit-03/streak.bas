  10 CLS
  20 RANDOMIZE
  30 LET a = INT (RND * 13) + 1
  40 LET streak = 0
  50 PRINT "The number is: "; a
  60 PRINT
  70 INPUT "Higher or lower (H/L)? "; g$
  80 LET b = INT (RND * 13) + 1
  90 PRINT "Next number: "; b
 100 PRINT
 110 LET ok = 0
 120 IF g$ = "H" AND b > a THEN LET ok = 1
 130 IF g$ = "L" AND b < a THEN LET ok = 1
 140 IF b = a THEN LET ok = 1
 150 IF ok = 0 THEN GO TO 200
 160 LET streak = streak + 1
 170 PRINT "Correct! Streak: "; streak
 180 LET a = b
 190 GO TO 50
 200 BEEP 0.3, -10
 210 PRINT "Wrong! Your streak: "; streak
