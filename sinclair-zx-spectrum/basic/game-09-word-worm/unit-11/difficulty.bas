10 CLS
20 DIM w$(50, 7)
30 DIM l(50)
40 FOR i = 1 TO 50
50 READ l(i), w$(i)
60 NEXT i
70 LET e = 0: LET m = 0: LET v = 1: LET c = 0
80 LET s = 30
90 REM pick a word for current level
100 IF v <= 2 THEN LET n = INT (RND * 20) + 1
110 IF v = 3 OR v = 4 THEN LET n = INT (RND * 20) + 16
120 IF v >= 5 THEN LET n = INT (RND * 15) + 36
130 LET a$ = w$(n)(1 TO l(n))
140 LET r = 2
150 LET t = 0
160 LET p = 1: LET b$ = ""
170 GO SUB 700
180 PRINT AT 20, 0; "Type: "; INK 5; a$; "         "
190 REM game loop
200 LET t = t + 1
210 IF t < s THEN GO TO 260
220 PRINT AT r, 12; "       "
230 LET r = r + 1
240 LET t = 0
250 IF r >= 20 THEN GO TO 420
260 PRINT AT r, 12; INK 6; a$
270 LET k$ = INKEY$
280 IF k$ = "" THEN GO TO 200
290 IF k$ <> a$(p TO p) THEN GO TO 200
300 LET b$ = b$ + k$
310 LET p = p + 1
320 PRINT AT 21, 0; INK 4; b$; "       "
330 IF p <= LEN a$ THEN GO TO 200
340 REM word complete
350 PRINT AT r, 12; "       "
360 LET e = e + 1: LET c = c + 1
370 BEEP 0.1, 15
380 IF c >= 10 THEN LET v = v + 1: LET c = 0: LET s = s - 5: IF s < 5 THEN LET s = 5
390 PRINT AT 21, 0; "               "
400 GO TO 100
420 REM word missed
430 PRINT AT r - 1, 12; INK 2; a$
440 LET m = m + 1
450 BEEP 0.2, -5
460 PAUSE 20
470 PRINT AT r - 1, 12; "       "
480 PRINT AT 21, 0; "               "
490 IF m >= 3 THEN GO TO 550
500 GO TO 100
550 REM game over
560 CLS
570 PRINT AT 8, 9; INK 2; "GAME OVER"
580 PRINT AT 10, 8; "Score: "; e
590 PRINT AT 11, 8; "Level: "; v
600 STOP
700 REM === draw HUD ===
710 PRINT AT 0, 0; INK 7; "Score:"; e; " Lv:"; v; " Miss:"; m; "/3  "
720 RETURN
800 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
810 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
820 DATA 3,"jam",3,"big",3,"top",3,"hop",3,"zip"
830 DATA 3,"van",3,"wet",3,"map",3,"dot",3,"log"
840 DATA 4,"bird",4,"fish",4,"lamp",4,"tree",4,"star"
850 DATA 4,"ball",4,"frog",4,"drum",4,"bell",4,"corn"
860 DATA 4,"wave",4,"king",4,"farm",4,"cave",4,"lake"
870 DATA 5,"house",5,"cloud",5,"river",5,"flame",5,"plant"
880 DATA 5,"storm",5,"brave",5,"ocean",5,"night",5,"tiger"
890 DATA 6,"dragon",6,"garden",5,"magic",5,"swift",5,"queen"
