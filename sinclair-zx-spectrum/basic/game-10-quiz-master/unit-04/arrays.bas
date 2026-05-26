  10 DIM k(4)
  20 FOR i = 1 TO 4
  30 READ k(i)
  40 NEXT i
  50 LET score = 0
  60 FOR n = 1 TO 4
  70 CLS
  80 READ q$,a$,b$,c$,d$
  90 PRINT "Question ";n;" of 4"
 100 PRINT
 110 PRINT q$
 120 PRINT
 130 PRINT "1. ";a$
 140 PRINT "2. ";b$
 150 PRINT "3. ";c$
 160 PRINT "4. ";d$
 170 PRINT
 180 INPUT "Your answer (1-4): ";g
 190 PRINT
 200 IF g = k(n) THEN PRINT "Correct!": LET score = score + 1
 210 IF g <> k(n) THEN PRINT "The answer was ";k(n)
 220 PRINT : PRINT "Score: ";score;" / ";n
 230 PAUSE 100
 240 NEXT n
 250 CLS
 260 PRINT "Quiz complete!"
 270 PRINT
 280 PRINT "You scored ";score;" out of 4"
 500 DATA 2,2,3,2
 510 DATA "How many legs does a spider have?","Six","Eight","Ten","Twelve"
 520 DATA "Which planet is closest to the Sun?","Venus","Mercury","Earth","Mars"
 530 DATA "In what year was the Moon landing?","1959","1965","1969","1972"
 540 DATA "What is the capital of France?","London","Paris","Rome","Berlin"
