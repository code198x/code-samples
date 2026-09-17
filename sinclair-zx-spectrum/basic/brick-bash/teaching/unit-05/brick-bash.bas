10 GO SUB 7000
100 LET alive = 1: LET left = 1: LET p = 14: LET x = 127: LET y = 40
110 LET dx = 4: LET dy = 4: LET served = 0: LET steps = 0
130 GO SUB 1000: GO SUB 3000
200 LET k$ = INKEY$
210 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
220 IF k$ = "r" OR k$ = "R" THEN GO TO 100
230 LET oldp = p
240 IF k$ = "o" OR k$ = "O" THEN LET p = p - 1
250 IF k$ = "p" OR k$ = "P" THEN LET p = p + 1
260 IF p < 2 THEN LET p = 2
270 IF p > 26 THEN LET p = 26
280 IF p <> oldp THEN PRINT AT 18,oldp; "    "; AT 18,p; INK 7; p$
290 IF served = 1 THEN GO TO 350
300 IF k$ = " " THEN LET served = 1: PRINT AT 1,2; "Clear every brick.": GO TO 350
310 IF p = oldp THEN GO TO 200
320 GO SUB 3000: LET x = 8 * p + 15: GO SUB 3000: GO TO 200
350 LET nx = x + dx: LET ny = y + dy
360 IF nx < 16 THEN LET nx = 32 - nx: LET dx = ABS dx
370 IF nx > 238 THEN LET nx = 476 - nx: LET dx = -ABS dx
380 IF ny > 149 THEN LET ny = 298 - ny: LET dy = -ABS dy
390 IF ny >= 32 THEN GO TO 440
400 IF nx + 1 < 8 * p OR nx > 8 * p + 31 THEN LET e$ = "Missed! R for another go.": GO TO 4000
410 LET ny = 64 - ny: LET dy = 4
440 LET tx = nx: LET ty = y: GO SUB 2000
450 IF hit = 1 THEN LET dx = -dx: LET nx = x: GO SUB 2500
460 LET tx = nx: LET ty = ny: GO SUB 2000
470 IF hit = 1 THEN LET dy = -dy: LET ny = y: GO SUB 2500
480 IF left = 0 THEN LET e$ = "Brick cleared! Nicely done.": GO TO 4000
490 GO SUB 3000
500 LET x = nx: LET y = ny: LET steps = steps + 1
510 GO SUB 3000: GO TO 200
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,2; INK 5; "BRICK BASH"; AT 0,21; INK 7; "BRICKS 1"
1020 PRINT AT 1,2; "SPACE serves. O/P move."
1030 PLOT INK 1;15,16: DRAW INK 1;0,136: DRAW INK 1;225,0: DRAW INK 1;0,-136
1040 PRINT AT 8,24; INK 5; b$
1080 PRINT AT 18,p; INK 7; p$
1090 PRINT AT 21,2; INK 5; "O/P move  R retry  Q quit";
1100 RETURN
2000 LET hit = 0
2010 IF alive = 0 THEN RETURN
2020 IF tx + 1 < 192 OR tx > 215 OR ty + 1 < 104 OR ty > 111 THEN RETURN
2030 LET hit = 1: RETURN
2500 LET alive = 0: LET left = 0
2510 PRINT AT 8,24; "   "; AT 0,28; INK 7; left; " "
2520 RETURN
3000 PLOT INK 7; OVER 1;x,y: DRAW INK 7; OVER 1;1,0: DRAW INK 7; OVER 1;0,1: DRAW INK 7; OVER 1;-1,0: RETURN
4000 PRINT AT 1,0; "                                "; AT 1,2; INK 6; e$
4010 PRINT AT 21,2; INK 7; "R plays again       Q quits   ";
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
7000 RESTORE 7200: FOR j = 0 TO 47: READ v: POKE USR "a" + j,v: NEXT j
7010 LET b$ = CHR$ 144 + CHR$ 145 + CHR$ 146
7020 LET p$ = CHR$ 147 + CHR$ 148 + CHR$ 148 + CHR$ 149: RETURN
7200 DATA 127,255,255,255,255,255,255,127
7210 DATA 255,255,255,255,255,255,255,255
7220 DATA 254,255,255,255,255,255,255,254
7230 DATA 63,127,127,63,0,0,0,0
7240 DATA 255,255,255,255,0,0,0,0
7250 DATA 252,254,254,252,0,0,0,0
9000 PAPER 0: INK 7: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
