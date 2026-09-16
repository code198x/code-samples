10 LET stage = 2
60 LET lr = 0: LET lc = 0
70 PAPER 0: INK 7
80 PRINT AT 21, 0; "Row then column. Q quits.";
100 LET p$ = "Row": GO SUB 3000: LET pr = v
110 PRINT AT 21, 0; "Selected row: "; pr; "                ";
115 GO TO 100
3000 PAPER 0: INK 7
3010 INPUT (p$ + " (1-8, Q): "); LINE a$
3015 IF LEN a$ > 16 THEN GO SUB 4000
3020 IF a$ = "q" OR a$ = "Q" THEN GO TO 9000
3030 IF LEN a$ <> 1 THEN GO TO 3100
3040 IF a$ < "1" OR a$ > "8" THEN GO TO 3100
3050 LET v = VAL a$
3060 RETURN
3100 PRINT AT 21, 0; "Use one digit from 1 to 8.      ";
3110 GO TO 3010
4000 GO SUB 1000
4010 LET r = tr: LET c = tc: GO SUB 2000
4020 PRINT AT y, x; " X "
4030 IF lr = 0 THEN GO TO 4070
4040 LET r = lr: LET c = lc: GO SUB 2000
4050 PRINT AT y, x; ">"; b$
4070 PAPER 0: INK 7
4080 RETURN
9000 PRINT AT 21, 0; "Finished. RUN to try again.     ";
9010 STOP
