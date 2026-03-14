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
130 REM guard position
140 LET g = 3: LET h = 10
150 PRINT AT g + 2, h + 2; INK 2; "G"
160 REM game loop
170 PRINT AT r + 2, c + 2; INK 7; BRIGHT 1; "@"
180 LET k$ = INKEY$
190 IF k$ = "" THEN GO TO 180
200 LET u = r: LET z = c
210 IF k$ = "q" THEN LET u = r - 1
220 IF k$ = "a" THEN LET u = r + 1
230 IF k$ = "o" THEN LET z = c - 1
240 IF k$ = "p" THEN LET z = c + 1
250 IF u < 1 OR u > 8 OR z < 1 OR z > 16 THEN GO TO 170
260 IF m$(u)(z TO z) = "#" THEN GO TO 170
270 PRINT AT r + 2, c + 2; " "
280 LET r = u: LET c = z
290 REM check guard contact
300 IF r = g AND c = h THEN GO TO 400
310 GO TO 170
400 REM detected!
410 BEEP 0.1, 20: BEEP 0.1, 15: BEEP 0.2, 20
420 BORDER 2: PAUSE 10: BORDER 0
430 PRINT AT 12, 6; INK 2; BRIGHT 1; "DETECTED!"
440 STOP
500 DATA "################"
510 DATA "#              #"
520 DATA "#  ## ####  #  #"
530 DATA "#     #     #  #"
540 DATA "#  ####  #     #"
550 DATA "#        #  #  #"
560 DATA "#   ##      #  #"
570 DATA "################"
