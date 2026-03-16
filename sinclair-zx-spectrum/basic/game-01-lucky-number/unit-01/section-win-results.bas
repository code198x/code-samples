 830 PRINT AT 13,2;"                            "
 840 PRINT AT 14,2;"                            "
 850 PRINT AT 13,7; INK 4; BRIGHT 1; FLASH 1;"  YOU GOT IT!  "; FLASH 0
 860 PRINT AT 15,7; INK 5;"The number was ";n
 870 PRINT AT 16,7; INK 7;"Found in ";c;" guesses"
 880 IF c<=5 THEN PRINT AT 18,7; INK 2; BRIGHT 1;"Incredible!"
 890 IF c>5 AND c<=8 THEN PRINT AT 18,7; INK 6;"Impressive!"
 895 IF c>8 AND c<=12 THEN PRINT AT 18,7; INK 5;"Well done!"
 896 IF c>12 THEN PRINT AT 18,7; INK 4;"Keep practising!"
 897 BRIGHT 0
 898 PRINT AT 20,7; INK 7;"Play again? (y/n)"
 899 LET k$=INKEY$
 900 IF k$="" THEN GO TO 899
 910 IF k$="y" THEN GO TO 280
 920 BORDER 7: PAPER 7: INK 0: CLS
 930 PRINT "Thanks for playing!": STOP
