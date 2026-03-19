  10 CLS
  20 LET t=10
  30 PRINT AT 10,14; t; " "
  40 BEEP 0.05,t
  50 PAUSE 50
  60 LET t=t-1
  70 IF t>=0 THEN GO TO 30
  80 PRINT AT 12,11;"Time is up!"
