  10 CLS
  20 LET n = 42
  30 PRINT "I'm thinking of a number"
  40 PRINT "between 1 and 100."
  50 PRINT
  60 INPUT "Your guess: "; g
  70 IF g = n THEN PRINT "Got it!": STOP
  80 IF g < n THEN PRINT "Too low!"
  90 IF g > n THEN PRINT "Too high!"
 100 GO TO 60
