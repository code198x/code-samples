  10 PRINT "Press A, B, C or D"
  20 LET k$=INKEY$
  30 IF k$<>"a" AND k$<>"b" AND k$<>"c" AND k$<>"d" THEN GO TO 20
  40 PRINT "You pressed: ";k$
