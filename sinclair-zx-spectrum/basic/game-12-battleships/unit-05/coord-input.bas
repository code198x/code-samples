10 BORDER 1: PAPER 1: INK 7: CLS
20 DIM a(10, 10): DIM b(10, 10)
25 DIM c(10, 10): DIM d(10, 10)
30 DIM l(5)
35 FOR n = 1 TO 5: READ l(n): NEXT n
36 DATA 5, 4, 3, 3, 2
50 LET p = 1
55 GO SUB 500
100 REM === test coordinate input ===
105 PRINT AT 14, 1; "                              "
106 PRINT AT 15, 1; "                              "
110 INPUT "Enter coord (e.g. A3): "; m$
115 IF LEN m$ < 2 THEN PRINT AT 15, 1; INK 2; "Use format: A3": GO TO 110
120 LET x = CODE m$(1) - 64
122 IF x > 26 THEN LET x = x - 32
125 IF LEN m$ = 2 THEN LET y = VAL m$(2)
127 IF LEN m$ > 2 THEN LET y = VAL m$(2 TO LEN m$)
130 IF x < 1 OR x > 10 OR y < 1 OR y > 10 THEN PRINT AT 15, 1; INK 2; "Invalid square": GO TO 110
135 PRINT AT 14, 1; INK 7; "Column: "; x; " Row: "; y
140 PRINT AT 15, 1; INK 7; "That is "; CHR$ (64 + x); y
145 GO TO 100
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
