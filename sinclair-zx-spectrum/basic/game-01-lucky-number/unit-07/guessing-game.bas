  10 LET n=42
  20 LET c=0
  30 LET c=c+1
  40 INPUT "Your guess? "; g
  50 IF g=n THEN GO TO 100
  60 IF g<n THEN PRINT "Too low!"
  70 IF g>n THEN PRINT "Too high!"
  80 GO TO 30
 100 PRINT "Correct!"
 110 PRINT "Found in "; c; " guesses"
