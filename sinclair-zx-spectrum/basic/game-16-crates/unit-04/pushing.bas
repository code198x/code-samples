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
 320 IF INKEY$ <> "" THEN GO TO 320
 330 LET k$ = INKEY$: IF k$ = "" THEN GO TO 330
 350 LET dy = 0: LET dx = 0
 360 IF k$ = "i" OR k$ = "I" THEN LET dy = -1
 370 IF k$ = "k" OR k$ = "K" THEN LET dy = 1
 380 IF k$ = "j" OR k$ = "J" THEN LET dx = -1
 390 IF k$ = "l" OR k$ = "L" THEN LET dx = 1
 400 IF dy = 0 AND dx = 0 THEN GO TO 320
 410 LET nr = pr + dy: LET nc = pc + dx
 420 LET v = g(nr, nc)
 430 IF v = 1 THEN GO TO 320
 440 IF v = 3 THEN GO TO 510
 450 IF v <> 0 THEN GO TO 320
 460 PRINT AT sr+pr-1, sc+pc-1; PAPER 7; INK 0; " "
 480 LET pr = nr: LET pc = nc
 490 PRINT AT sr+pr-1, sc+pc-1; PAPER 7; INK 4; "P"
 500 GO TO 320
 510 REM --- Push crate ---
 520 LET br = nr + dy: LET bc = nc + dx
 530 LET bv = g(br, bc)
 540 IF bv <> 0 THEN GO TO 320
 550 LET g(br,bc) = 3: PRINT AT sr+br-1, sc+bc-1; PAPER 6; INK 0; " "
 570 PRINT AT sr+pr-1, sc+pc-1; PAPER 7; INK 0; " "
 590 LET g(nr,nc) = 0
 610 LET pr = nr: LET pc = nc
 620 PRINT AT sr+pr-1, sc+pc-1; PAPER 7; INK 4; "P"
 630 GO TO 320
 900 DATA 5,5
 901 DATA "WWWWW"
 902 DATA "W   W"
 903 DATA "W C W"
 904 DATA "W P W"
 905 DATA "WWWWW"
