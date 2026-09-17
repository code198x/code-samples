10 GO TO 100
100 LET x = 127: LET y = 40
110 LET dx = 4: LET dy = 4: LET steps = 0
130 GO SUB 1000: GO SUB 3000
200 LET k$ = INKEY$
210 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
220 IF k$ = "r" OR k$ = "R" THEN GO TO 100
350 LET nx = x + dx: LET ny = y + dy
360 IF nx < 16 THEN LET nx = 32 - nx: LET dx = ABS dx
370 IF nx > 238 THEN LET nx = 476 - nx: LET dx = -ABS dx
380 IF ny > 149 THEN LET ny = 298 - ny: LET dy = -ABS dy
390 IF ny < 32 THEN LET e$ = "Ball reached the bottom.": GO TO 4000
490 GO SUB 3000
500 LET x = nx: LET y = ny: LET steps = steps + 1
510 GO SUB 3000: GO TO 200
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,2; INK 5; "BRICK BASH"
1020 PRINT AT 1,2; "Watch the ball bounce."
1030 PLOT INK 1;15,16: DRAW INK 1;0,136: DRAW INK 1;225,0: DRAW INK 1;0,-136
1090 PRINT AT 21,2; INK 5; "R retry  Q quit";
1100 RETURN
3000 PLOT INK 7; OVER 1;x,y: DRAW INK 7; OVER 1;1,0: DRAW INK 7; OVER 1;0,1: DRAW INK 7; OVER 1;-1,0: RETURN
4000 PRINT AT 1,0; "                                "; AT 1,2; INK 6; e$
4010 PRINT AT 21,2; INK 7; "R plays again       Q quits   ";
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 100
4060 GO TO 4030
9000 PAPER 0: INK 7: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
