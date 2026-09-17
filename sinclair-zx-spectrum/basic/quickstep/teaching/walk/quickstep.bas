10 GO SUB 7000
100 LET steps = 0
110 LET x = 7: LET y = 2
180 GO SUB 1000: GO SUB 3000
200 LET k$ = INKEY$
210 IF k$ = "" THEN GO TO 200
220 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
230 IF k$ = "r" OR k$ = "R" THEN GO TO 100
250 LET dx = 0: LET dy = 0
295 IF k$ = "i" OR k$ = "I" THEN LET dy = -1
296 IF k$ = "k" OR k$ = "K" THEN LET dy = 1
297 IF k$ = "j" OR k$ = "J" THEN LET dx = -1
298 IF k$ = "l" OR k$ = "L" THEN LET dx = 1
300 LET nx = x + dx: LET ny = y + dy
310 IF nx < 0 OR nx > 14 OR ny < 0 OR ny > 2 THEN LET nx = x: LET ny = y
340 IF nx = x AND ny = y THEN GO TO 470
341 GO SUB 3100: LET x = nx: LET y = ny: GO SUB 3000: GO TO 470
470 IF INKEY$ <> "" THEN GO TO 470
480 GO TO 200
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,1; INK 5; "QUICKSTEP"; AT 0,21; INK 4; "EXIT ABOVE"
1030 FOR j = 0 TO 2 STEP 2
1040 PRINT AT 2+2*j,1; PAPER 1; INK 5; s$; AT 3+2*j,1; s$
1060 NEXT j
1070 PRINT AT 2,15; PAPER 4; INK 7; "  "; AT 3,15; "  "
1090 PRINT AT 20,2; PAPER 0; INK 7; "I up  J left  K down  L right"
1110 PRINT AT 21,2; INK 7; "R retry              Q quit";
1120 RETURN
3000 LET paper = 0: IF y <> 1 THEN LET paper = 1
3010 IF y = 0 AND x = 7 THEN LET paper = 4
3020 PRINT AT 2+2*y,1+2*x; PAPER paper; INK 7; h$; AT 3+2*y,1+2*x; f$
3030 RETURN
3100 IF y = 1 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN
3110 IF y = 0 AND x = 7 THEN PRINT AT 2,15; PAPER 4; "  "; AT 3,15; "  ": RETURN
3120 PRINT AT 2+2*y,1+2*x; PAPER 1; INK 5; g$; AT 3+2*y,1+2*x; g$: RETURN
7000 RESTORE 7280: FOR j = 64 TO 103: READ n: POKE USR "a" + j,n: NEXT j
7010 LET h$ = CHR$ 152 + CHR$ 153: LET f$ = CHR$ 154 + CHR$ 155
7020 LET g$ = CHR$ 156 + CHR$ 156: LET s$ = "": FOR j = 1 TO 15: LET s$ = s$ + g$: NEXT j: RETURN
7280 DATA 0,7,15,13,15,7,3,31
7290 DATA 0,224,240,176,240,224,192,248
7300 DATA 63,55,7,7,6,6,14,0
7310 DATA 252,236,224,224,96,96,112,0
7320 DATA 0,0,0,0,0,16,0,0
9000 PAPER 0: INK 7: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
