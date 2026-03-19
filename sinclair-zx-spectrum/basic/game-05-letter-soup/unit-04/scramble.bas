  10 CLS
  20 LET w$="spectrum"
  30 LET v$=w$
  40 LET s$=""
  50 IF LEN v$=0 THEN GO TO 90
  60 LET p=INT (RND*LEN v$)+1
  70 LET s$=s$+v$(p TO p)
  80 LET v$=v$(1 TO p-1)+v$(p+1 TO LEN v$)
  85 GO TO 50
  90 PRINT "Original: "; w$
 100 PRINT "Scrambled: "; s$
