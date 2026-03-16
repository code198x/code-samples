 370 REM === Guess loop ===
 380 LET c=c+1
 390 PRINT AT 2,10; INK 5;c;"  "
 400 INPUT "Your guess (1-100): ";g
 410 IF g<1 OR g>100 THEN GO TO 400
 420 REM === Show guess big ===
 430 LET pc=6: LET v=g: LET dr=4: GO SUB 8200
 440 IF g=n THEN GO TO 700
 450 LET d=ABS (g-n)
 460 REM === Heat bar ===
 470 LET h=INT ((100-d)/3.4)+1
 480 IF h>30 THEN LET h=30
 490 IF h<1 THEN LET h=1
 500 FOR i=1 TO 30
 510 IF i<=h AND i<=10 THEN PRINT AT 11,1+i; PAPER 1;" "
 520 IF i<=h AND i>10 AND i<=20 THEN PRINT AT 11,1+i; PAPER 6;" "
 530 IF i<=h AND i>20 AND i<=26 THEN PRINT AT 11,1+i; PAPER 2;" "
 540 IF i<=h AND i>26 THEN PRINT AT 11,1+i; PAPER 7;" "
 550 IF i>h THEN PRINT AT 11,1+i; PAPER 0;" "
 560 NEXT i
 570 BEEP 0.05,h/2-8
 580 REM === Border ===
 590 IF d<=5 THEN BORDER 2
 600 IF d>5 AND d<=15 THEN BORDER 6
 610 IF d>15 AND d<=30 THEN BORDER 1
 620 IF d>30 THEN BORDER 0
 630 REM === Feedback ===
 640 PRINT AT 13,2;"                            "
 650 PRINT AT 14,2;"                            "
 660 IF g<n THEN PRINT AT 13,2; INK 6; BRIGHT 1;"Too low!": PRINT AT 14,2; INK 5; BRIGHT 0;"Guess higher."
 670 IF g>n THEN PRINT AT 13,2; INK 3; BRIGHT 1;"Too high!": PRINT AT 14,2; INK 5; BRIGHT 0;"Guess lower."
 680 GO TO 370
