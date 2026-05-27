   5 DIM k(8): DIM s(4)
  10 CLS
  20 INK 2: PRINT AT 6,10;"QUIZ MASTER"
  30 INK 0: PRINT AT 9,5;"Press any key to start"
  40 PAUSE 0
  50 RESTORE: FOR i = 1 TO 8: READ k(i): NEXT i
  60 RESTORE 600
  70 FOR i = 1 TO 4: LET s(i) = 0: NEXT i
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
 270 IF g = k(n) THEN PRINT AT 14,0;"Correct!": LET score = score + 1: LET s(c) = s(c) + 1: BEEP 0.2,12
 280 IF g <> k(n) THEN PRINT AT 14,0;"The answer was ";k(n): BEEP 0.3,-5
 290 PRINT AT 0,26;score;"/8"
 300 PAUSE 80
 310 NEXT q
 320 PRINT AT 16,2;t$;": ";s(c);" out of 2"
 330 PAUSE 60
 340 NEXT c
 350 CLS
 360 PRINT AT 3,9;"Quiz complete!"
 370 PRINT AT 5,6;"You scored ";score;" out of 8"
 380 PRINT AT 8,4;"Animals:   ";s(1);" / 2"
 390 PRINT AT 9,4;"Space:     ";s(2);" / 2"
 400 PRINT AT 10,4;"History:   ";s(3);" / 2"
 410 PRINT AT 11,4;"Geography: ";s(4);" / 2"
 420 IF score = 8 THEN INK 4: PRINT AT 14,10;"Quiz Master!": GO TO 460
 430 IF score >= 6 THEN INK 5: PRINT AT 14,12;"Expert": GO TO 460
 440 IF score >= 4 THEN INK 6: PRINT AT 14,11;"Not bad": GO TO 460
 450 INK 2: PRINT AT 14,9;"Keep trying"
 460 INK 0
 470 BEEP 0.1,0: BEEP 0.1,4: BEEP 0.1,7: BEEP 0.2,12
 480 PRINT AT 17,0;: INPUT "Play again? (y/n): ";p$
 490 IF p$ = "y" OR p$ = "Y" THEN GO TO 10
 500 CLS: PRINT "Thanks for playing!"
 510 STOP
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
