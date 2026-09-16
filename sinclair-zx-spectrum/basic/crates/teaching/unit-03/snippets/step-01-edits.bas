110 GO SUB 3000
120 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
150 LET dr = 0: LET dc = 0
160 IF k$ = "i" OR k$ = "I" THEN LET dr = -1
170 IF k$ = "k" OR k$ = "K" THEN LET dr = 1
180 IF k$ = "j" OR k$ = "J" THEN LET dc = -1
190 IF k$ = "l" OR k$ = "L" THEN LET dc = 1
200 IF dr = 0 AND dc = 0 THEN GO TO 110
210 LET nr = pr + dr: LET nc = pc + dc
220 IF nr < 1 OR nr > 8 OR nc < 1 OR nc > 8 THEN GO TO 700
230 LET v = g(nr,nc)
240 IF v = 1 OR v = 3 THEN GO TO 700
260 GO TO 500
500 LET oldr = pr: LET oldc = pc
510 LET pr = nr: LET pc = nc: LET moves = moves + 1
520 LET r = oldr: LET c = oldc: GO SUB 2000
530 LET r = pr: LET c = pc: GO SUB 2000
600 GO SUB 2500
610 GO TO 110
700 GO TO 110
1020 PRINT AT 20, 2; INK 7; "I up  J left  K down  L right"
1030 PRINT AT 21, 13; INK 5; "Q quit";
1070 GO SUB 2500
2500 PRINT AT 1, 2; INK 7; "STEPS "; moves; "    "
2540 RETURN
3000 LET k$ = INKEY$
3010 IF k$ = h$ THEN GO TO 3000
3020 LET h$ = k$
3025 IF k$ = "" THEN GO TO 3000
3030 RETURN
9000 PAPER 0: INK 7
9010 PRINT AT 21, 0; "Finished. RUN to try again.     ";
9020 STOP
