10 CLS
20 LET r = 10
30 LET c = 15
40 LET n = 0
50 REM place 5 coins
60 FOR i = 1 TO 5
70 LET y = INT (RND * 20) + 1
80 LET x = INT (RND * 32)
90 INK 6: PRINT AT y, x; "*": INK 0
100 NEXT i
110 PRINT AT 0, 0; "Coins: "; n
120 REM game loop
130 PRINT AT r, c; INK 4; "O"
140 LET k$ = INKEY$
150 IF k$ = "" THEN GO TO 140
160 PRINT AT r, c; " "
170 IF k$ = "q" AND r > 1 THEN LET r = r - 1
180 IF k$ = "a" AND r < 20 THEN LET r = r + 1
190 IF k$ = "o" AND c > 0 THEN LET c = c - 1
200 IF k$ = "p" AND c < 31 THEN LET c = c + 1
210 REM check for coin
220 IF ATTR (r, c) = 49 THEN LET n = n + 1: BEEP 0.05, 20: PRINT AT 0, 7; n
230 PRINT AT r, c; INK 4; "O"
240 GO TO 140
