10 BORDER 1: PAPER 1: INK 7: CLS
20 DIM a(10, 10): DIM b(10, 10)
25 DIM c(10, 10): DIM d(10, 10)
30 DIM l(5)
35 FOR n = 1 TO 5: READ l(n): NEXT n
36 DATA 5, 4, 3, 3, 2
37 DIM n$(5, 10)
38 FOR n = 1 TO 5: READ n$(n): NEXT n
39 DATA "CARRIER   ", "BATTLESHIP", "DESTROYER ", "SUBMARINE ", "PATROL    "
50 LET p = 1
55 CLS
60 GO SUB 300
70 CLS
72 PRINT AT 10, 4; INK 6; "Pass to Player 2"
74 PRINT AT 12, 4; INK 7; "Press any key"
76 PAUSE 0
78 LET p = 2
79 CLS
80 GO SUB 300
85 CLS
86 PRINT AT 10, 4; INK 6; "All ships placed!"
88 PRINT AT 12, 4; INK 7; "Press any key"
89 PAUSE 0
90 LET p = 1
100 REM === game loop ===
105 CLS
110 GO SUB 500
115 PRINT AT 12, 1; INK 6; BRIGHT 1; "Player "; p
120 GO SUB 800
125 GO SUB 900
140 PRINT AT 20, 2; INK 7; "Press any key"
145 PAUSE 0
150 IF p = 1 THEN LET p = 2: GO TO 160
152 LET p = 1
160 CLS
162 PRINT AT 10, 4; INK 6; "Player "; p; " ready?"
165 PRINT AT 12, 4; INK 7; "Press any key"
170 PAUSE 0
175 GO TO 100
300 REM === place ships ===
305 PRINT AT 0, 2; INK 6; BRIGHT 1; "Player "; p; " - Place Ships"
310 FOR s = 1 TO 5
315 GO SUB 600
320 PRINT AT 14, 1; INK 7; "Place "; n$(s); " ("; l(s); " cells)"
325 PRINT AT 15, 1; "                              "
326 PRINT AT 16, 1; "                              "
330 INPUT "Start (e.g. A3): "; m$
332 IF LEN m$ < 2 THEN PRINT AT 16, 1; INK 2; "Use format: A3": GO TO 330
335 LET x = CODE m$(1) - 64
336 IF x > 26 THEN LET x = x - 32
337 IF LEN m$ = 2 THEN LET y = VAL m$(2)
338 IF LEN m$ > 2 THEN LET y = VAL m$(2 TO LEN m$)
340 IF x < 1 OR x > 10 OR y < 1 OR y > 10 THEN PRINT AT 16, 1; INK 2; "Invalid square": GO TO 330
345 INPUT "Direction (H/V): "; d$
347 IF d$ <> "H" AND d$ <> "h" AND d$ <> "V" AND d$ <> "v" THEN PRINT AT 16, 1; INK 2; "Enter H or V": GO TO 345
350 LET e = 0
352 IF d$ = "H" OR d$ = "h" THEN LET e = 1
355 IF e = 1 AND x + l(s) - 1 > 10 THEN PRINT AT 16, 1; INK 2; "Ship off grid    ": GO TO 330
360 IF e = 0 AND y + l(s) - 1 > 10 THEN PRINT AT 16, 1; INK 2; "Ship off grid    ": GO TO 330
365 FOR n = 0 TO l(s) - 1
370 IF e = 1 THEN LET r = y: LET q = x + n
372 IF e = 0 THEN LET r = y + n: LET q = x
375 IF p = 1 AND a(r, q) <> 0 THEN PRINT AT 16, 1; INK 2; "Ships overlap     ": GO TO 330
377 IF p = 2 AND b(r, q) <> 0 THEN PRINT AT 16, 1; INK 2; "Ships overlap     ": GO TO 330
380 NEXT n
385 FOR n = 0 TO l(s) - 1
387 IF e = 1 THEN LET r = y: LET q = x + n
388 IF e = 0 THEN LET r = y + n: LET q = x
390 IF p = 1 THEN LET a(r, q) = s
392 IF p = 2 THEN LET b(r, q) = s
395 NEXT n
397 BEEP 0.05, 10
398 PRINT AT 16, 1; INK 4; n$(s); " placed!       "
399 NEXT s
400 RETURN
500 REM === draw both grids ===
505 PRINT AT 0, 1; INK 6; "YOUR SHIPS"
507 PRINT AT 0, 18; INK 6; "YOUR SHOTS"
510 FOR n = 1 TO 10
515 PRINT AT 1, n + 1; INK 5; CHR$ (64 + n)
517 PRINT AT 1, n + 18; INK 5; CHR$ (64 + n)
520 NEXT n
525 FOR r = 1 TO 10
530 IF r < 10 THEN PRINT AT r + 1, 1; INK 5; r
532 IF r = 10 THEN PRINT AT r + 1, 0; INK 5; "10"
535 IF r < 10 THEN PRINT AT r + 1, 18; INK 5; r
537 IF r = 10 THEN PRINT AT r + 1, 17; INK 5; "10"
540 FOR q = 1 TO 10
545 LET v = 0: LET w = 0
547 IF p = 1 THEN LET v = a(r, q): LET w = d(r, q)
549 IF p = 2 THEN LET v = b(r, q): LET w = c(r, q)
552 IF v = 0 AND w = 0 THEN PRINT AT r + 1, q + 1; INK 0; PAPER 1; "."
554 IF v > 0 AND w = 0 THEN PRINT AT r + 1, q + 1; INK 7; PAPER 1; CHR$ (64 + v)
556 IF w = 1 THEN PRINT AT r + 1, q + 1; INK 6; PAPER 1; "."
558 IF w = 2 THEN PRINT AT r + 1, q + 1; INK 2; BRIGHT 1; PAPER 1; "X"
560 REM tracking grid
562 LET v = 0
564 IF p = 1 THEN LET v = c(r, q)
566 IF p = 2 THEN LET v = d(r, q)
568 IF v = 0 THEN PRINT AT r + 1, q + 18; INK 0; PAPER 1; "."
570 IF v = 1 THEN PRINT AT r + 1, q + 18; INK 6; PAPER 1; "."
572 IF v = 2 THEN PRINT AT r + 1, q + 18; INK 2; BRIGHT 1; PAPER 1; "X"
575 NEXT q
580 NEXT r
585 RETURN
600 REM === draw placement grid ===
610 FOR n = 1 TO 10
615 PRINT AT 1, n + 1; INK 5; CHR$ (64 + n)
620 NEXT n
625 FOR r = 1 TO 10
627 IF r < 10 THEN PRINT AT r + 1, 1; INK 5; r
628 IF r = 10 THEN PRINT AT r + 1, 0; INK 5; "10"
630 FOR q = 1 TO 10
635 LET v = 0
637 IF p = 1 THEN LET v = a(r, q)
639 IF p = 2 THEN LET v = b(r, q)
640 IF v = 0 THEN PRINT AT r + 1, q + 1; INK 0; PAPER 1; "."
645 IF v > 0 THEN PRINT AT r + 1, q + 1; INK 7; PAPER 1; CHR$ (64 + v)
650 NEXT q
655 NEXT r
660 RETURN
800 REM === fire shot ===
805 PRINT AT 15, 1; "                              "
806 PRINT AT 16, 1; "                              "
810 INPUT "Target (e.g. D7): "; m$
812 IF LEN m$ < 2 THEN PRINT AT 16, 1; INK 2; "Use format: D7": GO TO 810
815 LET x = CODE m$(1) - 64
816 IF x > 26 THEN LET x = x - 32
817 IF LEN m$ = 2 THEN LET y = VAL m$(2)
818 IF LEN m$ > 2 THEN LET y = VAL m$(2 TO LEN m$)
820 IF x < 1 OR x > 10 OR y < 1 OR y > 10 THEN PRINT AT 16, 1; INK 2; "Invalid square": GO TO 810
825 LET f = 0
827 IF p = 1 AND c(y, x) <> 0 THEN LET f = 1
829 IF p = 2 AND d(y, x) <> 0 THEN LET f = 1
830 IF f = 1 THEN PRINT AT 16, 1; INK 2; "Already fired there": GO TO 810
840 RETURN
900 REM === resolve shot ===
905 LET v = 0
910 IF p = 1 THEN LET v = b(y, x)
912 IF p = 2 THEN LET v = a(y, x)
915 IF v = 0 THEN GO TO 950
920 REM hit
922 IF p = 1 THEN LET c(y, x) = 2
924 IF p = 2 THEN LET d(y, x) = 2
930 PRINT AT 17, 1; INK 2; BRIGHT 1; "HIT!                          "
936 GO TO 960
950 REM miss
952 IF p = 1 THEN LET c(y, x) = 1
954 IF p = 2 THEN LET d(y, x) = 1
956 PRINT AT 17, 1; INK 6; "Miss.                         "
960 GO SUB 500
965 RETURN
