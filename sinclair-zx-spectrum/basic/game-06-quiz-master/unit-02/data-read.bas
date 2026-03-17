  10 LET sc=0
  20 FOR n=1 TO 4
  30 READ q$,a$,b$,c$,d$,r$
  40 PRINT "Q";n;": ";q$
  50 PRINT "  A: ";a$
  60 PRINT "  B: ";b$
  70 PRINT "  C: ";c$
  80 PRINT "  D: ";d$
  90 INPUT "Answer? ";k$
 100 IF k$=r$ THEN PRINT "Correct!": LET sc=sc+1: GO TO 120
 110 PRINT "Wrong! It was ";r$
 120 PRINT
 130 NEXT n
 140 PRINT "Score: ";sc;" out of 4"
 500 DATA "Closest planet to the Sun?","Mercury","Venus","Earth","Mars","a"
 510 DATA "Who built the pyramids?","Romans","Egyptians","Vikings","Greeks","b"
 520 DATA "Capital of France?","London","Berlin","Madrid","Paris","d"
 530 DATA "Instrument with 88 keys?","Guitar","Drums","Violin","Piano","d"
