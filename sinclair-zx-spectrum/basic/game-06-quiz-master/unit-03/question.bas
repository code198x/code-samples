10 CLS
20 READ q$, a$, b$, c$, r
30 PRINT q$
40 PRINT
50 PRINT "  1. "; a$
60 PRINT "  2. "; b$
70 PRINT "  3. "; c$
80 PRINT
90 INPUT "Your answer (1-3)? "; g
100 IF g = r THEN PRINT "Correct!"
110 IF g <> r THEN PRINT "Wrong!"
200 DATA "What colour is the sky?","Green","Blue","Red",2
