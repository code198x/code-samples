10 REM Quiz Master
20 BORDER 1
30 INK 7
40 PAPER 1
50 CLS
60 PRINT AT 0, 10; "Quiz Master"
70 PRINT AT 4, 2; "Test your knowledge across"
80 PRINT AT 5, 2; "three categories!"
90 PRINT AT 8, 2; "Pick a topic, answer three"
100 PRINT AT 9, 2; "questions, then try another."
110 PRINT AT 12, 2; "Score well in all three to"
120 PRINT AT 13, 2; "earn the title Quiz Master!"
130 PRINT AT 20, 5; "Press any key to start"
140 IF INKEY$ = "" THEN GO TO 140
150 BORDER 7
160 PAPER 7
170 INK 0
180 LET t = 0
190 FOR k = 1 TO 3
200 IF k = 1 THEN RESTORE 800
210 IF k = 2 THEN RESTORE 900
220 IF k = 3 THEN RESTORE 1000
230 LET n = 0
240 FOR i = 1 TO 3
250 READ q$, a$, b$, c$, r
260 CLS
270 PRINT AT 0, 0; "Category "; k; " of 3"
280 PRINT AT 0, 22; "Total: "; t
290 IF k = 1 THEN INK 4: PRINT AT 2, 2; "Science": INK 0
300 IF k = 2 THEN INK 1: PRINT AT 2, 2; "Geography": INK 0
310 IF k = 3 THEN INK 2: PRINT AT 2, 2; "History": INK 0
320 PRINT AT 5, 2; q$
330 PRINT AT 8, 4; "1. "; a$
340 PRINT AT 9, 4; "2. "; b$
350 PRINT AT 10, 4; "3. "; c$
360 PRINT AT 13, 2;
370 INPUT "Your answer (1-3)? "; g
380 IF g < 1 OR g > 3 THEN GO TO 370
390 IF g = r THEN GO TO 420
400 INK 2: PRINT AT 15, 2; "Wrong!": INK 0
410 BEEP 0.3, -5: GO TO 460
420 INK 4: PRINT AT 15, 2; "Correct!": INK 0
430 BEEP 0.15, 12
440 BEEP 0.15, 16
450 LET n = n + 1
460 PAUSE 50
470 NEXT i
480 LET t = t + n
490 CLS
500 PRINT AT 10, 6; "Category score: "; n; "/3"
510 PAUSE 75
520 NEXT k
530 BORDER 1
540 PAPER 1
550 INK 7
560 CLS
570 PRINT AT 4, 10; "Quiz Master"
580 PRINT AT 8, 10; "Game Over!"
590 PRINT AT 11, 8; "Score: "; t; " out of 9"
600 IF t = 9 THEN PRINT AT 14, 5; "Perfect! Quiz Master!": GO TO 660
610 IF t >= 7 THEN PRINT AT 14, 8; "Well done!": GO TO 660
620 IF t >= 4 THEN PRINT AT 14, 6; "Not bad, keep trying!": GO TO 660
630 PRINT AT 14, 6; "Better luck next time!"
660 BEEP 0.5, 7
670 PRINT AT 20, 5; "Press any key to exit"
680 IF INKEY$ = "" THEN GO TO 680
690 BORDER 7
700 PAPER 7
710 INK 0
720 CLS
800 DATA "What gas do plants breathe in?","Oxygen","Nitrogen","Carbon dioxide",3
810 DATA "How many bones in the body?","106","206","306",2
820 DATA "What planet has rings?","Mars","Saturn","Jupiter",2
900 DATA "What is the longest river?","Amazon","Nile","Thames",2
910 DATA "Which continent is biggest?","Africa","Europe","Asia",3
920 DATA "What ocean is the largest?","Atlantic","Indian","Pacific",3
1000 DATA "When did WW2 end?","1943","1945","1947",2
1010 DATA "Who built the pyramids?","Romans","Greeks","Egyptians",3
1020 DATA "When was the Moon landing?","1959","1969","1979",2
