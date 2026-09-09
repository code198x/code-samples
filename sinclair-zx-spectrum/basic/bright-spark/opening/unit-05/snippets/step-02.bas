275 PRINT AT 20,0;"1-4 choose. Hold q to quit."
1000 PRINT AT 18,0;"WATCH                         "
1010 FOR i=1 TO LEN s$
1020 IF INKEY$="q" THEN GO TO 1900
1030 LET p=VAL s$(i)
1040 GO SUB 900
1050 NEXT i
1060 IF INKEY$="q" THEN GO TO 1900
1070 PRINT AT 18,0;"Release the keys.              "
1080 GO SUB 1600
1090 PRINT AT 18,0;"YOUR TURN                     "
1100 FOR i=1 TO LEN s$
1110 GO SUB 1500
1120 GO SUB 900
1130 GO SUB 1600
1140 IF k$<>s$(i) THEN GO TO 1800
1150 NEXT i
1160 PRINT AT 18,0;"Order complete.               "
1170 STOP
1800 PRINT AT 18,0;"Different choice.             "
1810 BEEP 0.1,-12
1820 STOP
