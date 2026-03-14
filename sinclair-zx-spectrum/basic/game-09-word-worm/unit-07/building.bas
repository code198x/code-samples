10 CLS
20 DIM w$(10, 5)
30 DIM l(10)
40 FOR i = 1 TO 10
50 READ l(i), w$(i)
60 NEXT i
70 LET n = INT (RND * 10) + 1
80 LET a$ = w$(n)(1 TO l(n))
90 LET r = 2
100 LET t = 0: LET s = 25
110 LET p = 1: LET b$ = ""
120 PRINT AT 0, 0; "Type: "; a$
130 REM game loop
140 LET t = t + 1
150 IF t < s THEN GO TO 200
160 PRINT AT r, 12; "       "
170 LET r = r + 1
180 LET t = 0
190 IF r >= 20 THEN PRINT AT 20, 8; "Missed!": STOP
200 PRINT AT r, 12; a$
210 LET k$ = INKEY$
220 IF k$ = "" THEN GO TO 140
230 IF k$ <> a$(p TO p) THEN PRINT AT 20, 0; INK 2; "Wrong!  ": GO TO 140
240 LET b$ = b$ + k$
250 LET p = p + 1
260 PRINT AT 20, 0; INK 4; b$; "       "
270 IF p > LEN a$ THEN PRINT AT 21, 0; INK 4; "Complete!": STOP
280 GO TO 140
500 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
510 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
