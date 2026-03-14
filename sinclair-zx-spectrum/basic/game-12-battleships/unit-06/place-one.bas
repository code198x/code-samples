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
55 PRINT AT 0, 2; INK 6; BRIGHT 1; "Player "; p; " - Place Ships"
57 GO SUB 600
60 LET s = 1
65 PRINT AT 14, 1; INK 7; "Place "; n$(s); " ("; l(s); " cells)"
70 PRINT AT 15, 1; "                              "
72 PRINT AT 16, 1; "                              "
75 INPUT "Start (e.g. A3): "; m$
77 IF LEN m$ < 2 THEN PRINT AT 16, 1; INK 2; "Use format: A3": GO TO 75
80 LET x = CODE m$(1) - 64
82 IF x > 26 THEN LET x = x - 32
85 IF LEN m$ = 2 THEN LET y = VAL m$(2)
87 IF LEN m$ > 2 THEN LET y = VAL m$(2 TO LEN m$)
90 IF x < 1 OR x > 10 OR y < 1 OR y > 10 THEN PRINT AT 16, 1; INK 2; "Invalid square": GO TO 75
95 INPUT "Direction (H/V): "; d$
97 IF d$ <> "H" AND d$ <> "h" AND d$ <> "V" AND d$ <> "v" THEN PRINT AT 16, 1; INK 2; "Enter H or V": GO TO 95
100 LET e = 0
102 IF d$ = "H" OR d$ = "h" THEN LET e = 1
105 IF e = 1 AND x + l(s) - 1 > 10 THEN PRINT AT 16, 1; INK 2; "Ship off grid    ": GO TO 75
110 IF e = 0 AND y + l(s) - 1 > 10 THEN PRINT AT 16, 1; INK 2; "Ship off grid    ": GO TO 75
115 FOR n = 0 TO l(s) - 1
120 IF e = 1 THEN LET r = y: LET q = x + n
122 IF e = 0 THEN LET r = y + n: LET q = x
125 IF p = 1 THEN LET a(r, q) = s
127 IF p = 2 THEN LET b(r, q) = s
130 NEXT n
135 GO SUB 600
140 PRINT AT 16, 1; INK 4; n$(s); " placed!"
150 STOP
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
