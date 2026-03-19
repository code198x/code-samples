  10 CLS
  20 LET secret$="b"
  30 PRINT "Press a, b, c or d..."
  40 LET k$=INKEY$
  50 IF k$="" THEN GO TO 40
  60 IF k$=secret$ THEN PRINT "Correct!": STOP
  70 PRINT "Wrong — you pressed "; k$
  80 GO TO 40
