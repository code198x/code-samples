5 REM === CIRCLES ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 REM CIRCLE x, y, radius draws a circle.
25 REM We will use radius 3 for game nodes.
30 CIRCLE 128, 88, 3
40 PRINT AT 0, 0; "One circle at centre, radius 3"
50 PAUSE 50
60 CLS
70 REM A row of 5 circles
80 FOR i = 1 TO 5
90 LET px = 40 + (i - 1) * 45
100 CIRCLE px, 88, 3
110 NEXT i
120 PRINT AT 0, 0; "A row of 5 circles"
130 PAUSE 100
140 CLS
150 REM A 3x3 grid of circles
160 FOR r = 1 TO 3
170 FOR c = 1 TO 3
180 LET px = 64 + (c - 1) * 64
190 LET py = 44 + (r - 1) * 48
200 CIRCLE px, py, 3
210 NEXT c
220 NEXT r
230 PRINT AT 0, 0; "A 3x3 grid of circles"
240 STOP
