  10 CLS
  20 RANDOMIZE
  30 PRINT "Get ready..."
  40 PRINT
  50 FOR x = 0 TO 200
  60 PLOT x, 88
  70 NEXT x
  80 PRINT "NOW!"
  90 LET t = 0
 100 IF INKEY$ <> "" THEN GO TO 130
 110 LET t = t + 1
 120 GO TO 100
 130 PRINT "Your time: "; t
 140 PRINT
 150 IF t < 5 THEN INK 4: PRINT "Lightning!"
 160 IF t >= 5 AND t < 15 THEN INK 5: PRINT "Quick!"
 170 IF t >= 15 AND t < 30 THEN INK 6: PRINT "OK"
 180 IF t >= 30 THEN INK 2: PRINT "Slow..."
