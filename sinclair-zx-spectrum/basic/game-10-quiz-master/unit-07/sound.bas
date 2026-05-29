   5 DIM k(8)
  10 BORDER 0: PAPER 0: INK 7: CLS
  50 RESTORE: FOR i = 1 TO 8: READ k(i): NEXT i
  60 RESTORE 600
  80 LET score = 0: LET n = 0
  90 FOR c = 1 TO 4
 100 READ t$,ink
 110 FOR q = 1 TO 2
 120 LET n = n + 1
 130 CLS
 140 PAPER ink: INK 7
 150 FOR i = 0 TO 31: PRINT " ";: NEXT i
 160 PRINT AT 0,1;t$
 170 PRINT AT 0,26;score;"/8"
 180 PAPER 7: INK 0
 190 READ q$,a$,b$,c$,d$
 200 PRINT AT 2,0;"Question ";n;" of 8"
 210 PRINT AT 4,0;q$
 220 PRINT AT 7,2;"1. ";a$
 230 PRINT AT 8,2;"2. ";b$
 240 PRINT AT 9,2;"3. ";c$
 250 PRINT AT 10,2;"4. ";d$
 260 PRINT AT 12,0;: INPUT "Answer (1-4): ";g
 270 IF g = k(n) THEN PRINT AT 14,0;"Correct!": LET score = score + 1: BEEP 0.2,12
 280 IF g <> k(n) THEN PRINT AT 14,0;"The answer was ";k(n): BEEP 0.3,-5
 290 PRINT AT 0,26;score;"/8"
 300 PAUSE 80
 310 NEXT q
 340 NEXT c
 350 CLS
 360 PRINT AT 3,9;"Quiz complete!"
 370 PRINT AT 5,6;"You scored ";score;" out of 8"
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
