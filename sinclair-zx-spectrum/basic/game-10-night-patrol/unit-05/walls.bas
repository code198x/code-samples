10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM m$(8, 16)
30 FOR i = 1 TO 8
40 READ m$(i)
50 NEXT i
60 REM draw map
70 FOR r = 1 TO 8
80 FOR c = 1 TO 16
90 IF m$(r)(c TO c) = "#" THEN PRINT AT r + 2, c + 2; INK 1; CHR$ 143
100 NEXT c
110 NEXT r
120 LET r = 6: LET c = 2
130 REM game loop
140 PRINT AT r + 2, c + 2; INK 7; BRIGHT 1; "@"
150 LET k$ = INKEY$
160 IF k$ = "" THEN GO TO 150
170 LET u = r: LET z = c
180 IF k$ = "q" THEN LET u = r - 1
190 IF k$ = "a" THEN LET u = r + 1
200 IF k$ = "o" THEN LET z = c - 1
210 IF k$ = "p" THEN LET z = c + 1
220 IF u < 1 OR u > 8 OR z < 1 OR z > 16 THEN GO TO 140
230 IF m$(u)(z TO z) = "#" THEN GO TO 140
240 PRINT AT r + 2, c + 2; " "
250 LET r = u: LET c = z
260 GO TO 140
500 DATA "################"
510 DATA "#              #"
520 DATA "#  ## ####  #  #"
530 DATA "#     #     #  #"
540 DATA "#  ####  #     #"
550 DATA "#        #  #  #"
560 DATA "#   ##      #  #"
570 DATA "################"
