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
110 LET f$ = "W"
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
220 REM move guard
230 IF t < s THEN GO TO 350
240 LET t = 0
245 GO SUB 760
250 PRINT AT g + 2, h + 2; " "
260 LET f$ = d$(q TO q)
270 IF f$ = "N" THEN LET g = g - 1
280 IF f$ = "S" THEN LET g = g + 1
290 IF f$ = "W" THEN LET h = h - 1
300 IF f$ = "E" THEN LET h = h + 1
310 LET q = q + 1: IF q > LEN d$ THEN LET q = 1
350 IF r = g AND c = h THEN GO TO 400
360 GO TO 130
400 REM detected
410 BEEP 0.1, 20: BEEP 0.1, 15
420 BORDER 2: PAUSE 10: BORDER 0
430 PRINT AT 12, 6; INK 2; "DETECTED!"
440 STOP
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
860 RETURN
900 DATA "################"
910 DATA "#              #"
920 DATA "#  ## ####  #  #"
930 DATA "#     #     #  #"
940 DATA "#  ####  #     #"
950 DATA "#        #  #  #"
960 DATA "#   ##      #  #"
970 DATA "################"
