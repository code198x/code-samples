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
