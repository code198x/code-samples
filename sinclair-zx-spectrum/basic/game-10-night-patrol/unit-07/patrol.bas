10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM m$(8, 16)
30 FOR i = 1 TO 8
40 READ m$(i)
50 NEXT i
60 GO SUB 800
70 LET r = 6: LET c = 2
80 LET g = 3: LET h = 10
90 LET d$ = "WWWWWWEEEEEE"
100 LET q = 1: LET t = 0: LET s = 15
110 REM game loop
120 PRINT AT r + 2, c + 2; INK 7; BRIGHT 1; "@"
130 PRINT AT g + 2, h + 2; INK 2; "G"
140 LET t = t + 1
150 LET k$ = INKEY$
160 IF k$ = "" THEN GO TO 200
170 LET u = r: LET z = c
180 IF k$ = "q" THEN LET u = r - 1
185 IF k$ = "a" THEN LET u = r + 1
186 IF k$ = "o" THEN LET z = c - 1
187 IF k$ = "p" THEN LET z = c + 1
188 IF u < 1 OR u > 8 OR z < 1 OR z > 16 THEN GO TO 200
189 IF m$(u)(z TO z) = "#" THEN GO TO 200
190 PRINT AT r + 2, c + 2; " "
195 LET r = u: LET c = z
200 REM move guard
210 IF t < s THEN GO TO 300
220 LET t = 0
230 PRINT AT g + 2, h + 2; " "
240 LET f$ = d$(q TO q)
250 IF f$ = "N" THEN LET g = g - 1
260 IF f$ = "S" THEN LET g = g + 1
270 IF f$ = "W" THEN LET h = h - 1
280 IF f$ = "E" THEN LET h = h + 1
290 LET q = q + 1: IF q > LEN d$ THEN LET q = 1
300 IF r = g AND c = h THEN GO TO 400
310 GO TO 120
400 REM detected
410 BEEP 0.1, 20: BEEP 0.1, 15
420 BORDER 2: PAUSE 10: BORDER 0
430 PRINT AT 12, 6; INK 2; "DETECTED!"
440 STOP
800 REM === draw map ===
810 FOR y = 1 TO 8
820 FOR x = 1 TO 16
830 IF m$(y)(x TO x) = "#" THEN PRINT AT y + 2, x + 2; INK 1; CHR$ 143
840 NEXT x
850 NEXT y
860 RETURN
900 DATA "################"
910 DATA "#              #"
920 DATA "#  ## ####  #  #"
930 DATA "#     #     #  #"
940 DATA "#  ####  #     #"
950 DATA "#        #  #  #"
960 DATA "#   ##      #  #"
970 DATA "################"
