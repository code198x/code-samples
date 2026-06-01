  90 RESTORE 900
 100 READ w, h
 120 LET sr = INT ((22 - h) / 2) + 1
 130 LET sc = INT ((32 - w) / 2)
 150 DIM g(h, w)
 160 CLS
 170 PRINT AT 0, 10; "*** CRATES ***"
 200 FOR r = 1 TO h
 210 READ r$
 220 FOR c = 1 TO w
 230 LET q$ = r$(c TO c)
 240 IF q$ = "W" THEN LET g(r,c) = 1: PRINT AT sr+r-1, sc+c-1; PAPER 1; INK 0; " "
 250 IF q$ = " " THEN PRINT AT sr+r-1, sc+c-1; PAPER 7; INK 0; " "
 260 IF q$ = "." THEN LET g(r,c) = 2: PRINT AT sr+r-1, sc+c-1; PAPER 2; INK 0; " "
 270 IF q$ = "C" THEN LET g(r,c) = 3: PRINT AT sr+r-1, sc+c-1; PAPER 6; INK 0; " "
 280 IF q$ = "P" THEN LET pr = r: LET pc = c: PRINT AT sr+r-1, sc+c-1; PAPER 7; INK 4; "P"
 290 NEXT c
 300 NEXT r
 900 DATA 5,5
 901 DATA "WWWWW"
 902 DATA "W . W"
 903 DATA "W C W"
 904 DATA "W P W"
 905 DATA "WWWWW"
