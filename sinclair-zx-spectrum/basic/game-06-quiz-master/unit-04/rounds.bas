10 CLS
20 LET n = 0
30 FOR i = 1 TO 5
40 READ q$, a$, b$, c$, r
50 PRINT "Question "; i; " of 5"
60 PRINT
70 PRINT q$
80 PRINT
90 PRINT "  1. "; a$
100 PRINT "  2. "; b$
110 PRINT "  3. "; c$
120 PRINT
130 INPUT "Your answer (1-3)? "; g
140 IF g < 1 OR g > 3 THEN PRINT "Pick 1, 2 or 3!": GO TO 130
150 IF g = r THEN INK 4: PRINT "Correct!": INK 0: LET n = n + 1
160 IF g <> r THEN INK 2: PRINT "Wrong!": INK 0
170 PRINT
180 PAUSE 50
190 CLS
200 NEXT i
210 PRINT "You scored "; n; " out of 5"
300 DATA "What colour is the sky?","Green","Blue","Red",2
310 DATA "How many legs has a spider?","6","8","10",2
320 DATA "What is the capital of France?","Berlin","Madrid","Paris",3
330 DATA "Which planet is nearest the Sun?","Mercury","Venus","Mars",1
340 DATA "How many days in a week?","5","6","7",3
