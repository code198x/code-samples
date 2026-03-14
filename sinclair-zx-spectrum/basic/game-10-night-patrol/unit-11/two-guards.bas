10 BORDER 0: PAPER 0: INK 7: CLS
20 DIM m$(8, 16)
30 FOR i = 1 TO 8
40 READ m$(i)
50 NEXT i
60 LET r = 6: LET c = 2: LET v = 3: LET e = 0
70 DIM y(2): DIM z(2)
80 DIM q(2): DIM f$(2, 1)
90 LET n = 2
100 LET y(1) = 3: LET z(1) = 5: LET f$(1) = "S"
110 LET y(2) = 5: LET z(2) = 12: LET f$(2) = "W"
120 READ d$, b$
130 LET q(1) = 1: LET q(2) = 1
140 LET t = 0: LET s = 15
150 LET j = 0
160 LET o = 2: LET p = 14
170 LET w = 6: LET x = 15
180 GO SUB 800
185 PRINT AT o + 2, p + 2; INK 6; "*"
186 PRINT AT w + 2, x + 2; INK 1; "X"
190 GO SUB 870
200 REM game loop
210 PRINT AT r + 2, c + 2; INK 7; BRIGHT 1; "@"
220 FOR i = 1 TO n
230 PRINT AT y(i) + 2, z(i) + 2; INK 2; "G"
240 NEXT i
250 LET t = t + 1
260 LET k$ = INKEY$
270 IF k$ = "" THEN GO TO 310
280 LET u = r: LET i = c
282 IF k$ = "q" THEN LET u = r - 1
284 IF k$ = "a" THEN LET u = r + 1
286 IF k$ = "o" THEN LET i = c - 1
288 IF k$ = "p" THEN LET i = c + 1
290 IF u < 1 OR u > 8 OR i < 1 OR i > 16 THEN GO TO 310
292 IF m$(u)(i TO i) = "#" THEN GO TO 310
294 PRINT AT r + 2, c + 2; " "
296 LET r = u: LET c = i
298 IF r = o AND c = p AND j = 0 THEN LET j = 1: BEEP 0.1, 20: PRINT AT w + 2, x + 2; INK 4; "X": GO SUB 870
299 IF r = w AND c = x AND j = 1 THEN GO TO 550
310 IF t < s THEN GO TO 380
320 LET t = 0
330 FOR i = 1 TO n
340 PRINT AT y(i) + 2, z(i) + 2; " "
342 IF i = 1 THEN LET f$ = d$(q(1) TO q(1)): GO TO 346
344 LET f$ = b$(q(2) TO q(2))
346 IF f$ = "N" THEN LET y(i) = y(i) - 1
348 IF f$ = "S" THEN LET y(i) = y(i) + 1
350 IF f$ = "W" THEN LET z(i) = z(i) - 1
352 IF f$ = "E" THEN LET z(i) = z(i) + 1
354 LET f$(i) = f$
356 LET q(i) = q(i) + 1
358 IF i = 1 AND q(1) > LEN d$ THEN LET q(1) = 1
360 IF i = 2 AND q(2) > LEN b$ THEN LET q(2) = 1
362 NEXT i
380 FOR i = 1 TO n
382 IF r = y(i) AND c = z(i) THEN GO TO 400
384 NEXT i
390 GO TO 210
400 REM detected
410 LET v = v - 1
420 BEEP 0.1, 20: BEEP 0.1, 15
430 BORDER 2: PAUSE 10: BORDER 0
440 IF v = 0 THEN GO TO 500
450 FOR i = 1 TO n: PRINT AT y(i) + 2, z(i) + 2; " ": NEXT i
460 PRINT AT r + 2, c + 2; " "
470 LET r = 6: LET c = 2
475 LET y(1) = 3: LET z(1) = 5: LET y(2) = 5: LET z(2) = 12
480 LET q(1) = 1: LET q(2) = 1: LET t = 0
490 GO SUB 870: GO TO 210
500 CLS
510 PRINT AT 8, 9; INK 2; "GAME OVER"
520 PRINT AT 10, 8; "Score: "; e
530 BEEP 0.15, 0: BEEP 0.15, -3: BEEP 0.2, -7
540 STOP
550 LET e = e + 10
560 BEEP 0.15, 12: BEEP 0.15, 16: BEEP 0.3, 19
570 PRINT AT 12, 5; INK 4; BRIGHT 1; "FLOOR COMPLETE!"
580 STOP
800 REM === draw map ===
810 FOR y = 1 TO 8
820 FOR x = 1 TO 16
830 IF m$(y)(x TO x) = "#" THEN PRINT AT y + 2, x + 2; INK 1; CHR$ 143
840 NEXT x
850 NEXT y
860 RETURN
870 REM === draw HUD ===
880 PRINT AT 0, 0; INK 7; "Lives:"; v; " Score:"; e; "  "
885 IF j = 0 THEN PRINT AT 1, 0; INK 6; "Find * then reach X "
886 IF j = 1 THEN PRINT AT 1, 0; INK 4; "Go to X exit!       "
890 RETURN
900 DATA "################"
910 DATA "#   #     #    #"
920 DATA "#   #  ## # #  #"
930 DATA "#   #     #    #"
940 DATA "### #####  #   #"
950 DATA "#          #   #"
960 DATA "#   # #     #  #"
970 DATA "################"
980 DATA "SSSSNNNN","WWWWWWEEEEEE"
