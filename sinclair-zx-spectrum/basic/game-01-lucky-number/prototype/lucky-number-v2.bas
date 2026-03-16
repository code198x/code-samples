   1 REM Lucky Number v2
  10 BORDER 0: PAPER 0: INK 7: CLS
  20 REM === Rainbow cascade ===
  30 FOR i=0 TO 7
  40 FOR j=0 TO 31
  50 PRINT AT i,j; PAPER i;" "
  60 NEXT j
  65 BEEP 0.01,i*4+20
  70 NEXT i
  80 REM === Block title: LUCKY ===
  90 RESTORE 900
 100 FOR r=0 TO 4
 110 READ a$
 120 FOR q=1 TO LEN a$
 130 IF a$(q)="1" THEN PRINT AT 9+r,6+q; PAPER 6;" "
 140 NEXT q
 150 NEXT r
 160 REM === Block title: NUMBER ===
 170 RESTORE 950
 180 FOR r=0 TO 4
 190 READ a$
 200 FOR q=1 TO LEN a$
 210 IF a$(q)="1" THEN PRINT AT 15+r,4+q; PAPER 5;" "
 220 NEXT q
 230 NEXT r
 240 PRINT AT 21,6; INK 7; FLASH 1;" Press any key "; FLASH 0
 250 IF INKEY$="" THEN GO TO 250
 260 REM === New game ===
 270 LET n=INT (RND*100)+1
 280 LET c=0
 290 CLS
 300 REM === Game header ===
 310 FOR i=0 TO 31
 320 PRINT AT 0,i; PAPER 1;" "
 330 NEXT i
 340 PRINT AT 0,9; PAPER 1; INK 6; BRIGHT 1;" LUCKY NUMBER "
 350 REM === Static labels ===
 360 PRINT AT 3,2; INK 5;"Guesses: 0"
 370 PRINT AT 5,2; INK 7;"Temperature:"
 380 REM === Guess loop ===
 390 LET c=c+1
 400 PRINT AT 3,10; INK 5;c;"  "
 410 INPUT "Your guess (1-100): ";g
 420 IF g<1 OR g>100 THEN GO TO 410
 430 IF g=n THEN GO TO 700
 440 LET d=ABS (g-n)
 450 REM === Heat bar ===
 460 LET h=INT ((100-d)/3.4)+1
 470 IF h>30 THEN LET h=30
 480 IF h<1 THEN LET h=1
 490 FOR i=1 TO 30
 500 IF i<=h AND i<=10 THEN PRINT AT 6,1+i; PAPER 1;" "
 510 IF i<=h AND i>10 AND i<=20 THEN PRINT AT 6,1+i; PAPER 6;" "
 520 IF i<=h AND i>20 AND i<=26 THEN PRINT AT 6,1+i; PAPER 2;" "
 530 IF i<=h AND i>26 THEN PRINT AT 6,1+i; PAPER 7;" "
 540 IF i>h THEN PRINT AT 6,1+i; PAPER 0;" "
 550 NEXT i
 560 REM === Border feedback ===
 570 IF d<=5 THEN BORDER 2
 580 IF d>5 AND d<=15 THEN BORDER 6
 590 IF d>15 AND d<=30 THEN BORDER 1
 600 IF d>30 THEN BORDER 0
 610 REM === Direction ===
 620 PRINT AT 9,2;"                            "
 630 PRINT AT 10,2;"                            "
 640 IF g<n THEN PRINT AT 9,2; INK 6; BRIGHT 1;"Too low!": PRINT AT 10,2; INK 5; BRIGHT 0;"Guess higher."
 650 IF g>n THEN PRINT AT 9,2; INK 3; BRIGHT 1;"Too high!": PRINT AT 10,2; INK 5; BRIGHT 0;"Guess lower."
 660 BEEP 0.05,h/2-8
 670 GO TO 390
 700 REM === Win! ===
 710 FOR i=1 TO 20
 720 BORDER INT (RND*8)
 730 BEEP 0.03,10+i
 740 NEXT i
 750 BORDER 0
 760 REM === Fill heat bar green ===
 770 FOR i=1 TO 30
 780 PRINT AT 6,1+i; PAPER 4;" "
 790 BEEP 0.01,i
 800 NEXT i
 810 PRINT AT 9,2;"                            "
 820 PRINT AT 10,2;"                            "
 830 PRINT AT 9,6; INK 4; BRIGHT 1; FLASH 1;"  YOU GOT IT!  "; FLASH 0
 840 PRINT AT 11,6; INK 5;"The number was ";n
 850 PRINT AT 13,6; INK 7;"Found in ";c;" guesses"
 860 IF c<=5 THEN PRINT AT 15,6; INK 2; BRIGHT 1;"Incredible!"
 870 IF c>5 AND c<=8 THEN PRINT AT 15,6; INK 6;"Impressive!"
 880 IF c>8 AND c<=12 THEN PRINT AT 15,6; INK 5;"Well done!"
 890 IF c>12 THEN PRINT AT 15,6; INK 4;"Keep practising!"
 892 BRIGHT 0
 895 PRINT AT 19,6; INK 7;"Play again? (y/n)"
 896 LET k$=INKEY$
 897 IF k$="" THEN GO TO 896
 898 IF k$="y" THEN GO TO 260
 899 BORDER 7: PAPER 7: INK 0: CLS: PRINT "Thanks for playing!": STOP
 900 REM === LUCKY font data ===
 901 REM L   U   C   K   Y
 902 DATA "1...1.1.111.1.1.1.1"
 903 DATA "1...1.1.1...1.1.1.1"
 904 DATA "1...1.1.1...11...1."
 905 DATA "1...1.1.1...1.1..1."
 906 DATA "111..1..111.1.1..1."
 950 REM === NUMBER font data ===
 951 REM N   U   M   B   E   R
 952 DATA "1.1.1.1.1.1.11..111.11."
 953 DATA "111.1.1.111.1.1.1...1.1"
 954 DATA "1.1.1.1.111.11..11..11."
 955 DATA "1.1.1.1.1.1.1.1.1...1.1"
 956 DATA "1.1..1..1.1.11..111.1.1"
