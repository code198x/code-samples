  50 RESTORE 900
  52 READ w, h
  56 LET sr = INT ((22 - h) / 2) + 1
  58 LET sc = INT ((32 - w) / 2)
  61 DIM g(h, w)
  62 CLS
  64 PRINT AT 0, 10; "*** CRATES ***"
  70 FOR r = 1 TO h
  72 READ r$
  74 FOR c = 1 TO w
  76 LET q$ = r$(c TO c)
  78 IF q$ = "W" THEN LET g(r,c) = 1: PRINT AT sr+r-1, sc+c-1; PAPER 1; INK 0; " "
  80 IF q$ = " " THEN PRINT AT sr+r-1, sc+c-1; PAPER 7; INK 0; " "
  82 IF q$ = "." THEN LET g(r,c) = 2: PRINT AT sr+r-1, sc+c-1; PAPER 2; INK 0; " "
  84 IF q$ = "C" THEN LET g(r,c) = 3: PRINT AT sr+r-1, sc+c-1; PAPER 6; INK 0; " "
  86 IF q$ = "P" THEN LET pr = r: LET pc = c: PRINT AT sr+r-1, sc+c-1; PAPER 7; INK 4; "P"
  88 NEXT c
  90 NEXT r
 900 DATA 5,5
 901 DATA "WWWWW"
 902 DATA "W . W"
 903 DATA "W C W"
 904 DATA "W P W"
 905 DATA "WWWWW"
