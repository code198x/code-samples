  10 CLS
  20 DATA "What is the largest ocean?"
  30 DATA "Atlantic","Indian","Pacific","Arctic"
  40 DATA 3
  50 READ q$
  60 READ a$,b$,c$,d$
  70 READ correct
  80 PRINT q$
  90 PRINT
 100 PRINT "1. ";a$
 110 PRINT "2. ";b$
 120 PRINT "3. ";c$
 130 PRINT "4. ";d$
 140 PRINT
 150 INPUT "Your answer (1-4): ";g
 160 PRINT
 170 IF g = correct THEN PRINT "Correct!"
 180 IF g <> correct THEN PRINT "The answer was ";correct
