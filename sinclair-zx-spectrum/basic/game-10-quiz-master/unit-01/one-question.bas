  10 CLS
  20 DATA "What is the largest ocean?","PACIFIC"
  30 READ q$,a$
  40 PRINT q$
  50 PRINT
  60 INPUT "Your answer: ";g$
  70 PRINT
  80 IF g$ = a$ THEN PRINT "Correct!"
  90 IF g$ <> a$ THEN PRINT "The answer is ";a$
