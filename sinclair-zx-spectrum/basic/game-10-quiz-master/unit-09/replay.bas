  10 DIM k(8): DIM s(4)
  20 RESTORE: FOR i = 1 TO 8: READ k(i): NEXT i
  30 RESTORE 600
  40 FOR i = 1 TO 4: LET s(i) = 0: NEXT i
  50 LET score = 0: LET n = 0
  60 FOR c = 1 TO 4
  70 READ t$,ink
  80 FOR q = 1 TO 2
  90 LET n = n + 1
 100 CLS
 110 PAPER ink: INK 7
 120 FOR i = 0 TO 31: PRINT " ";: NEXT i
 130 PRINT AT 0,1;t$
 140 PRINT AT 0,26;score;"/8"
 150 PAPER 7: INK 0
 160 READ q$,a$,b$,c$,d$
 170 PRINT AT 2,0;"Question ";n;" of 8"
 180 PRINT AT 4,0;q$
 190 PRINT AT 7,2;"1. ";a$
 200 PRINT AT 8,2;"2. ";b$
 210 PRINT AT 9,2;"3. ";c$
 220 PRINT AT 10,2;"4. ";d$
 230 PRINT AT 12,0;: INPUT "Answer (1-4): ";g
 240 IF g = k(n) THEN PRINT AT 14,0;"Correct!": LET score = score + 1: LET s(c) = s(c) + 1: BEEP 0.2,12
 250 IF g <> k(n) THEN PRINT AT 14,0;"The answer was ";k(n): BEEP 0.3,-5
 260 PRINT AT 0,26;score;"/8"
 270 PAUSE 80
 280 NEXT q
 290 NEXT c
 300 CLS
 310 PRINT AT 3,9;"Quiz complete!"
 320 PRINT AT 5,6;"You scored ";score;" out of 8"
 330 PRINT AT 8,4;"Animals:   ";s(1);" / 2"
 340 PRINT AT 9,4;"Space:     ";s(2);" / 2"
 350 PRINT AT 10,4;"History:   ";s(3);" / 2"
 360 PRINT AT 11,4;"Geography: ";s(4);" / 2"
 370 IF score = 8 THEN INK 4: PRINT AT 14,10;"Quiz Master!": GO TO 410
 380 IF score >= 6 THEN INK 5: PRINT AT 14,12;"Expert": GO TO 410
 390 IF score >= 4 THEN INK 6: PRINT AT 14,11;"Not bad": GO TO 410
 400 INK 2: PRINT AT 14,9;"Keep trying"
 410 INK 0
 420 BEEP 0.1,0: BEEP 0.1,4: BEEP 0.1,7: BEEP 0.2,12
 430 PRINT AT 17,0;: INPUT "Play again? (y/n): ";p$
 440 IF p$ = "y" OR p$ = "Y" THEN GO TO 20
 450 CLS: PRINT "Thanks for playing!"
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
