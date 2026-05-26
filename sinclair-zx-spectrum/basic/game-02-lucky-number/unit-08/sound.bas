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
 140 IF g = n THEN GO TO 200
 150 IF g < n THEN PRINT "Too low!": BEEP 0.1, -5
 160 IF g > n THEN PRINT "Too high!": BEEP 0.1, 5
 170 GO TO 70
 200 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20: BEEP 0.2, 24
 210 PRINT "Got it! It was "; n
