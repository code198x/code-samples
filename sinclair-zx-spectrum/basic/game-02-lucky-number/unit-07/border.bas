  10 CLS
  20 RANDOMIZE
  30 LET n = INT (RND * 100) + 1
  50 PRINT "*** LUCKY NUMBER ***"
  60 PRINT
  70 PRINT "I'm thinking of a number"
  80 PRINT "between 1 and 100."
  90 PRINT
 120 INPUT "Your guess: "; g
 140 LET d = ABS (g - n)
 150 IF d > 50 THEN BORDER 1
 160 IF d > 25 AND d <= 50 THEN BORDER 5
 170 IF d > 10 AND d <= 25 THEN BORDER 6
 180 IF d > 5 AND d <= 10 THEN BORDER 2
 190 IF d <= 5 THEN BORDER 7
 200 IF g = n THEN PRINT "Got it! It was "; n: STOP
 210 IF g < n THEN PRINT "Too low!"
 220 IF g > n THEN PRINT "Too high!"
 230 GO TO 120
