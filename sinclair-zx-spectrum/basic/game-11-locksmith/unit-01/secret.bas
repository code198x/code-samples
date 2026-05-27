  50 RANDOMIZE
  55 DIM c(4)
  60 FOR i = 1 TO 4: LET c(i) = INT (RND * 6) + 1: NEXT i
  70 CLS
  75 PRINT "The code is: ";
  76 FOR i = 1 TO 4: PRINT c(i);: NEXT i
  80 STOP
