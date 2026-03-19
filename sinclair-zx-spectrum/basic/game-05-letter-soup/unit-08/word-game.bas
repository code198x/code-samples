  10 REM Word Game — text version
  20 RANDOMIZE
  30 CLS
  40 LET sc=0
  50 FOR n=1 TO 5
  60 READ w$
  70 LET v$=w$: LET s$=""
  80 IF LEN v$=0 THEN GO TO 120
  90 LET p=INT (RND*LEN v$)+1
 100 LET s$=s$+v$(p TO p)
 110 LET v$=v$(1 TO p-1)+v$(p+1 TO LEN v$)
 115 GO TO 80
 120 IF s$=w$ THEN GO TO 70
 130 PRINT "Round ";n;": ";s$
 140 INPUT "Your guess? ";g$
 150 IF g$=w$ THEN LET sc=sc+1: PRINT "Correct!": GO TO 170
 160 PRINT "Wrong — it was "; w$
 170 NEXT n
 180 PRINT : PRINT "Score: ";sc;" out of 5"
 190 DATA "cat","bird","lemon","castle","trumpet"
