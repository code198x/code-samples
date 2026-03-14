10 CLS
20 DIM w$(10, 5)
30 DIM l(10)
40 FOR i = 1 TO 10
50 READ l(i), w$(i)
60 NEXT i
70 REM pick a random word
80 LET n = INT (RND * 10) + 1
90 LET a$ = w$(n)(1 TO l(n))
100 LET r = 2
110 REM display and fall
120 PRINT AT r, 10; a$
130 PAUSE 15
140 PRINT AT r, 10; "     "
150 LET r = r + 1
160 IF r < 20 THEN GO TO 120
170 PRINT AT 20, 8; "Word missed!"
500 DATA 3,"cat",3,"dog",3,"run",3,"box",3,"red"
510 DATA 3,"sun",3,"hat",3,"cup",3,"pen",3,"fox"
