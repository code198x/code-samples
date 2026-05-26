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
 140 FOR i = 0 TO 31: PRINT " ";: NEXT i
 150 PRINT AT 0,1;t$
 160 PRINT AT 0,26;score;"/8"
 170 PAPER 7: INK 0
 180 READ q$,a$,b$,c$,d$
 190 PRINT AT 2,0;"Question ";n;" of 8"
 200 PRINT AT 4,0;q$
 210 PRINT AT 7,2;"1. ";a$
 220 PRINT AT 8,2;"2. ";b$
 230 PRINT AT 9,2;"3. ";c$
 240 PRINT AT 10,2;"4. ";d$
 250 PRINT AT 12,0;: INPUT "Answer (1-4): ";g
 260 IF g = k(n) THEN PRINT AT 14,0;"Correct!": LET score = score + 1: BEEP 0.2,12
 270 IF g <> k(n) THEN PRINT AT 14,0;"The answer was ";k(n): BEEP 0.3,-5
 280 PRINT AT 0,26;score;"/8"
 290 PAUSE 80
 300 NEXT q
 310 NEXT c
 320 CLS
 330 PRINT AT 6,9;"Quiz complete!"
 340 PRINT AT 8,6;"You scored ";score;" out of 8"
 350 IF score = 8 THEN INK 4: PRINT AT 11,10;"Quiz Master!": GO TO 390
 360 IF score >= 6 THEN INK 5: PRINT AT 11,12;"Expert": GO TO 390
 370 IF score >= 4 THEN INK 6: PRINT AT 11,11;"Not bad": GO TO 390
 380 INK 2: PRINT AT 11,9;"Keep trying"
 390 INK 0
 400 BEEP 0.1,0: BEEP 0.1,4: BEEP 0.1,7: BEEP 0.2,12
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
