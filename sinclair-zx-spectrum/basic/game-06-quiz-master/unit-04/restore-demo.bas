  10 CLS
  20 FOR i=1 TO 3
  30 READ w$
  40 PRINT w$
  50 NEXT i
  60 PRINT
  70 RESTORE
  80 PRINT "After RESTORE:"
  90 FOR i=1 TO 3
 100 READ w$
 110 PRINT w$
 120 NEXT i
 130 DATA "cat","dog","fish"
