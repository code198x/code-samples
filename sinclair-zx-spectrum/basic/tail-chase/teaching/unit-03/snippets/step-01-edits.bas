140 LET nd = dr: LET nc = dc: LET turn = 0: LET tick = PEEK 23672
180 IF turn = 1 THEN GO TO 240
190 IF (k$ = "i" OR k$ = "I") AND dr = 0 THEN LET nd = -1: LET nc = 0: LET turn = 1
200 IF (k$ = "k" OR k$ = "K") AND dr = 0 THEN LET nd = 1: LET nc = 0: LET turn = 1
210 IF (k$ = "j" OR k$ = "J") AND dc = 0 THEN LET nd = 0: LET nc = -1: LET turn = 1
220 IF (k$ = "l" OR k$ = "L") AND dc = 0 THEN LET nd = 0: LET nc = 1: LET turn = 1
270 LET tick = PEEK 23672: LET dr = nd: LET dc = nc
460 LET nd = dr: LET nc = dc: LET turn = 0: GO TO 150
1070 PRINT AT 21,1; INK 5; "I J K L steer  R retry  Q quit";
3010 IF dr = -1 THEN LET z = 145
3020 IF dr = 1 THEN LET z = 147
3030 IF dc = -1 THEN LET z = 148
7000 RESTORE 7200: FOR j = 0 TO 39: READ v: POKE USR "a" + j,v: NEXT j: RETURN
7210 DATA 60,126,90,90,126,126,60,24
7230 DATA 24,60,126,126,90,90,126,60
7240 DATA 60,126,63,51,51,63,126,60
