  10 CLS
  20 RANDOMIZE
  30 PRINT "Rolling 5 dice:"
  40 PRINT
  50 FOR i = 1 TO 5
  60 LET d = INT (RND * 6) + 1
  70 PRINT d; " ";
  80 BEEP 0.05, 20
  90 NEXT i
 100 PRINT
 110 PRINT
 120 PRINT "Done!"
