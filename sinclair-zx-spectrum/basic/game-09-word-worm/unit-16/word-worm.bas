10 REM Word Worm
20 BORDER 0: PAPER 0: INK 7: CLS
30 INK 6: PRINT AT 3, 10; "WORD WORM": INK 7
40 PRINT AT 7, 3; "Type the falling words before"
50 PRINT AT 8, 3; "they reach the bottom!"
60 PRINT AT 11, 3; "Controls:"
70 PRINT AT 12, 5; "Type the letters shown"
80 PRINT AT 13, 5; "Match each letter in order"
90 PRINT AT 16, 3; "Five in a row = streak bonus!"
100 INK 3: PRINT AT 20, 5; "Press any key to start": INK 7
110 IF INKEY$ <> "" THEN GO TO 110
120 IF INKEY$ = "" THEN GO TO 120
130 CLS
140 DIM w$(50, 7)
150 DIM l(50)
160 FOR i = 1 TO 50
170 READ l(i), w$(i)
180 NEXT i
190 LET e = 0: LET m = 0: LET v = 1: LET c = 0
200 LET s = 25: LET t = 0: LET j = 0
210 BORDER v
220 GO SUB 1100
230 GO SUB 1000
240 REM === game loop ===
250 LET t = t + 1
260 IF t < s THEN GO TO 300
270 GO SUB 800
280 IF r >= 19 THEN GO SUB 900: GO TO 230
290 LET t = 0
300 PRINT AT r, 12; INK 6; a$
310 LET k$ = INKEY$
320 IF k$ = "" THEN GO TO 250
330 GO SUB 700
340 GO TO 250
700 REM === handle input ===
710 IF k$ <> a$(p TO p) THEN RETURN
720 LET b$ = b$ + k$
730 LET p = p + 1
740 PRINT AT 21, 0; INK 4; b$; "       "
750 IF p <= LEN a$ THEN RETURN
760 PRINT AT r, 12; "       "
770 LET e = e + 1: LET c = c + 1: LET j = j + 1
780 BEEP 0.05, l(n) * 3 + 5
782 IF j >= 5 THEN LET e = e + 5: PRINT AT 10, 9; INK 3; BRIGHT 1; "STREAK! +5": BEEP 0.05, 20: BEEP 0.05, 24: BEEP 0.1, 28: PAUSE 10: PRINT AT 10, 9; "          ": LET j = 0
784 IF c >= 10 THEN LET v = v + 1: LET c = 0: LET s = s - 5: IF s < 5 THEN LET s = 5: BORDER v
786 GO SUB 1100
788 GO SUB 1000
790 RETURN
800 REM === move word ===
810 PRINT AT r, 12; "       "
820 LET r = r + 1
830 RETURN
900 REM === word missed ===
910 PRINT AT r, 12; INK 2; a$
920 LET m = m + 1: LET j = 0
930 BEEP 0.15, -5: BEEP 0.15, -10
940 PAUSE 15
950 PRINT AT r, 12; "       "
960 PRINT AT 21, 0; "               "
970 IF m >= 3 THEN GO TO 1200
980 GO SUB 1100
990 RETURN
1000 REM === draw HUD ===
1010 PRINT AT 0, 0; INK 7; "Score:"; e; " Lv:"; v; " Miss:"; m; "/3 Str:"; j; "  "
1020 PRINT AT 20, 0; "Type: "; INK 5; a$; "       "
1030 RETURN
1100 REM === pick word ===
1110 IF v <= 2 THEN LET n = INT (RND * 20) + 1
1120 IF v = 3 OR v = 4 THEN LET n = INT (RND * 20) + 16
1130 IF v >= 5 THEN LET n = INT (RND * 15) + 36
1140 LET a$ = w$(n)(1 TO l(n))
1150 LET r = 2: LET p = 1: LET b$ = "": LET t = 0
1160 RETURN
1200 REM === game over ===
1210 CLS
1220 INK 2: PRINT AT 5, 9; "GAME OVER": INK 7
1230 PRINT AT 8, 7; "Score: "; e
1240 PRINT AT 9, 7; "Level: "; v
1250 PRINT AT 10, 7; "Words: "; e
1260 IF e >= 30 THEN PRINT AT 12, 6; "Word worm master!"
1270 IF e >= 15 AND e < 30 THEN PRINT AT 12, 8; "Well done!"
1280 IF e < 15 THEN PRINT AT 12, 5; "Better luck next time!"
1290 BEEP 0.15, 0: BEEP 0.15, -3: BEEP 0.2, -7
1300 REM === end screen ===
1310 INK 3: PRINT AT 20, 5; "Press any key to exit": INK 7
1320 IF INKEY$ <> "" THEN GO TO 1320
1330 IF INKEY$ = "" THEN GO TO 1330
1340 BORDER 7: PAPER 7: INK 0: CLS
1350 STOP
2000 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
2010 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
2020 DATA 3,"jam",3,"big",3,"top",3,"hop",3,"zip"
2030 DATA 3,"van",3,"wet",3,"map",3,"dot",3,"log"
2040 DATA 4,"bird",4,"fish",4,"lamp",4,"tree",4,"star"
2050 DATA 4,"ball",4,"frog",4,"drum",4,"bell",4,"corn"
2060 DATA 4,"wave",4,"king",4,"farm",4,"cave",4,"lake"
2070 DATA 5,"house",5,"cloud",5,"river",5,"flame",5,"plant"
2080 DATA 5,"storm",5,"brave",5,"ocean",5,"night",5,"tiger"
2090 DATA 6,"dragon",6,"garden",5,"magic",5,"swift",5,"queen"
