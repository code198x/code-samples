100 LET steps = 0
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
1090 PRINT AT 20,2; PAPER 0; INK 7; "I up  J left  K down  L right"
1110 PRINT AT 21,2; INK 7; "R retry              Q quit";
1120 RETURN
3100 IF y = 1 THEN PRINT AT 2+2*y,1+2*x; PAPER 0; "  "; AT 3+2*y,1+2*x; "  ": RETURN
3110 IF y = 0 AND x = 7 THEN PRINT AT 2,15; PAPER 4; "  "; AT 3,15; "  ": RETURN
3120 PRINT AT 2+2*y,1+2*x; PAPER 1; INK 5; g$; AT 3+2*y,1+2*x; g$: RETURN
9000 PAPER 0: INK 7: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
