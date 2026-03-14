10 CLS
20 DIM w$(30, 5)
30 DIM l(30)
40 FOR i = 1 TO 30
50 READ l(i), w$(i)
60 NEXT i
70 LET e = 0: LET m = 0: LET v = 1: LET c = 0
80 LET s = 25: LET t = 0: LET j = 0
90 GO SUB 900
100 GO SUB 800
110 REM === game loop ===
120 LET t = t + 1
130 IF t < s THEN GO TO 170
140 GO SUB 600
150 IF r >= 19 THEN GO SUB 700: GO TO 100
160 LET t = 0
170 PRINT AT r, 12; INK 6; a$
180 LET k$ = INKEY$
190 IF k$ = "" THEN GO TO 120
200 GO SUB 500
210 GO TO 120
500 REM === handle input ===
510 IF k$ <> a$(p TO p) THEN RETURN
520 LET b$ = b$ + k$
530 LET p = p + 1
540 PRINT AT 21, 0; INK 4; b$; "       "
550 IF p <= LEN a$ THEN RETURN
560 PRINT AT r, 12; "       "
570 LET e = e + 1: LET c = c + 1: LET j = j + 1
580 BEEP 0.1, 15
582 IF j >= 5 THEN LET e = e + 5: PRINT AT 10, 9; INK 3; BRIGHT 1; "STREAK! +5": BEEP 0.1, 20: BEEP 0.1, 24: PAUSE 15: PRINT AT 10, 9; "          ": LET j = 0
584 IF c >= 10 THEN LET v = v + 1: LET c = 0: LET s = s - 5: IF s < 5 THEN LET s = 5
586 GO SUB 900
588 GO SUB 800
590 RETURN
600 REM === move word ===
610 PRINT AT r, 12; "       "
620 LET r = r + 1
630 RETURN
700 REM === word missed ===
710 PRINT AT r, 12; INK 2; a$
720 LET m = m + 1: LET j = 0
730 BEEP 0.2, -5
740 PAUSE 15
750 PRINT AT r, 12; "       "
760 PRINT AT 21, 0; "               "
770 IF m >= 3 THEN GO TO 950
780 GO SUB 900
790 RETURN
800 REM === draw HUD ===
810 PRINT AT 0, 0; INK 7; "Score:"; e; " Lv:"; v; " Miss:"; m; "/3 Str:"; j; "  "
820 PRINT AT 20, 0; "Type: "; INK 5; a$; "       "
830 RETURN
900 REM === pick word ===
910 IF v <= 2 THEN LET n = INT (RND * 20) + 1
920 IF v >= 3 THEN LET n = INT (RND * 10) + 21
930 LET a$ = w$(n)(1 TO l(n))
940 LET r = 2: LET p = 1: LET b$ = "": LET t = 0
945 RETURN
950 REM game over
960 CLS
970 PRINT AT 8, 9; INK 2; "GAME OVER"
980 PRINT AT 10, 8; "Score: "; e
990 PRINT AT 11, 8; "Level: "; v
992 PRINT AT 12, 8; "Best streak: "; j
995 STOP
1000 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
1010 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
1020 DATA 3,"jam",3,"big",3,"top",3,"hop",3,"zip"
1030 DATA 3,"van",3,"wet",3,"map",3,"dot",3,"log"
1040 DATA 4,"bird",4,"fish",4,"lamp",4,"tree",4,"star"
1050 DATA 4,"ball",4,"frog",4,"drum",4,"bell",4,"corn"
