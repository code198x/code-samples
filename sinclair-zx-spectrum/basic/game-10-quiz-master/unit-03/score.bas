  10 LET score = 0
  20 FOR n = 1 TO 4
  30 CLS
  40 READ q$,a$,b$,c$,d$,correct
  50 PRINT "Question ";n;" of 4"
  60 PRINT
  70 PRINT q$
  80 PRINT
  90 PRINT "1. ";a$
 100 PRINT "2. ";b$
 110 PRINT "3. ";c$
 120 PRINT "4. ";d$
 130 PRINT
 140 INPUT "Your answer (1-4): ";g
 150 PRINT
 160 IF g = correct THEN PRINT "Correct!": LET score = score + 1
 170 IF g <> correct THEN PRINT "The answer was ";correct
 180 PRINT : PRINT "Score: ";score;" / ";n
 190 PAUSE 100
 200 NEXT n
 210 CLS
 220 PRINT "Quiz complete!"
 230 PRINT
 240 PRINT "You scored ";score;" out of 4"
 500 DATA "How many legs does a spider have?","Six","Eight","Ten","Twelve",2
 510 DATA "Which planet is closest to the Sun?","Venus","Mercury","Earth","Mars",2
 520 DATA "In what year was the Moon landing?","1959","1965","1969","1972",3
 530 DATA "What is the capital of France?","London","Paris","Rome","Berlin",2
