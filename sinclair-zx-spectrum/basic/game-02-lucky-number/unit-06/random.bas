  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 LET n = INT (RND * 100) + 1
  50 INVERSE 1: PRINT AT 2, 0; "   *** LUCKY NUMBER ***          ": INVERSE 0
  60 PRINT
  70 PRINT "I'm thinking of a number"
  80 PRINT "between 1 and 100."
  90 PRINT
 120 INPUT "Your guess: "; g
 200 IF g = n THEN PRINT "Got it! It was "; n: STOP
 210 IF g < n THEN PRINT "Too low!"
 220 IF g > n THEN PRINT "Too high!"
 230 GO TO 120

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
