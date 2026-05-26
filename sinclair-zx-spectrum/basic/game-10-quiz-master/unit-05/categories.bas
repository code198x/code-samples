   5 DIM k(8)
  50 RESTORE: FOR i = 1 TO 8: READ k(i): NEXT i
  60 RESTORE 600
  80 LET score = 0: LET n = 0
  90 FOR c = 1 TO 4
 100 READ t$,ink
 110 FOR q = 1 TO 2
 120 LET n = n + 1
 130 CLS
 140 PRINT t$
 190 READ q$,a$,b$,c$,d$
 200 PRINT "Question ";n;" of 8"
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
 340 NEXT c
 360 PRINT "You scored ";score;" out of 8"
 550 DATA 2,2,2,2,3,2,3,2
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
