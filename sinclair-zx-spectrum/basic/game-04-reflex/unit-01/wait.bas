  10 CLS
  20 RANDOMIZE
  30 PRINT "Get ready..."
  40 PAUSE INT (RND * 100) + 50
  50 PRINT "NOW!"
  60 IF INKEY$ = "" THEN GO TO 60
  70 PRINT "You pressed!"
