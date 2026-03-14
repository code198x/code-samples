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
90 STOP
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
