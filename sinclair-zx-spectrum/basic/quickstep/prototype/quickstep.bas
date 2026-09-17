10 GO SUB 7000: GO SUB 5000
100 DIM p(6): DIM d(6): DIM t(6): DIM v(6): DIM r(6): DIM a$(6,30): DIM b$(6,30)
110 LET x = 7: LET y = 8: LET steps = 0: RESTORE 7100
120 FOR i = 1 TO 6: READ p(i),d(i),v(i),r(i): LET t(i) = v(i): NEXT i
140 FOR i = 1 TO 6: FOR j = 0 TO 2: FOR k = 0 TO 3
150 LET c = 2 * p(i) + 10 * j + k: LET c = c - 30 * INT (c / 30) + 1
160 LET a$(i,c) = CHR$ (144 + k): LET b$(i,c) = CHR$ (148 + k)
170 NEXT k: NEXT j: NEXT i
180 GO SUB 1000: GO SUB 3000: LET dx = 0: LET dy = 0: POKE 23560,0: LET tick = PEEK 23672
200 LET k$ = INKEY$
220 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
230 IF k$ = "r" OR k$ = "R" THEN GO TO 100
280 LET elapsed = PEEK 23672 - tick: IF elapsed < 0 THEN LET elapsed = elapsed + 256
290 IF elapsed < 32 THEN GO TO 200
291 LET k$ = INKEY$: IF k$ = "" THEN LET k$ = CHR$ (PEEK 23560)
292 POKE 23560,0: LET dx = 0: LET dy = 0
293 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
294 IF k$ = "r" OR k$ = "R" THEN GO TO 100
295 IF k$ = "i" OR k$ = "I" THEN LET dy = -1
296 IF k$ = "k" OR k$ = "K" THEN LET dy = 1
297 IF k$ = "j" OR k$ = "J" THEN LET dx = -1
298 IF k$ = "l" OR k$ = "L" THEN LET dx = 1
300 LET tick = PEEK 23672: LET nx = x + dx: LET ny = y + dy
310 IF nx < 0 OR nx > 14 OR ny < 0 OR ny > 8 THEN LET nx = x: LET ny = y
320 GO SUB 2000
330 IF hit = 1 THEN LET e$ = "That gap was not clear.": GO TO 4000
340 IF nx = x AND ny = y THEN GO TO 350
341 GO SUB 3100: LET x = nx: LET y = ny: GO SUB 3000
350 FOR i = 1 TO 6: LET t(i) = t(i) - 1
360 IF t(i) > 0 THEN GO TO 430
370 LET t(i) = v(i): LET p(i) = p(i) + d(i)
380 IF p(i) = 15 THEN LET p(i) = 0
390 IF p(i) = -1 THEN LET p(i) = 14
400 IF d(i) = 1 THEN LET a$(i) = a$(i,29 TO 30) + a$(i,1 TO 28): LET b$(i) = b$(i,29 TO 30) + b$(i,1 TO 28)
410 IF d(i) = -1 THEN LET a$(i) = a$(i,3 TO 30) + a$(i,1 TO 2): LET b$(i) = b$(i,3 TO 30) + b$(i,1 TO 2)
420 GO SUB 1200: IF y = r(i) THEN GO SUB 3000
430 NEXT i
440 GO SUB 2000: LET steps = steps + 1
450 IF hit = 1 THEN LET e$ = "The lane caught you.": GO TO 4000
460 IF x = 7 AND y = 0 THEN LET e$ = "Across! A well-timed journey.": GO TO 4000
470 LET dx = 0: LET dy = 0: GO TO 200
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,1; INK 5; "QUICKSTEP"; AT 0,21; INK 4; "EXIT ABOVE"
1030 FOR j = 0 TO 8 STEP 4
1040 PRINT AT 2+2*j,1; PAPER 1; INK 5; s$; AT 3+2*j,1; s$
1060 NEXT j
1070 PRINT AT 2,15; PAPER 4; INK 7; "  "; AT 3,15; "  "
1080 FOR i = 1 TO 6: GO SUB 1200: LET z$ = ">": IF d(i) = -1 THEN LET z$ = "<"
1081 PRINT AT row,0; PAPER 0; INK ink; z$; AT row,31; z$
1082 NEXT i
1090 PRINT AT 20,2; PAPER 0; INK 7; "I up  J left  K down  L right"
1110 PRINT AT 21,2; INK 7; "R retry              Q quit";
1120 RETURN
1200 LET row = 2 + 2 * r(i): LET ink = 6: IF d(i) = -1 THEN LET ink = 5
1210 PRINT AT row,1; PAPER 0; INK ink; a$(i); AT row+1,1; b$(i)
1240 RETURN
2000 LET hit = 0: IF ny = 0 OR ny = 4 OR ny = 8 THEN RETURN
2010 LET lane = ny: IF ny > 4 THEN LET lane = ny - 1
2015 LET delta = nx - p(lane): LET delta = delta - 5 * INT (delta / 5)
2020 IF delta < 2 THEN LET hit = 1
2030 RETURN
3000 LET paper = 0: IF y = 0 OR y = 4 OR y = 8 THEN LET paper = 1
3010 IF y = 0 AND x = 7 THEN LET paper = 4
3020 PRINT AT 2+2*y,1+2*x; PAPER paper; INK 7; h$; AT 3+2*y,1+2*x; f$
3030 RETURN
3100 IF y <> 0 AND y <> 4 AND y <> 8 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN
3110 PRINT AT 2+2*y,1+2*x; PAPER 1; INK 5; g$; AT 3+2*y,1+2*x; g$: RETURN
4000 PRINT AT 1,1; PAPER 0; INK 6; e$
4010 PRINT AT 20,2; PAPER 0; INK 7; "R plays again. Q quits.    "
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
5000 BORDER 0: PAPER 0: INK 7: CLS
5010 PRINT AT 3,11; INK 5; "QUICKSTEP"
5020 PRINT AT 6,3; "Six lanes. One halfway rest."
5030 PRINT AT 8,3; "I up   J left   K down"
5040 PRINT AT 9,3; "L right"
5050 PRINT AT 11,3; "Step into a gap, then watch."
5060 PRINT AT 13,3; "Plan beyond the next lane."
5070 PRINT AT 15,3; "Reach the green exit at top."
5080 PRINT AT 17,3; "R retries. Q quits."
5090 PRINT AT 20,11; INK 6; "S starts."
5100 LET k$ = INKEY$
5110 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5120 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5100
5130 RETURN
7000 RESTORE 7200: FOR j = 0 TO 103: READ n: POKE USR "a" + j,n: NEXT j
7010 LET h$ = CHR$ 152 + CHR$ 153: LET f$ = CHR$ 154 + CHR$ 155
7020 LET g$ = CHR$ 156 + CHR$ 156: LET s$ = "": FOR j = 1 TO 15: LET s$ = s$ + g$: NEXT j: RETURN
7100 DATA 0,1,3,1,9,-1,4,2,11,1,2,3
7110 DATA 7,-1,3,5,1,1,4,6,10,-1,2,7
7200 DATA 0,0,63,127,120,120,120,120
7210 DATA 0,0,255,255,24,24,24,24
7220 DATA 0,0,255,255,24,24,24,24
7230 DATA 0,0,252,254,30,30,30,30
7240 DATA 127,127,127,127,63,7,7,0
7250 DATA 255,255,255,255,255,192,192,0
7260 DATA 255,255,255,255,255,3,3,0
7270 DATA 254,254,254,254,252,224,224,0
7280 DATA 0,7,15,13,15,7,3,31
7290 DATA 0,224,240,176,240,224,192,248
7300 DATA 63,55,7,7,6,6,14,0
7310 DATA 252,236,224,224,96,96,112,0
7320 DATA 0,0,0,0,0,16,0,0
9000 PAPER 0: INK 7: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
