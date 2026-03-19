  10 CLS
  20 LET t$="Hello from a subroutine!"
  30 GO SUB 100
  40 LET t$="Called again with new text!"
  50 GO SUB 100
  60 LET t$="Third time — same code, different data"
  70 GO SUB 100
  80 STOP
 100 REM === Print with border ===
 110 PRINT "=========================="
 120 PRINT t$
 130 PRINT "=========================="
 140 PRINT
 150 RETURN
