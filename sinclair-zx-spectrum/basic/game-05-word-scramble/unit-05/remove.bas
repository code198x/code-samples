  10 LET w$="planet"
  20 PRINT "Start: ";w$
  30 LET p=3
  40 PRINT "Remove letter ";p;": ";w$(p TO p)
  50 LET w$=w$(1 TO p-1)+w$(p+1 TO LEN w$)
  60 PRINT "Result: ";w$
  70 PRINT
  80 LET p=1
  90 PRINT "Remove letter ";p;": ";w$(p TO p)
 100 LET w$=w$(1 TO p-1)+w$(p+1 TO LEN w$)
 110 PRINT "Result: ";w$
