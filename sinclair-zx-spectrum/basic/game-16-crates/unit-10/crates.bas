  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 10; "*** CRATES ***"
  30 PRINT AT 8, 3; "Push crates onto red targets."
  40 PRINT AT 9, 3; "I/J/K/L to move. R to restart."
  50 PRINT AT 11, 3; "You can push but never pull."
  60 PRINT AT 14, 4; "Press any key to begin"
  70 PAUSE 0
  80 LET lv = 1: LET moves = 0
  90 RESTORE 900 + (lv - 1) * 10
 100 READ w, h
 110 IF w = 0 THEN GO TO 790
 120 LET sr = INT ((22 - h) / 2) + 1
 130 LET sc = INT ((32 - w) / 2)
 140 LET ps = 0: LET moves = 0
 150 DIM g(h, w)
 160 CLS
 170 PRINT AT 0, 10; "*** CRATES ***"
 180 PRINT AT 0, 0; "Level "; lv
 190 PRINT AT 0, 24; "Moves: "; moves
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
 340 IF k$ = "r" OR k$ = "R" THEN LET moves = 0: GO TO 90
 350 LET dy = 0: LET dx = 0
 360 IF k$ = "i" OR k$ = "I" THEN LET dy = -1
 370 IF k$ = "k" OR k$ = "K" THEN LET dy = 1
 380 IF k$ = "j" OR k$ = "J" THEN LET dx = -1
 390 IF k$ = "l" OR k$ = "L" THEN LET dx = 1
 400 IF dy = 0 AND dx = 0 THEN GO TO 320
 410 LET nr = pr + dy: LET nc = pc + dx
 420 LET v = g(nr, nc)
 430 IF v = 1 THEN GO TO 320
 440 IF v = 3 OR v = 4 THEN GO TO 510
 450 IF v <> 0 AND v <> 2 THEN GO TO 320
 460 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 0; " "
 470 LET ps = 0: IF v = 2 THEN LET ps = 1
 480 LET pr = nr: LET pc = nc
 490 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 4; "P"
 500 GO TO 320
 510 REM --- Push crate ---
 520 LET br = nr + dy: LET bc = nc + dx
 530 LET bv = g(br, bc)
 540 IF bv <> 0 AND bv <> 2 THEN BEEP 0.05, -5: GO TO 320
 550 IF bv = 0 THEN LET g(br,bc) = 3: PRINT AT sr+br-1, sc+bc-1; PAPER 6; INK 0; " "
 560 IF bv = 2 THEN LET g(br,bc) = 4: PRINT AT sr+br-1, sc+bc-1; PAPER 4; INK 0; " "
 570 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 0; " "
 580 LET ps = 0: IF v = 4 THEN LET ps = 1
 590 IF v = 3 THEN LET g(nr,nc) = 0
 600 IF v = 4 THEN LET g(nr,nc) = 2
 610 LET pr = nr: LET pc = nc
 620 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 4; "P"
 630 LET moves = moves + 1
 640 PRINT AT 0, 24; "Moves: "; moves; "  "
 650 REM --- All targets covered? ---
 660 LET win = 1
 670 FOR r = 1 TO h
 680 FOR c = 1 TO w
 690 IF g(r, c) = 2 THEN LET win = 0
 700 NEXT c
 710 NEXT r
 720 IF win = 0 THEN GO TO 320
 730 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 740 PRINT AT 20, 6; "Level complete! Press any key"
 750 PAUSE 0
 760 LET lv = lv + 1
 770 GO TO 90
 790 CLS
 800 PRINT AT 6, 10; "*** CRATES ***"
 810 PRINT AT 9, 4; INK 4; "All levels complete!"
 820 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20: BEEP 0.2, 25
 830 PRINT AT 18, 4; "Press any key to play again"
 840 PAUSE 0
 850 LET lv = 1: LET moves = 0: GO TO 90
 900 DATA 5,5
 901 DATA "WWWWW"
 902 DATA "W . W"
 903 DATA "W C W"
 904 DATA "W P W"
 905 DATA "WWWWW"
 910 DATA 6,6
 911 DATA "WWWWWW"
 912 DATA "W    W"
 913 DATA "W  . W"
 914 DATA "W C  W"
 915 DATA "W P  W"
 916 DATA "WWWWWW"
 920 DATA 6,6
 921 DATA "WWWWWW"
 922 DATA "WP   W"
 923 DATA "WCC  W"
 924 DATA "W..  W"
 925 DATA "W    W"
 926 DATA "WWWWWW"
 930 DATA 0,0
