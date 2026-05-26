  10 CLS
  20 RANDOMIZE
  30 LET a = INT (RND * 13) + 1
  40 LET b = INT (RND * 13) + 1
  50 PRINT "The number is: "; a
  60 PRINT
  70 INPUT "Higher or lower (H/L)? "; g$
  80 PRINT
  90 PRINT "Next number: "; b
 100 PRINT
 110 IF g$ = "H" AND b > a THEN PRINT "Correct!": BEEP 0.1, 10
 120 IF g$ = "L" AND b < a THEN PRINT "Correct!": BEEP 0.1, 10
 130 IF g$ = "H" AND b <= a THEN PRINT "Wrong!": BEEP 0.3, -10
 140 IF g$ = "L" AND b >= a THEN PRINT "Wrong!": BEEP 0.3, -10
 150 IF b = a THEN PRINT "They were the same!": BEEP 0.1, 0
