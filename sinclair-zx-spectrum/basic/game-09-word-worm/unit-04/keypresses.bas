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
110 PRINT AT 0, 0; "Type: "; a$
120 REM game loop
130 LET t = t + 1
140 IF t < s THEN GO TO 190
150 PRINT AT r, 12; "      "
160 LET r = r + 1
170 LET t = 0
180 IF r >= 20 THEN PRINT AT 20, 8; "Missed!": STOP
190 PRINT AT r, 12; a$
200 LET k$ = INKEY$
210 IF k$ = "" THEN GO TO 130
220 PRINT AT 20, 0; "Key: "; k$; "  "
230 GO TO 130
500 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
510 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
