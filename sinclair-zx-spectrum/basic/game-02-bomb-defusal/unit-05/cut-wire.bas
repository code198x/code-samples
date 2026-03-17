  10 LET w=INT (RND*4)+1
  20 PRINT "Cut a wire (1-4):"
  30 LET k$=INKEY$
  40 IF k$<"1" OR k$>"4" THEN GO TO 30
  50 LET g=VAL k$
  60 IF g=w THEN PRINT "DEFUSED!": STOP
  70 PRINT "BOOM! It was wire ";w
