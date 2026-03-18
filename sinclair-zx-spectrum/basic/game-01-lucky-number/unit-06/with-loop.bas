  10 LET n=42
  20 INPUT "Your guess? "; g
  30 IF g=n THEN GO TO 70
  40 IF g<n THEN PRINT "Too low!"
  50 IF g>n THEN PRINT "Too high!"
  60 GO TO 20
  70 PRINT "Correct!"
