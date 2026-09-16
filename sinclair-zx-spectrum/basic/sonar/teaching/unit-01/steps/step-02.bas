10 LET stage = 1
20 LET tr = 3: LET tc = 6
30 GO SUB 1000
40 LET r = tr: LET c = tc: GO SUB 2000
50 PRINT AT y, x; " X "
80 PAPER 0: INK 7
90 PRINT AT 21, 1; "X marks row 3, column 6.";
100 STOP
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
