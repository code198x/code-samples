  10 DIM k(8)
  20 FOR i = 1 TO 8
  30 READ k(i)
  40 NEXT i
  50 RESTORE 600
  60 LET score = 0
  70 LET n = 0
  80 FOR c = 1 TO 4
  90 READ t$,ink
 100 FOR q = 1 TO 2
 110 LET n = n + 1
 120 CLS
 130 PAPER ink: INK 7
 140 PRINT " ";t$
 150 PAPER 7: INK 0
 160 PRINT
 170 READ q$,a$,b$,c$,d$
 180 PRINT q$
 190 PRINT
 200 PRINT "1. ";a$
 210 PRINT "2. ";b$
 220 PRINT "3. ";c$
 230 PRINT "4. ";d$
 240 PRINT
 250 INPUT "Your answer (1-4): ";g
 260 PRINT
 270 IF g = k(n) THEN PRINT "Correct!": LET score = score + 1
 280 IF g <> k(n) THEN PRINT "The answer was ";k(n)
 290 PRINT : PRINT "Score: ";score;" / ";n
 300 PAUSE 100
 310 NEXT q
 320 NEXT c
 330 CLS
 340 PRINT "Quiz complete!"
 350 PRINT
 360 PRINT "You scored ";score;" out of 8"
 500 DATA 2,2,2,2,3,2,3,2
 600 DATA "Animals",4
 610 DATA "How many legs does a spider have?","Six","Eight","Ten","Twelve"
 620 DATA "What is the fastest land animal?","Lion","Cheetah","Horse","Wolf"
 630 DATA "Space",5
 640 DATA "Which planet is closest to the Sun?","Venus","Mercury","Earth","Mars"
 650 DATA "How many planets orbit the Sun?","Seven","Eight","Nine","Ten"
 660 DATA "History",2
 670 DATA "In what year was the Moon landing?","1959","1965","1969","1972"
 680 DATA "Which country built the pyramids?","Greece","Egypt","Rome","China"
 690 DATA "Geography",6
 700 DATA "What is the largest ocean?","Atlantic","Indian","Pacific","Arctic"
 710 DATA "What is the capital of France?","London","Paris","Rome","Berlin"
