  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 10; "*** CRATES ***"
  25 PRINT AT 8, 3; "Push crates onto red targets."
  27 PRINT AT 9, 3; "I/J/K/L to move. R to restart."
  30 PRINT AT 11, 3; "You can push but never pull."
  35 PRINT AT 14, 4; "Press any key to begin"
  40 PAUSE 0
  48 LET lv = 1: LET moves = 0
  50 RESTORE 900 + (lv - 1) * 10
  52 READ w, h
  54 IF w = 0 THEN GO TO 500
  56 LET sr = INT ((22 - h) / 2) + 1
  58 LET sc = INT ((32 - w) / 2)
  60 LET ps = 0: LET moves = 0
  61 DIM g(h, w)
  62 CLS
  64 PRINT AT 0, 10; "*** CRATES ***"
  66 PRINT AT 0, 0; "Level "; lv
  68 PRINT AT 0, 24; "Moves: "; moves
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
 150 IF INKEY$ <> "" THEN GO TO 150
 151 LET k$ = INKEY$: IF k$ = "" THEN GO TO 151
 153 IF k$ = "r" OR k$ = "R" THEN LET moves = 0: GO TO 50
 154 LET dy = 0: LET dx = 0
 156 IF k$ = "i" OR k$ = "I" THEN LET dy = -1
 157 IF k$ = "k" OR k$ = "K" THEN LET dy = 1
 158 IF k$ = "j" OR k$ = "J" THEN LET dx = -1
 159 IF k$ = "l" OR k$ = "L" THEN LET dx = 1
 160 IF dy = 0 AND dx = 0 THEN GO TO 150
 162 LET nr = pr + dy: LET nc = pc + dx
 164 LET v = g(nr, nc)
 166 IF v = 1 THEN GO TO 150
 168 IF v = 3 OR v = 4 THEN GO TO 180
 169 IF v <> 0 AND v <> 2 THEN GO TO 150
 172 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 0; " "
 174 LET ps = 0: IF v = 2 THEN LET ps = 1
 176 LET pr = nr: LET pc = nc
 178 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 4; "P"
 179 GO TO 150
 180 REM --- Push crate ---
 182 LET br = nr + dy: LET bc = nc + dx
 184 LET bv = g(br, bc)
 186 IF bv <> 0 AND bv <> 2 THEN BEEP 0.05, -5: GO TO 150
 187 IF bv = 0 THEN LET g(br,bc) = 3: PRINT AT sr+br-1, sc+bc-1; PAPER 6; INK 0; " "
 188 IF bv = 2 THEN LET g(br,bc) = 4: PRINT AT sr+br-1, sc+bc-1; PAPER 4; INK 0; " "
 190 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 0; " "
 192 LET ps = 0: IF v = 4 THEN LET ps = 1
 193 IF v = 3 THEN LET g(nr,nc) = 0
 194 IF v = 4 THEN LET g(nr,nc) = 2
 196 LET pr = nr: LET pc = nc
 197 PRINT AT sr+pr-1, sc+pc-1; PAPER (7-ps*5); INK 4; "P"
 198 LET moves = moves + 1
 199 PRINT AT 0, 24; "Moves: "; moves; "  "
 200 REM --- All targets covered? ---
 202 LET win = 1
 204 FOR r = 1 TO h
 206 FOR c = 1 TO w
 208 IF g(r, c) = 2 THEN LET win = 0
 210 NEXT c
 212 NEXT r
 214 IF win = 0 THEN GO TO 150
 220 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 222 PRINT AT 20, 6; "Level complete! Press any key"
 224 PAUSE 0
 226 LET lv = lv + 1
 228 GO TO 50
 500 CLS
 510 PRINT AT 6, 10; "*** CRATES ***"
 515 PRINT AT 9, 4; INK 4; "All levels complete!"
 520 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20: BEEP 0.2, 25
 550 PRINT AT 18, 4; "Press any key to play again"
 555 PAUSE 0
 560 LET lv = 1: LET moves = 0: GO TO 50
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
