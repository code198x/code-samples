180 GO SUB 1000: GO SUB 3000: LET dx = 0: LET dy = 0: LET tick = PEEK 23672
280 LET elapsed = PEEK 23672 - tick: IF elapsed < 0 THEN LET elapsed = elapsed + 256
290 IF elapsed < 32 THEN GO TO 200
291 LET k$ = INKEY$
292 LET dx = 0: LET dy = 0
293 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
294 IF k$ = "r" OR k$ = "R" THEN GO TO 100
300 LET tick = PEEK 23672: LET nx = x + dx: LET ny = y + dy
340 IF nx = x AND ny = y THEN GO TO 350
341 GO SUB 3100: LET x = nx: LET y = ny: GO SUB 3000
350 LET t = t - 1
360 IF t > 0 THEN GO TO 440
370 LET t = v: LET p = p + d
470 LET dx = 0: LET dy = 0: GO TO 200
