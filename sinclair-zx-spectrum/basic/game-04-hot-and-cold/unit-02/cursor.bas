10 CLS
20 LET r = 10
30 LET c = 15
40 PRINT AT r, c; "+"
50 IF INKEY$ = "" THEN GO TO 50
60 PRINT AT r, c; " "
70 LET r = r + 1
80 PRINT AT r, c; "+"
90 IF INKEY$ = "" THEN GO TO 90
