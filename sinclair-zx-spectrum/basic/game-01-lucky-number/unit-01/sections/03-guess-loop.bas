 500 REM === Guess loop ===
 510 LET c=c+1
 520 PRINT AT 2,11; INK 6; BRIGHT 1;c;"  "
 530 INPUT "Your guess? ";g
 540 IF g<1 OR g>100 THEN GO TO 530
 550 REM === Show guess as big digits ===
 560 INK 6: GO SUB 2400
 570 IF g=n THEN GO TO 800
 580 LET d=ABS (g-n)
 590 REM === Temperature bar ===
 600 GO SUB 2200
 610 REM === Border colour ===
 620 IF d>40 THEN BORDER 0
 630 IF d>20 AND d<=40 THEN BORDER 1
 640 IF d>10 AND d<=20 THEN BORDER 6
 650 IF d>5 AND d<=10 THEN BORDER 2
 660 IF d<=5 THEN BORDER 7
 670 REM === Feedback ===
 680 LET r=17: GO SUB 3100
 690 LET r=18: GO SUB 3100
 700 IF g<n THEN LET r=17: LET t$="Too low!": INK 6: BRIGHT 1: GO SUB 3000: LET r=18: LET t$="Guess higher.": INK 5: BRIGHT 0: GO SUB 3000: BEEP 0.05,0: BEEP 0.1,10
 710 IF g>n THEN LET r=17: LET t$="Too high!": INK 3: BRIGHT 1: GO SUB 3000: LET r=18: LET t$="Guess lower.": INK 5: BRIGHT 0: GO SUB 3000: BEEP 0.05,10: BEEP 0.1,0
 720 GO TO 500
