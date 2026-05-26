  10 CLS
  20 DATA "SPECTRUM"
  30 READ w$
  40 PRINT "The word has "; LEN w$; " letters."
  50 PRINT
  60 FOR i = 1 TO LEN w$
  70 PRINT "_ ";
  80 NEXT i
