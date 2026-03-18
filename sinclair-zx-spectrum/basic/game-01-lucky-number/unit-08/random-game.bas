  10 RANDOMIZE
  20 LET n=INT (RND*100)+1
  30 LET c=0
  40 LET c=c+1
  50 INPUT "Your guess? "; g
  60 IF g=n THEN GO TO 110
  70 IF g<n THEN PRINT "Too low!"
  80 IF g>n THEN PRINT "Too high!"
  90 GO TO 40
 110 PRINT "Correct! The number was "; n
 120 PRINT "Found in "; c; " guesses"
