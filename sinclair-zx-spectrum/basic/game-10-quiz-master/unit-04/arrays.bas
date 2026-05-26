   5 DIM k(4)
  50 RESTORE: FOR i = 1 TO 4: READ k(i): NEXT i
  55 RESTORE 610
  80 LET score = 0: LET n = 0
 110 FOR q = 1 TO 4
 120 LET n = n + 1
 130 CLS
 190 READ q$,a$,b$,c$,d$
 200 PRINT "Question ";n;" of 4"
 210 PRINT q$
 220 PRINT "1. ";a$
 230 PRINT "2. ";b$
 240 PRINT "3. ";c$
 250 PRINT "4. ";d$
 260 INPUT "Answer (1-4): ";g
 270 IF g = k(n) THEN PRINT "Correct!": LET score = score + 1
 280 IF g <> k(n) THEN PRINT "The answer was ";k(n)
 300 PAUSE 80
 310 NEXT q
 360 PRINT "You scored ";score;" out of 4"
 550 DATA 2,2,3,2
 610 DATA "How many legs does a spider have?","Six","Eight","Ten","Twelve"
 620 DATA "What is the fastest land animal?","Lion","Cheetah","Horse","Wolf"
 640 DATA "Which planet is closest to the Sun?","Venus","Mercury","Earth","Mars"
 650 DATA "How many planets orbit the Sun?","Seven","Eight","Nine","Ten"
