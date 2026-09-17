10 GO SUB 7000
100 LET p = 10: LET d = -1: LET v = 2: LET t = v: DIM a$(30): DIM b$(30)
110 LET x = 7: LET y = 2: LET steps = 0
140 FOR j = 0 TO 2: FOR k = 0 TO 3
150 LET c = 2 * p + 10 * j + k: LET c = c - 30 * INT (c / 30) + 1
160 LET a$(c) = CHR$ (144 + k): LET b$(c) = CHR$ (148 + k)
170 NEXT k: NEXT j
180 GO SUB 1000: GO SUB 3000: LET dx = 0: LET dy = 0: LET tick = PEEK 23672
200 LET k$ = INKEY$
220 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
230 IF k$ = "r" OR k$ = "R" THEN GO TO 100
280 LET elapsed = PEEK 23672 - tick: IF elapsed < 0 THEN LET elapsed = elapsed + 256
290 IF elapsed < 32 THEN GO TO 200
291 LET k$ = INKEY$
292 LET dx = 0: LET dy = 0
293 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
294 IF k$ = "r" OR k$ = "R" THEN GO TO 100
295 IF k$ = "i" OR k$ = "I" THEN LET dy = -1
296 IF k$ = "k" OR k$ = "K" THEN LET dy = 1
297 IF k$ = "j" OR k$ = "J" THEN LET dx = -1
298 IF k$ = "l" OR k$ = "L" THEN LET dx = 1
300 LET tick = PEEK 23672: LET nx = x + dx: LET ny = y + dy
310 IF nx < 0 OR nx > 14 OR ny < 0 OR ny > 2 THEN LET nx = x: LET ny = y
320 GO SUB 2000
330 IF hit = 1 THEN LET e$ = "That gap was not clear.": GO TO 4000
340 IF nx = x AND ny = y THEN GO TO 350
341 GO SUB 3100: LET x = nx: LET y = ny: GO SUB 3000
350 LET t = t - 1
360 IF t > 0 THEN GO TO 440
370 LET t = v: LET p = p + d
380 IF p = 15 THEN LET p = 0
390 IF p = -1 THEN LET p = 14
400 IF d = 1 THEN LET a$ = a$(29 TO 30) + a$(1 TO 28): LET b$ = b$(29 TO 30) + b$(1 TO 28)
410 IF d = -1 THEN LET a$ = a$(3 TO 30) + a$(1 TO 2): LET b$ = b$(3 TO 30) + b$(1 TO 2)
420 GO SUB 1200: IF y = 1 THEN GO SUB 3000
440 GO SUB 2000: LET steps = steps + 1
450 IF hit = 1 THEN LET e$ = "The lane caught you.": GO TO 4000
460 IF x = 7 AND y = 0 THEN LET e$ = "Across! A well-timed journey.": GO TO 4000
470 LET dx = 0: LET dy = 0: GO TO 200
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,1; INK 5; "QUICKSTEP"; AT 0,21; INK 4; "EXIT ABOVE"
1030 FOR j = 0 TO 2 STEP 2
1040 PRINT AT 2+2*j,1; PAPER 1; INK 5; s$; AT 3+2*j,1; s$
1060 NEXT j
1070 PRINT AT 2,15; PAPER 4; INK 7; "  "; AT 3,15; "  "
1080 GO SUB 1200: LET z$ = ">": IF d = -1 THEN LET z$ = "<"
1081 PRINT AT row,0; PAPER 0; INK ink; z$; AT row,31; z$
1090 PRINT AT 20,2; PAPER 0; INK 7; "I up  J left  K down  L right"
1110 PRINT AT 21,2; INK 7; "R retry              Q quit";
1120 RETURN
1200 LET row = 4: LET ink = 6: IF d = -1 THEN LET ink = 5
1210 PRINT AT row,1; PAPER 0; INK ink; a$; AT row+1,1; b$
1240 RETURN
2000 LET hit = 0: IF ny <> 1 THEN RETURN
2015 LET delta = nx - p: LET delta = delta - 5 * INT (delta / 5)
2020 IF delta < 2 THEN LET hit = 1
2030 RETURN
3000 LET paper = 0: IF y <> 1 THEN LET paper = 1
3010 IF y = 0 AND x = 7 THEN LET paper = 4
3020 PRINT AT 2+2*y,1+2*x; PAPER paper; INK 7; h$; AT 3+2*y,1+2*x; f$
3030 RETURN
3100 IF y = 1 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN
3110 PRINT AT 2+2*y,1+2*x; PAPER 1; INK 5; g$; AT 3+2*y,1+2*x; g$: RETURN
4000 PRINT AT 1,1; PAPER 0; INK 6; e$
4010 PRINT AT 20,2; PAPER 0; INK 7; "R plays again. Q quits.    "
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
7000 RESTORE 7200: FOR j = 0 TO 103: READ n: POKE USR "a" + j,n: NEXT j
7010 LET h$ = CHR$ 152 + CHR$ 153: LET f$ = CHR$ 154 + CHR$ 155
7020 LET g$ = CHR$ 156 + CHR$ 156: LET s$ = "": FOR j = 1 TO 15: LET s$ = s$ + g$: NEXT j: RETURN
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
