10 LET stage = 2
20 LET tr = 3: LET tc = 6
30 GO SUB 1000
40 LET r = tr: LET c = tc: GO SUB 2000
50 PRINT AT y, x; " X "
60 LET lr = 0: LET lc = 0
70 PAPER 0: INK 7
80 PRINT AT 21, 0; "Row then column. Q quits.";
100 LET p$ = "Row": GO SUB 3000: LET pr = v
110 LET p$ = "Column": GO SUB 3000: LET pc = v
120 IF lr = 0 THEN GO TO 160
130 LET r = lr: LET c = lc: GO SUB 2000
140 PRINT AT y, x; " . "
150 IF r = tr AND c = tc THEN PRINT AT y, x; " X "
160 LET r = pr: LET c = pc: GO SUB 2000
170 LET d = 1
180 IF r = tr AND c = tc THEN LET d = 0
190 LET b$ = " -"
200 IF d = 0 THEN LET b$ = " *"
210 PRINT AT y, x; ">"; b$
220 LET lr = r: LET lc = c
230 PAPER 0: INK 7
240 PRINT AT 21, 0; "                               ";
250 IF d <> 0 THEN PRINT AT 21, 0; "Miss. Try another cell.";
260 IF d = 0 THEN PRINT AT 21, 0; "Found! Q quits; RUN tries again";
270 GO TO 100
1000 BORDER 1: PAPER 0: INK 7: CLS
1010 PRINT AT 0, 9; "SONAR - STAGE "; stage
1020 FOR c = 1 TO 8
1030 PRINT AT 2, 6 + 3 * (c - 1); c
1040 NEXT c
1050 PRINT AT 3, 4; "+------------------------+"
1060 PRINT AT 20, 4; "+------------------------+"
1070 FOR r = 1 TO 8
1080 PRINT AT 4 + 2 * (r - 1), 2; r
1090 FOR k = 0 TO 1
1100 PRINT AT 4 + 2 * (r - 1) + k, 4; ":"; AT 4 + 2 * (r - 1) + k, 29; ":"
1110 NEXT k
1120 FOR c = 1 TO 8
1130 GO SUB 2000
1140 PRINT AT y, x; " . "; AT y + 1, x; "   "
1150 NEXT c
1160 PAPER 0: INK 7
1170 NEXT r
1180 RETURN
2000 LET y = 4 + 2 * (r - 1): LET x = 5 + 3 * (c - 1)
2010 PAPER 1: INK 7
2020 IF r + c = 2 * INT ((r + c) / 2) THEN PAPER 5: INK 0
2030 RETURN
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
