100 LET x = 48: LET y = 56: LET vx = 0: LET vy = 0: LET h = 2: LET steps = 0
280 IF k$ <> " " THEN GO TO 320
290 LET vx = vx + .2 * a(h): LET vy = vy + .2 * b(h)
300 LET speed = SQR (vx * vx + vy * vy)
310 IF speed > 3 THEN LET vx = 3 * vx / speed: LET vy = 3 * vy / speed
320 LET nx = x + vx: LET ny = y + vy
330 IF nx < 22 OR nx > 233 OR ny < 30 OR ny > 145 THEN GO SUB 3000: LET e$ = "Hull lost. Try a gentler burn.": GO TO 4000
340 LET x = nx: LET y = ny: LET steps = steps + 1
1010 PRINT AT 0,2; INK 5; "DRIFT"; AT 0,19; INK 7; "FREE FLIGHT"
1020 PRINT AT 1,2; "Turn. Burn. Coast. Brake."
1060 PRINT AT 19,2; INK 5; "O/P turn   SPACE thrust"
1070 PRINT AT 20,2; INK 7; "Turn back to slow down."
4000 PRINT AT 1,0; "                                "; AT 1,2; INK 6; e$
4010 PRINT AT 20,2; "R plays again. Q quits.      "
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
