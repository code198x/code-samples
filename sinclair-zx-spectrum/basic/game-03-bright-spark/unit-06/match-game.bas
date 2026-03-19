  10 CLS
  20 LET s$="1324"
  30 PRINT "Repeat: "; s$
  40 PRINT
  50 FOR i=1 TO LEN s$
  60 LET k$=INKEY$
  70 IF k$="" THEN GO TO 60
  80 IF k$<>s$(i) THEN PRINT "Wrong at step "; i: STOP
  90 PRINT "Step "; i; ": correct"
 100 PAUSE 10
 110 IF INKEY$<>"" THEN GO TO 110
 120 NEXT i
 130 PRINT : PRINT "All correct!"
