  10 LET a$="spec"
  20 LET b$="trum"
  30 LET r$=a$+b$
  40 PRINT a$;" + ";b$;" = ";r$
  50 PRINT
  60 LET w$="hello"
  70 LET r$=""
  80 FOR i=1 TO LEN w$
  90 LET r$=r$+w$(i TO i)
 100 PRINT "Building: ";r$
 110 NEXT i
