 800 REM === WIN! ===
 810 FOR i=1 TO 20
 820 BORDER INT (RND*8)
 830 BEEP 0.03,10+i
 840 NEXT i
 850 BORDER 0
 860 REM === Green digits ===
 870 LET pc=4: GO SUB 2400
 880 REM === Green bar ===
 890 FOR i=1 TO 28
 900 PRINT AT 15,1+i; PAPER 4;" "
 910 BEEP 0.01,i
 920 NEXT i
 930 PRINT AT 17,2;"                            "
 940 PRINT AT 18,2;"                            "
 950 PRINT AT 17,8; INK 4; BRIGHT 1; FLASH 1;"  YOU GOT IT!  "; FLASH 0
 960 PRINT AT 19,8; INK 5;"The number was ";n
 970 PRINT AT 20,8; INK 7;"Found in ";c;" guesses"
 980 IF c<=5 THEN PRINT AT 18,10; INK 2; BRIGHT 1;"Incredible!"
 990 IF c>5 AND c<=8 THEN PRINT AT 18,10; INK 6;"Impressive!"
1000 IF c>8 AND c<=12 THEN PRINT AT 18,10; INK 5;"Well done!"
1010 IF c>12 THEN PRINT AT 18,9; INK 4;"Keep practising!"
1020 BRIGHT 0
1030 PRINT AT 21,7; PAPER 1; INK 5;" Play again? y/n  "
1040 LET k$=INKEY$
1050 IF k$="" THEN GO TO 1040
1060 IF k$="y" THEN GO TO 300
1070 BORDER 7: PAPER 7: INK 0: CLS
1080 PRINT "Thanks for playing!"
1090 STOP
