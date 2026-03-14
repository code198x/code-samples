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
110 LET p = 1
120 PRINT AT 0, 0; "Type: "; a$
130 PRINT AT 21, 0; "Next letter: "; a$(p TO p)
140 REM game loop
150 LET t = t + 1
160 IF t < s THEN GO TO 210
170 PRINT AT r, 12; "       "
180 LET r = r + 1
190 LET t = 0
200 IF r >= 20 THEN PRINT AT 20, 8; "Missed!": STOP
210 PRINT AT r, 12; a$
220 LET k$ = INKEY$
230 IF k$ = "" THEN GO TO 150
240 IF k$ = a$(p TO p) THEN PRINT AT 20, 0; INK 4; "Correct: "; k$; "  ": LET p = p + 1: GO TO 270
250 PRINT AT 20, 0; INK 2; "Wrong: "; k$; "    "
260 GO TO 270
270 IF p > LEN a$ THEN PRINT AT 20, 0; INK 4; "Word complete!    ": STOP
280 PRINT AT 21, 13; a$(p TO p); " "
290 GO TO 150
500 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
510 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
