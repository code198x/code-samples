110 LET r = 8: LET c = 9: LET dr = 0: LET dc = 1: LET steps = 0
130 GO SUB 1000
140 LET tick = PEEK 23672
150 LET k$ = INKEY$
160 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
170 IF k$ = "r" OR k$ = "R" THEN GO TO 110
240 LET elapsed = PEEK 23672 - tick
250 IF elapsed < 0 THEN LET elapsed = elapsed + 256
260 IF elapsed < 18 THEN GO TO 150
270 LET tick = PEEK 23672
280 LET nr = r + dr: LET nx = c + dc
290 IF nr < 1 OR nr > 16 OR nx < 1 OR nx > 24 THEN LET e$ = "Mind the wall!": GO TO 4000
400 PRINT AT r+3,c+3; " ": LET r = nr: LET c = nx: LET steps = steps + 1
410 GO SUB 3000
460 GO TO 150
1070 PRINT AT 21,7; INK 5; "R retry     Q quit";
4000 PRINT AT 2,0; "                                "; AT 2,2; INK 6; e$
4010 PRINT AT 21,1; INK 7; "R for another go     Q to quit ";
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 110
4060 GO TO 4030
