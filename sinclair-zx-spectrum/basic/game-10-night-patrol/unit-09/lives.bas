10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM m$(8, 16)
30 FOR i = 1 TO 8
40 READ m$(i)
50 NEXT i
60 LET r = 6: LET c = 2: LET v = 3: LET e = 0
70 LET g = 3: LET h = 10
80 LET d$ = "WWWWWWEEEEEE"
90 LET q = 1: LET t = 0: LET s = 15: LET f$ = "W"
100 GO SUB 800
110 GO SUB 850
120 REM game loop
130 PRINT AT r + 2, c + 2; INK 7; BRIGHT 1; "@"
140 PRINT AT g + 2, h + 2; INK 2; "G"
150 GO SUB 700
160 LET t = t + 1
170 LET k$ = INKEY$
180 IF k$ = "" THEN GO TO 220
190 LET u = r: LET z = c
191 IF k$ = "q" THEN LET u = r - 1
192 IF k$ = "a" THEN LET u = r + 1
193 IF k$ = "o" THEN LET z = c - 1
194 IF k$ = "p" THEN LET z = c + 1
195 IF u < 1 OR u > 8 OR z < 1 OR z > 16 THEN GO TO 220
196 IF m$(u)(z TO z) = "#" THEN GO TO 220
197 PRINT AT r + 2, c + 2; " "
198 LET r = u: LET c = z
220 IF t < s THEN GO TO 350
230 LET t = 0
235 GO SUB 760
240 PRINT AT g + 2, h + 2; " "
250 LET f$ = d$(q TO q)
260 IF f$ = "N" THEN LET g = g - 1
270 IF f$ = "S" THEN LET g = g + 1
280 IF f$ = "W" THEN LET h = h - 1
290 IF f$ = "E" THEN LET h = h + 1
300 LET q = q + 1: IF q > LEN d$ THEN LET q = 1
350 IF r = g AND c = h THEN GO TO 400
360 GO TO 130
400 REM detected
410 LET v = v - 1
420 BEEP 0.1, 20: BEEP 0.1, 15
430 BORDER 2: PAUSE 10: BORDER 0
440 IF v = 0 THEN GO TO 500
450 GO SUB 760
460 PRINT AT g + 2, h + 2; " "
470 PRINT AT r + 2, c + 2; " "
480 LET r = 6: LET c = 2: LET g = 3: LET h = 10
490 LET q = 1: LET f$ = "W": LET t = 0
495 GO SUB 850
496 GO TO 130
500 REM game over
510 CLS
520 PRINT AT 8, 9; INK 2; "GAME OVER"
530 PRINT AT 10, 8; "Score: "; e
540 BEEP 0.15, 0: BEEP 0.15, -3: BEEP 0.2, -7
550 STOP
700 REM === draw sightline ===
710 LET a = g: LET b = h
720 IF f$ = "N" THEN LET a = a - 1
722 IF f$ = "S" THEN LET a = a + 1
724 IF f$ = "W" THEN LET b = b - 1
726 IF f$ = "E" THEN LET b = b + 1
728 IF a < 1 OR a > 8 OR b < 1 OR b > 16 THEN RETURN
730 IF m$(a)(b TO b) = "#" THEN RETURN
732 IF a = r AND b = c THEN GO TO 400
734 PRINT AT a + 2, b + 2; INK 6; "."
736 GO TO 720
760 REM === clear sightline ===
770 LET a = g: LET b = h
772 IF f$ = "N" THEN LET a = a - 1
774 IF f$ = "S" THEN LET a = a + 1
776 IF f$ = "W" THEN LET b = b - 1
778 IF f$ = "E" THEN LET b = b + 1
780 IF a < 1 OR a > 8 OR b < 1 OR b > 16 THEN RETURN
782 IF m$(a)(b TO b) = "#" THEN RETURN
784 PRINT AT a + 2, b + 2; " "
786 GO TO 772
800 REM === draw map ===
810 FOR y = 1 TO 8
820 FOR x = 1 TO 16
830 IF m$(y)(x TO x) = "#" THEN PRINT AT y + 2, x + 2; INK 1; CHR$ 143
840 NEXT x
850 NEXT y
855 RETURN
856 REM === draw HUD ===
858 PRINT AT 0, 0; INK 7; "Lives:"; v; " Score:"; e; "  "
860 RETURN
900 DATA "################"
910 DATA "#              #"
920 DATA "#  ## ####  #  #"
930 DATA "#     #     #  #"
940 DATA "#  ####  #     #"
950 DATA "#        #  #  #"
960 DATA "#   ##      #  #"
970 DATA "################"
