10 CLS
20 DIM w$(20, 5)
30 DIM l(20)
40 FOR i = 1 TO 20
50 READ l(i), w$(i)
60 NEXT i
70 LET e = 0: LET m = 0: LET v = 1
80 REM pick a word
90 LET n = INT (RND * 20) + 1
100 LET a$ = w$(n)(1 TO l(n))
110 LET r = 2
120 LET t = 0: LET s = 25
130 LET p = 1: LET b$ = ""
140 GO SUB 700
150 PRINT AT 20, 0; "Type: "; INK 5; a$; "         "
160 REM game loop
170 LET t = t + 1
180 IF t < s THEN GO TO 230
190 PRINT AT r, 12; "       "
200 LET r = r + 1
210 LET t = 0
220 IF r >= 20 THEN GO TO 400
230 PRINT AT r, 12; INK 6; a$
240 LET k$ = INKEY$
250 IF k$ = "" THEN GO TO 170
260 IF k$ <> a$(p TO p) THEN GO TO 170
270 LET b$ = b$ + k$
280 LET p = p + 1
290 PRINT AT 21, 0; INK 4; b$; "       "
300 IF p <= LEN a$ THEN GO TO 170
310 REM word complete
320 PRINT AT r, 12; "       "
330 LET e = e + 1
340 BEEP 0.1, 15
350 PRINT AT 21, 0; "               "
360 GO TO 90
400 REM word missed
410 PRINT AT r - 1, 12; INK 2; a$
420 LET m = m + 1
430 BEEP 0.2, -5
440 PAUSE 20
450 PRINT AT r - 1, 12; "       "
460 PRINT AT 21, 0; "               "
470 IF m >= 3 THEN GO TO 500
480 GO TO 90
500 REM game over
510 CLS
520 PRINT AT 8, 9; INK 2; "GAME OVER"
530 PRINT AT 10, 8; "Score: "; e
540 PRINT AT 11, 8; "Level: "; v
550 STOP
700 REM === draw HUD ===
710 PRINT AT 0, 0; INK 7; "Score:"; e; " Level:"; v; " Misses:"; m; "/3  "
720 RETURN
800 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
810 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
820 DATA 3,"jam",3,"big",3,"top",3,"hop",3,"zip"
830 DATA 3,"van",3,"wet",3,"map",3,"dot",3,"log"
