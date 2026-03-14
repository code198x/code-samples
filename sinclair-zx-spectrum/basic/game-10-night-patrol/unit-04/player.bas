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
170 PRINT AT r + 2, c + 2; " "
180 IF k$ = "q" AND r > 1 THEN LET r = r - 1
190 IF k$ = "a" AND r < 8 THEN LET r = r + 1
200 IF k$ = "o" AND c > 1 THEN LET c = c - 1
210 IF k$ = "p" AND c < 16 THEN LET c = c + 1
220 GO TO 140
500 DATA "################"
510 DATA "#              #"
520 DATA "#  ## ####  #  #"
530 DATA "#     #     #  #"
540 DATA "#  ####  #     #"
550 DATA "#        #  #  #"
560 DATA "#   ##      #  #"
570 DATA "################"
