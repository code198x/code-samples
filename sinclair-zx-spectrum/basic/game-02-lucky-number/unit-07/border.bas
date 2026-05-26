  10 CLS
  20 RANDOMIZE
  30 LET n = INT (RND * 100) + 1
  40 PRINT "I'm thinking of a number"
  50 PRINT "between 1 and 100."
  60 PRINT
  70 INPUT "Your guess: "; g
  80 LET d = ABS (g - n)
  90 IF d > 50 THEN BORDER 1
 100 IF d > 25 AND d <= 50 THEN BORDER 5
 110 IF d > 10 AND d <= 25 THEN BORDER 6
 120 IF d > 5 AND d <= 10 THEN BORDER 2
 130 IF d <= 5 THEN BORDER 7
 140 IF g = n THEN PRINT "Got it! It was "; n: STOP
 150 IF g < n THEN PRINT "Too low!"
 160 IF g > n THEN PRINT "Too high!"
 170 GO TO 70
