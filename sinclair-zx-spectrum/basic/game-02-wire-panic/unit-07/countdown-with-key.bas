  10 CLS
  20 LET t=10
  30 PRINT AT 10,14; t; " "
  40 BEEP 0.05,t
  50 PAUSE 40
  60 LET k$=INKEY$
  70 IF k$<>"" THEN PRINT AT 12,8;"Pressed at "; t; " seconds!": STOP
  80 LET t=t-1
  90 IF t>=0 THEN GO TO 30
 100 PRINT AT 12,11;"Too slow!"
