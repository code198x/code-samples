  10 CLS
  20 RANDOMIZE
  30 LET n = INT (RND * 100) + 1
  40 PRINT "I'm thinking of a number"
  50 PRINT "between 1 and 100."
  60 PRINT
  70 INPUT "Your guess: "; g
  80 IF g = n THEN PRINT "Got it! It was "; n: STOP
  90 IF g < n THEN PRINT "Too low!"
 100 IF g > n THEN PRINT "Too high!"
 110 GO TO 70
