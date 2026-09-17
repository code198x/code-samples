10 GO SUB 7000
110 LET r = 8: LET c = 9: LET dr = 0: LET dc = 1: LET steps = 0
130 GO SUB 1000
140 LET nd = dr: LET nc = dc: LET turn = 0: LET tick = PEEK 23672
150 LET k$ = INKEY$
160 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
170 IF k$ = "r" OR k$ = "R" THEN GO TO 110
180 IF turn = 1 THEN GO TO 240
190 IF (k$ = "i" OR k$ = "I") AND dr = 0 THEN LET nd = -1: LET nc = 0: LET turn = 1
200 IF (k$ = "k" OR k$ = "K") AND dr = 0 THEN LET nd = 1: LET nc = 0: LET turn = 1
210 IF (k$ = "j" OR k$ = "J") AND dc = 0 THEN LET nd = 0: LET nc = -1: LET turn = 1
220 IF (k$ = "l" OR k$ = "L") AND dc = 0 THEN LET nd = 0: LET nc = 1: LET turn = 1
240 LET elapsed = PEEK 23672 - tick
250 IF elapsed < 0 THEN LET elapsed = elapsed + 256
260 IF elapsed < 18 THEN GO TO 150
270 LET tick = PEEK 23672: LET dr = nd: LET dc = nc
280 LET nr = r + dr: LET nx = c + dc
290 IF nr < 1 OR nr > 16 OR nx < 1 OR nx > 24 THEN LET e$ = "Mind the wall!": GO TO 4000
400 PRINT AT r+3,c+3; " ": LET r = nr: LET c = nx: LET steps = steps + 1
410 GO SUB 3000
460 LET nd = dr: LET nc = dc: LET turn = 0: GO TO 150
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0,11; INK 5; "TAIL CHASE"
1020 PRINT AT 2,5; INK 7; "Keep some room to turn."
1030 FOR x = 3 TO 28: PRINT AT 3,x; INK 1; CHR$ 144; AT 20,x; CHR$ 144: NEXT x
1040 FOR y = 4 TO 19: PRINT AT y,3; INK 1; CHR$ 144; AT y,28; CHR$ 144: NEXT y
1060 GO SUB 3000
1070 PRINT AT 21,1; INK 5; "I J K L steer  R retry  Q quit";
1080 RETURN
3000 LET z = 146
3010 IF dr = -1 THEN LET z = 145
3020 IF dr = 1 THEN LET z = 147
3030 IF dc = -1 THEN LET z = 148
3040 PRINT AT r+3,c+3; INK 7; CHR$ z
3050 RETURN
4000 PRINT AT 2,0; "                                "; AT 2,2; INK 6; e$
4010 PRINT AT 21,1; INK 7; "R for another go     Q to quit ";
4020 IF INKEY$ <> "" THEN GO TO 4020
4030 LET k$ = INKEY$
4040 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
4050 IF k$ = "r" OR k$ = "R" THEN GO TO 110
4060 GO TO 4030
7000 RESTORE 7200: FOR j = 0 TO 39: READ v: POKE USR "a" + j,v: NEXT j: RETURN
7200 DATA 255,129,129,129,255,129,129,255
7210 DATA 60,126,90,90,126,126,60,24
7220 DATA 60,126,252,204,204,252,126,60
7230 DATA 24,60,126,126,90,90,126,60
7240 DATA 60,126,63,51,51,63,126,60
9000 PAPER 0: INK 7: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
