10 CLS
20 DIM w$(10, 5)
30 DIM l(10)
40 FOR i = 1 TO 10
50 READ l(i), w$(i)
60 NEXT i
70 LET n = INT (RND * 10) + 1
80 LET a$ = w$(n)(1 TO l(n))
90 LET r = 2
100 LET t = 0
110 LET s = 30
120 PRINT AT 0, 0; "Speed: "; s; " (1=fast 9=slow)"
130 REM game loop
140 LET t = t + 1
150 IF t < s THEN GO TO 200
160 REM move word down
170 PRINT AT r, 10; "      "
180 LET r = r + 1
190 LET t = 0
200 IF r < 20 THEN PRINT AT r, 10; a$
210 IF r >= 20 THEN PRINT AT 20, 8; "Missed!": STOP
220 LET k$ = INKEY$
230 IF k$ >= "1" AND k$ <= "9" THEN LET s = VAL k$ * 5
240 IF k$ >= "1" AND k$ <= "9" THEN PRINT AT 0, 7; s; "  "
250 GO TO 140
500 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
510 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
