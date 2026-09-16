10 LET stage = 6
25 DIM g(8,8)
26 FOR r = 1 TO 8: FOR c = 1 TO 8: LET g(r,c) = -1: NEXT c: NEXT r
27 LET lr = 0: LET lc = 0: LET pr = 0: LET pc = 0
28 LET d = 0: LET v = 0: LET a$ = "": LET b$ = "": LET p$ = ""
80 LET s$ = "N=1-2, M=3-4, F=5+ steps.": GO SUB 2600
150 LET d = ABS (pr - tr) + ABS (pc - tc)
151 IF d > 4 THEN LET d = 3: GO TO 160
152 IF d > 2 THEN LET d = 2: GO TO 160
153 IF d > 0 THEN LET d = 1
160 LET g(pr,pc) = d
200 LET oldr = lr: LET oldc = lc: LET lr = pr: LET lc = pc
210 IF oldr = 0 THEN GO TO 240
220 LET r = oldr: LET c = oldc: GO SUB 2100
240 LET r = pr: LET c = pc: GO SUB 2100
260 LET s$ = "Far: at least 5 steps away."
261 IF d = 2 THEN LET s$ = "Medium: 3 or 4 steps away."
262 IF d = 1 THEN LET s$ = "Near: 1 or 2 steps away."
280 IF d = 0 THEN LET s$ = "Found! Q quits; RUN tries again"
290 GO SUB 2600
310 GO TO 100
1130 GO SUB 2100
1190 RETURN
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
2600 PAPER 0: INK 7
2610 PRINT AT 21, 0; "                               ";
2620 PRINT AT 21, 0; s$;
2630 RETURN
3015 IF LEN a$ > 16 THEN GO SUB 1000
3100 LET s$ = "Use one digit from 1 to 8.": GO SUB 2600
9000 LET s$ = "Finished. RUN to try again.": GO SUB 2600
