10 GO SUB 7000
100 LET p = 14: LET x = 127: LET y = 40
110 LET dx = 4: LET dy = 4: LET served = 0: LET steps = 0
230 LET oldp = p
240 IF k$ = "o" OR k$ = "O" THEN LET p = p - 1
250 IF k$ = "p" OR k$ = "P" THEN LET p = p + 1
260 IF p < 2 THEN LET p = 2
270 IF p > 26 THEN LET p = 26
280 IF p <> oldp THEN PRINT AT 18,oldp; "    "; AT 18,p; INK 7; p$
290 IF served = 1 THEN GO TO 350
300 IF k$ = " " THEN LET served = 1: PRINT AT 1,2; "Watch the ball bounce.": GO TO 350
310 IF p = oldp THEN GO TO 200
320 GO SUB 3000: LET x = 8 * p + 15: GO SUB 3000: GO TO 200
1020 PRINT AT 1,2; "SPACE serves. O/P move."
1080 PRINT AT 18,p; INK 7; p$
1090 PRINT AT 21,2; INK 5; "O/P move  R retry  Q quit";
7000 RESTORE 7230: FOR j = 24 TO 47: READ v: POKE USR "a" + j,v: NEXT j
7020 LET p$ = CHR$ 147 + CHR$ 148 + CHR$ 148 + CHR$ 149: RETURN
7230 DATA 63,127,127,63,0,0,0,0
7240 DATA 255,255,255,255,0,0,0,0
7250 DATA 252,254,254,252,0,0,0,0
