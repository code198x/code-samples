10 GO SUB 7000: GO SUB 5000
100 LET x = 48: LET y = 56: LET vx = 0: LET vy = 0: LET h = 2: LET steps = 0
110 GO SUB 1000: GO SUB 3000
200 LET k$ = INKEY$
210 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
220 IF k$ = "r" OR k$ = "R" THEN GO TO 100
230 GO SUB 3000
240 IF k$ = "o" OR k$ = "O" THEN LET h = h + 1
250 IF k$ = "p" OR k$ = "P" THEN LET h = h - 1
260 IF h = 9 THEN LET h = 1
270 IF h = 0 THEN LET h = 8
280 IF k$ <> " " THEN GO TO 320
290 LET vx = vx + .2 * a(h): LET vy = vy + .2 * b(h)
300 LET speed = SQR (vx * vx + vy * vy)
310 IF speed > 3 THEN LET vx = 3 * vx / speed: LET vy = 3 * vy / speed
320 LET nx = x + vx: LET ny = y + vy
330 IF nx < 22 OR nx > 233 OR ny < 30 OR ny > 145 THEN GO SUB 3000: LET e$ = "Hull lost. Try a gentler burn.": GO TO 4000
340 LET x = nx: LET y = ny: LET steps = steps + 1
350 GO SUB 3000
360 IF x >= 190 AND x <= 210 AND y >= 94 AND y <= 114 AND vx * vx + vy * vy <= .16 THEN LET e$ = "Docked. A soft arrival!": GO TO 4000
370 GO TO 200
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,2; INK 5; "DRIFT"; AT 0,19; INK 7; "SOFT DOCK"
1020 PRINT AT 1,2; "Turn. Burn. Coast. Brake."
1030 PLOT INK 1;15,24: DRAW INK 1;0,128: DRAW INK 1;225,0: DRAW INK 1;0,-128: DRAW INK 1;-225,0
1040 PLOT INK 7;184,88: DRAW INK 7;32,0: DRAW INK 7;0,32: DRAW INK 7;-32,0: DRAW INK 7;0,-32
1050 PRINT AT 5,23; INK 5; "DOCK"
1060 PRINT AT 19,2; INK 5; "O/P turn   SPACE thrust"
1070 PRINT AT 20,2; INK 7; "Turn back to slow down."
1080 PRINT AT 21,2; INK 5; "R retry              Q quit";
1090 RETURN
3000 LET px = INT (x + .5): LET py = INT (y + .5)
3010 PLOT INK 7; OVER 1;px + c(h),py + d(h)
3020 DRAW INK 7; OVER 1;e(h) - c(h),f(h) - d(h)
3030 DRAW INK 7; OVER 1;g(h) - e(h),j(h) - f(h)
3040 DRAW INK 7; OVER 1;c(h) - g(h),d(h) - j(h): RETURN
4000 PRINT AT 1,0; "                                "; AT 1,2; INK 6; e$
4010 PRINT AT 20,2; "R plays again. Q quits.      "
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
5000 BORDER 0: PAPER 0: INK 7: CLS
5010 PRINT AT 3,13; INK 5; "DRIFT"
5020 PRINT AT 6,3; "Space has no brakes."
5030 PRINT AT 8,3; "O/P turn. SPACE fires thrust."
5040 PRINT AT 10,3; "Release thrust: keep drifting."
5050 PRINT AT 12,3; "Turn back and burn to brake."
5060 PRINT AT 14,3; "Enter the box almost stopped."
5070 PRINT AT 16,3; "Walls end the attempt."
5080 PRINT AT 18,3; "R retries. Q quits."
5090 PRINT AT 20,11; INK 6; "S starts."
5100 LET k$ = INKEY$
5110 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5120 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5100
5130 RETURN
7000 DIM a(8): DIM b(8): DIM c(8): DIM d(8): DIM e(8): DIM f(8): DIM g(8): DIM j(8)
7010 FOR i = 1 TO 8: LET angle = (i - 1) * PI / 4
7020 LET a(i) = COS angle: LET b(i) = SIN angle
7030 LET c(i) = INT (5 * a(i) + .5): LET d(i) = INT (5 * b(i) + .5)
7040 LET e(i) = INT (-3 * a(i) - 3 * b(i) + .5): LET f(i) = INT (-3 * b(i) + 3 * a(i) + .5)
7050 LET g(i) = INT (-3 * a(i) + 3 * b(i) + .5): LET j(i) = INT (-3 * b(i) - 3 * a(i) + .5)
7060 NEXT i: RETURN
9000 PAPER 0: INK 7: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
