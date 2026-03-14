10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM m$(8, 16)
30 LET v = 3: LET e = 0: LET l = 1
40 RESTORE 900
50 REM load floor
60 FOR i = 1 TO 8
70 READ m$(i)
80 NEXT i
90 READ r, c, g, h, d$, o, p, w, x
100 LET q = 1: LET t = 0: LET s = 20 - l * 3: LET f$ = d$(1 TO 1)
110 LET j = 0
120 CLS
130 GO SUB 800
135 PRINT AT o + 2, p + 2; INK 6; "*"
136 PRINT AT w + 2, x + 2; INK 1; "X"
140 GO SUB 870
150 REM game loop
160 PRINT AT r + 2, c + 2; INK 7; BRIGHT 1; "@"
170 PRINT AT g + 2, h + 2; INK 2; "G"
180 LET t = t + 1
190 LET k$ = INKEY$
200 IF k$ = "" THEN GO TO 240
210 LET u = r: LET i = c
212 IF k$ = "q" THEN LET u = r - 1
214 IF k$ = "a" THEN LET u = r + 1
216 IF k$ = "o" THEN LET i = c - 1
218 IF k$ = "p" THEN LET i = c + 1
220 IF u < 1 OR u > 8 OR i < 1 OR i > 16 THEN GO TO 240
222 IF m$(u)(i TO i) = "#" THEN GO TO 240
224 PRINT AT r + 2, c + 2; " "
226 LET r = u: LET c = i
228 IF r = o AND c = p AND j = 0 THEN LET j = 1: BEEP 0.1, 20: PRINT AT w + 2, x + 2; INK 4; "X": GO SUB 870
230 IF r = w AND c = x AND j = 1 THEN GO TO 550
240 IF t < s THEN GO TO 320
250 LET t = 0
260 PRINT AT g + 2, h + 2; " "
270 LET f$ = d$(q TO q)
280 IF f$ = "N" THEN LET g = g - 1
290 IF f$ = "S" THEN LET g = g + 1
300 IF f$ = "W" THEN LET h = h - 1
310 IF f$ = "E" THEN LET h = h + 1
315 LET q = q + 1: IF q > LEN d$ THEN LET q = 1
320 IF r = g AND c = h THEN GO TO 400
330 GO TO 160
400 REM detected
410 LET v = v - 1
420 BEEP 0.1, 20: BEEP 0.1, 15
430 BORDER 2: PAUSE 10: BORDER 0
440 IF v = 0 THEN GO TO 500
460 PRINT AT g + 2, h + 2; " "
470 PRINT AT r + 2, c + 2; " "
480 READ r, c, g, h, d$, o, p, w, x
485 RESTORE: FOR i = 1 TO (l - 1) * 9 + 8: READ a$: NEXT i: READ r, c, g, h, d$, o, p, w, x
490 LET q = 1: LET f$ = d$(1 TO 1): LET t = 0
495 GO SUB 870: GO TO 160
500 CLS
510 PRINT AT 8, 9; INK 2; "GAME OVER"
520 PRINT AT 10, 8; "Score: "; e
525 PRINT AT 11, 8; "Floor: "; l
530 BEEP 0.15, 0: BEEP 0.15, -3: BEEP 0.2, -7
540 STOP
550 REM floor complete
560 LET e = e + 10 * l
570 BEEP 0.15, 12: BEEP 0.15, 16: BEEP 0.3, 19
580 PRINT AT 12, 5; INK 4; "FLOOR "; l; " COMPLETE!"
590 PAUSE 50
600 LET l = l + 1
610 IF l > 3 THEN GO TO 650
620 GO TO 60
650 REM victory
660 CLS
670 PRINT AT 8, 8; INK 4; "YOU ESCAPED!"
680 PRINT AT 10, 8; "Score: "; e
690 BEEP 0.15, 12: BEEP 0.15, 16: BEEP 0.15, 19: BEEP 0.3, 24
695 STOP
800 REM === draw map ===
810 FOR y = 1 TO 8
820 FOR x = 1 TO 16
830 IF m$(y)(x TO x) = "#" THEN PRINT AT y + 2, x + 2; INK 1; CHR$ 143
840 NEXT x
850 NEXT y
860 RETURN
870 REM === draw HUD ===
880 PRINT AT 0, 0; INK 7; "Lives:"; v; " Score:"; e; " Floor:"; l; "  "
885 IF j = 0 THEN PRINT AT 1, 0; INK 6; "Find * then reach X "
886 IF j = 1 THEN PRINT AT 1, 0; INK 4; "Go to X exit!       "
890 RETURN
900 REM floor 1
910 DATA "################"
920 DATA "#              #"
930 DATA "#  ## ####  #  #"
940 DATA "#     #     #  #"
950 DATA "#  ####  #     #"
960 DATA "#        #  #  #"
970 DATA "#   ##      #  #"
980 DATA "################"
990 DATA 6,2,3,10,"WWWWWWEEEEEE",2,14,6,15
1000 REM floor 2
1010 DATA "################"
1020 DATA "#   #     #    #"
1030 DATA "#   #  ## # #  #"
1040 DATA "#   #     #    #"
1050 DATA "### #####  #   #"
1060 DATA "#          #   #"
1070 DATA "#   # #     #  #"
1080 DATA "################"
1090 DATA 6,2,3,5,"SSSSNNNN",2,14,6,15
1100 REM floor 3
1110 DATA "################"
1120 DATA "#       #      #"
1130 DATA "# ####  # ###  #"
1140 DATA "#       #      #"
1150 DATA "# ##### # ###  #"
1160 DATA "#              #"
1170 DATA "#  # #   # #   #"
1180 DATA "################"
1190 DATA 6,2,2,3,"EEEEEEEWWWWWWW",2,14,6,15
