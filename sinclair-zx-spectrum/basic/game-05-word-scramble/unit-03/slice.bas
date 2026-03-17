  10 LET w$="planet"
  20 PRINT "Word: ";w$
  30 PRINT "First letter: ";w$(1 TO 1)
  40 PRINT "Third letter: ";w$(3 TO 3)
  50 PRINT "Letters 2 to 4: ";w$(2 TO 4)
  60 FOR i=1 TO LEN w$
  70 PRINT w$(i TO i);" ";
  80 NEXT i
