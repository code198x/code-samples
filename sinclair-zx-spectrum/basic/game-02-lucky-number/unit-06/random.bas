  10 CLS
  20 RANDOMIZE
  30 LET n = INT (RND * 100) + 1
  50 PRINT "*** LUCKY NUMBER ***"
  60 PRINT
  70 PRINT "I'm thinking of a number"
  80 PRINT "between 1 and 100."
  90 PRINT
 120 INPUT "Your guess: "; g
 200 IF g = n THEN PRINT "Got it! It was "; n: STOP
 210 IF g < n THEN PRINT "Too low!"
 220 IF g > n THEN PRINT "Too high!"
 230 GO TO 120
