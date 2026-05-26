  10 CLS
  20 RANDOMIZE
  30 PRINT "Get ready..."
  40 PAUSE INT (RND * 100) + 50
  50 PRINT "NOW!"
  60 LET t = 0
  70 IF INKEY$ <> "" THEN GO TO 100
  80 LET t = t + 1
  90 GO TO 70
 100 PRINT "Your time: "; t
