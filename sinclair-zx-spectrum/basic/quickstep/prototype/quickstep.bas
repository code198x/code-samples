10 GO SUB 7000: GO SUB 5000
100 DIM p(3): DIM d(3): DIM t(3): DIM v(3): DIM a$(3,26): DIM b$(3,26)
110 LET x = 6: LET y = 6: LET steps = 0: LET p(1) = 2: LET p(2) = 8: LET p(3) = 5
120 FOR i = 1 TO 3: LET d(i) = 1: LET v(i) = 2: LET t(i) = 2: NEXT i
130 LET d(2) = -1: LET v(2) = 3: LET t(2) = 3
140 FOR i = 1 TO 3: FOR j = 0 TO 1: FOR k = 0 TO 3
150 LET c = 2 * p(i) + 14 * j + k: LET c = c - 26 * INT (c / 26) + 1
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
310 IF nx < 0 OR nx > 12 OR ny < 0 OR ny > 6 THEN LET nx = x: LET ny = y
320 GO SUB 2000
330 IF hit = 1 THEN LET e$ = "That gap was not clear.": GO TO 4000
340 IF nx = x AND ny = y THEN GO TO 350
341 GO SUB 3100: LET x = nx: LET y = ny: GO SUB 3000
350 FOR i = 1 TO 3: LET t(i) = t(i) - 1
360 IF t(i) > 0 THEN GO TO 430
370 LET t(i) = v(i): LET p(i) = p(i) + d(i)
380 IF p(i) = 13 THEN LET p(i) = 0
390 IF p(i) = -1 THEN LET p(i) = 12
400 IF d(i) = 1 THEN LET a$(i) = a$(i,25 TO 26) + a$(i,1 TO 24): LET b$(i) = b$(i,25 TO 26) + b$(i,1 TO 24)
410 IF d(i) = -1 THEN LET a$(i) = a$(i,3 TO 26) + a$(i,1 TO 2): LET b$(i) = b$(i,3 TO 26) + b$(i,1 TO 2)
420 GO SUB 1200: IF y = 2 * i - 1 THEN GO SUB 3000
430 NEXT i
440 GO SUB 2000: LET steps = steps + 1
450 IF hit = 1 THEN LET e$ = "The lane caught you.": GO TO 4000
460 IF x = 6 AND y = 0 THEN LET e$ = "Across! A well-timed journey.": GO TO 4000
470 LET dx = 0: LET dy = 0: GO TO 200
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,11; INK 5; "QUICKSTEP"; AT 2,14; INK 4; "EXIT"
1020 PLOT INK 1;22,23: DRAW INK 1;211,0: DRAW INK 1;0,128: DRAW INK 1;-211,0: DRAW INK 1;0,-128
1030 FOR j = 0 TO 6: IF j / 2 <> INT (j / 2) THEN GO TO 1060
1040 PRINT AT 4+2*j,3; PAPER 1; INK 5; s$; AT 5+2*j,3; s$
1060 NEXT j
1070 PRINT AT 4,15; PAPER 4; INK 7; "  "; AT 5,15; "  "
1080 FOR i = 1 TO 3: GO SUB 1200: LET z$ = ">": IF d(i) = -1 THEN LET z$ = "<"
1081 PRINT AT row,1; PAPER 0; INK ink; z$; AT row,30; z$
1082 NEXT i
1090 PRINT AT 19,2; PAPER 0; INK 7; "I up  J left  K down  L right"
1100 PRINT AT 20,2; INK 5; "Rest on the blue strips."
1110 PRINT AT 21,2; INK 7; "R retry              Q quit";
1120 RETURN
1200 LET row = 2 + 4 * i: LET ink = 6: IF i = 2 THEN LET ink = 5
1210 PRINT AT row,3; PAPER 0; INK ink; a$(i); AT row+1,3; b$(i)
1240 RETURN
2000 LET hit = 0: IF ny / 2 = INT (ny / 2) THEN RETURN
2010 LET lane = (ny + 1) / 2: LET delta = nx - p(lane): IF delta < 0 THEN LET delta = delta + 13
2020 IF delta < 2 OR (delta >= 7 AND delta < 9) THEN LET hit = 1
2030 RETURN
3000 LET paper = 0: IF y / 2 = INT (y / 2) THEN LET paper = 1
3010 IF y = 0 AND x = 6 THEN LET paper = 4
3020 PRINT AT 4+2*y,3+2*x; PAPER paper; INK 7; h$; AT 5+2*y,3+2*x; f$
3030 RETURN
3100 IF y / 2 <> INT (y / 2) THEN PRINT AT 4+2*y,3+2*x; PAPER 0; "  "; AT 5+2*y,3+2*x; "  ": RETURN
3110 PRINT AT 4+2*y,3+2*x; PAPER 1; INK 5; g$; AT 5+2*y,3+2*x; g$: RETURN
4000 PRINT AT 1,1; PAPER 0; INK 6; e$
4010 PRINT AT 20,2; PAPER 0; INK 7; "R plays again. Q quits.    "
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
5000 BORDER 0: PAPER 0: INK 7: CLS
5010 PRINT AT 3,11; INK 5; "QUICKSTEP"
5020 PRINT AT 6,3; "Three lanes. One way across."
5030 PRINT AT 8,3; "I up   J left   K down"
5040 PRINT AT 9,3; "L right"
5050 PRINT AT 11,3; "Step into a gap, then watch."
5060 PRINT AT 13,3; "Blue strips are safe to wait."
5070 PRINT AT 15,3; "Reach the green exit at top."
5080 PRINT AT 17,3; "R retries. Q quits."
5090 PRINT AT 20,11; INK 6; "S starts."
5100 LET k$ = INKEY$
5110 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5120 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5100
5130 RETURN
7000 RESTORE 7200: FOR j = 0 TO 103: READ n: POKE USR "a" + j,n: NEXT j
7010 LET h$ = CHR$ 152 + CHR$ 153: LET f$ = CHR$ 154 + CHR$ 155
7020 LET g$ = CHR$ 156 + CHR$ 156: LET s$ = "": FOR j = 1 TO 13: LET s$ = s$ + g$: NEXT j: RETURN
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
