10 LET stage = 6
15 GO SUB 5000
20 LET tr = 3: LET tc = 6
25 DIM g(8,8)
26 FOR r = 1 TO 8: FOR c = 1 TO 8: LET g(r,c) = -1: NEXT c: NEXT r
27 LET n = 0: LET lr = 0: LET lc = 0: LET pr = 0: LET pc = 0
28 LET d = 0: LET v = 0: LET a$ = "": LET b$ = "": LET p$ = ""
30 GO SUB 1000
80 LET s$ = "N=1-2, M=3-4, F=5+ steps.": GO SUB 2600
100 LET p$ = "Row": GO SUB 3000: LET pr = v
110 LET p$ = "Column": GO SUB 3000: LET pc = v
120 LET seen = g(pr,pc)
130 LET d = seen
140 IF seen <> -1 THEN GO TO 200
150 LET d = ABS (pr - tr) + ABS (pc - tc)
151 IF d > 4 THEN LET d = 3: GO TO 160
152 IF d > 2 THEN LET d = 2: GO TO 160
153 IF d > 0 THEN LET d = 1
160 LET g(pr,pc) = d: LET n = n + 1
200 LET oldr = lr: LET oldc = lc: LET lr = pr: LET lc = pc
210 IF oldr = 0 THEN GO TO 240
220 LET r = oldr: LET c = oldc: GO SUB 2100
240 LET r = pr: LET c = pc: GO SUB 2100
250 GO SUB 2500
260 LET s$ = "Far: at least 5 steps away."
261 IF d = 2 THEN LET s$ = "Medium: 3 or 4 steps away."
262 IF d = 1 THEN LET s$ = "Near: 1 or 2 steps away."
270 IF seen <> -1 THEN LET s$ = "Already probed. No extra count."
280 IF d = 0 THEN LET s$ = "Found in " + STR$ n + " distinct probes."
290 GO SUB 2600
300 IF d = 0 THEN GO TO 6000
310 GO TO 100
1000 BORDER 1: PAPER 0: INK 7: CLS
1010 PRINT AT 0, 6; "SONAR N1-2 M3-4 F5+"
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
1130 GO SUB 2100
1150 NEXT c
1160 PAPER 0: INK 7
1170 NEXT r
1180 GO SUB 2500
1190 RETURN
2000 LET y = 4 + 2 * (r - 1): LET x = 5 + 3 * (c - 1)
2010 PAPER 1: INK 7
2020 IF r + c = 2 * INT ((r + c) / 2) THEN PAPER 5: INK 0
2030 RETURN
2100 GO SUB 2000
2110 LET z = g(r,c): LET b$ = ". "
2120 IF z = -1 THEN GO TO 2160
2130 LET b$ = " F"
2140 IF z = 2 THEN LET b$ = " M"
2145 IF z = 1 THEN LET b$ = " N"
2150 IF z = 0 THEN LET b$ = " *"
2160 LET m$ = " "
2170 IF r = lr AND c = lc THEN LET m$ = ">"
2180 PRINT AT y, x; m$; b$; AT y + 1, x; "   "
2190 RETURN
2500 PAPER 0: INK 7
2510 PRINT AT 1, 0; "Distinct probes: "; n; "   "
2520 RETURN
2600 PAPER 0: INK 7
2610 PRINT AT 21, 0; "                               ";
2620 PRINT AT 21, 0; s$;
2630 RETURN
3000 PAPER 0: INK 7
3010 INPUT (p$ + " (1-8, Q): "); LINE a$
3015 IF LEN a$ > 16 THEN GO SUB 1000
3020 IF a$ = "q" OR a$ = "Q" THEN GO TO 9000
3030 IF LEN a$ <> 1 THEN GO TO 3100
3040 IF a$ < "1" OR a$ > "8" THEN GO TO 3100
3050 LET v = VAL a$
3060 RETURN
3100 LET s$ = "Use one digit from 1 to 8.": GO SUB 2600
3110 GO TO 3010
5000 BORDER 1: PAPER 0: INK 7: CLS
5010 PRINT AT 2, 9; "SONAR - BANDS"
5020 PRINT AT 5, 1; "Find one object on an 8x8 grid."
5030 PRINT AT 7, 1; "Enter a row, then a column."
5040 PRINT AT 9, 1; "N = near 1-2. M = medium 3-4."
5050 PRINT AT 11, 1; "F = far 5+. Rows plus columns."
5060 PRINT AT 13, 1; "Old clues stay. > marks latest."
5070 PRINT AT 15, 1; "* means found. No probe limit."
5080 PRINT AT 18, 1; "Q leaves from any prompt."
5090 INPUT "ENTER to search, Q quits: "; LINE a$
5100 IF a$ = "q" OR a$ = "Q" THEN GO TO 9000
5110 IF a$ <> "" THEN GO TO 5000
5120 RETURN
6000 INPUT "R another round, Q quits: "; LINE a$
6010 IF LEN a$ > 16 THEN GO SUB 1000
6020 IF a$ = "q" OR a$ = "Q" THEN GO TO 9000
6030 IF a$ = "r" OR a$ = "R" THEN GO TO 20
6040 LET s$ = "Enter R for another round or Q.": GO SUB 2600
6050 GO TO 6000
9000 LET s$ = "Finished. RUN to try again.": GO SUB 2600
9010 STOP
