 700 REM === WIN! ===
 710 FOR i=1 TO 20
 720 BORDER INT (RND*8)
 730 BEEP 0.03,10+i
 740 NEXT i
 750 BORDER 0
 760 REM === Green digits ===
 770 LET pc=4: LET v=g: LET dr=4: GO SUB 8200
 780 REM === Green heat bar ===
 790 FOR i=1 TO 30
 800 PRINT AT 11,1+i; PAPER 4;" "
 810 BEEP 0.01,i
 820 NEXT i
