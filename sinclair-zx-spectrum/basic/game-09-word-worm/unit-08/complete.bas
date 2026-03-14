10 CLS
20 DIM w$(20, 5)
30 DIM l(20)
40 FOR i = 1 TO 20
50 READ l(i), w$(i)
60 NEXT i
70 LET e = 0
80 REM pick a word
90 LET n = INT (RND * 20) + 1
100 LET a$ = w$(n)(1 TO l(n))
110 LET r = 2
120 LET t = 0: LET s = 25
130 LET p = 1: LET b$ = ""
140 PRINT AT 0, 0; "Score: "; e; "  Type: "; a$; "     "
150 REM game loop
160 LET t = t + 1
170 IF t < s THEN GO TO 220
180 PRINT AT r, 12; "       "
190 LET r = r + 1
200 LET t = 0
210 IF r >= 20 THEN PRINT AT r - 1, 12; "       ": PRINT AT 20, 6; INK 2; "Missed! Next word...": PAUSE 30: PRINT AT 20, 0; "                            ": GO TO 90
220 PRINT AT r, 12; a$
230 LET k$ = INKEY$
240 IF k$ = "" THEN GO TO 160
250 IF k$ <> a$(p TO p) THEN GO TO 160
260 LET b$ = b$ + k$
270 LET p = p + 1
280 PRINT AT 20, 0; INK 4; b$; "       "
290 IF p <= LEN a$ THEN GO TO 160
300 REM word complete
310 PRINT AT r, 12; "       "
320 LET e = e + 1
330 BEEP 0.1, 15
340 PRINT AT 20, 0; "                            "
350 GO TO 90
500 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
510 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
520 DATA 3,"jam",3,"big",3,"top",3,"hop",3,"zip"
530 DATA 3,"van",3,"wet",3,"map",3,"dot",3,"log"
