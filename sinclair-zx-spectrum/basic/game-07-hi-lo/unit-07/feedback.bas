  10 BORDER 0: PAPER 0: INK 7: CLS
  20 DATA 0,102,255,255,255,126,60,24
  30 DATA 24,60,126,255,126,60,24,0
  40 DATA 24,60,24,126,255,126,24,60
  50 DATA 24,60,126,255,255,24,60,0
  60 FOR u = 0 TO 3: FOR j = 0 TO 7: READ b: POKE USR CHR$ (144 + u) + j, b: NEXT j: NEXT u
  70 LET f$ = "A234567890JQK"
  80 RANDOMIZE
 180 LET a = INT (RND * 13) + 1
 190 LET sa = INT (RND * 4) + 1
 200 LET streak = 0
 210 CLS
 220 INVERSE 1: PRINT AT 0, 0; " *** HI-LO ***  S:"; streak; "            ": INVERSE 0
 230 LET v = a: LET s = sa: LET cx = 5: LET cy = 4: GO SUB 800
 240 LET cx = 18: GO SUB 910
 250 PRINT AT 17, 4;
 260 INPUT "Higher or lower (H/L)? "; g$
 270 LET b = INT (RND * 13) + 1
 280 LET sb = INT (RND * 4) + 1
 290 LET v = b: LET s = sb: LET cx = 18: LET cy = 4: GO SUB 800
 300 LET ok = 0
 310 IF g$ = "H" AND b > a THEN LET ok = 1
 320 IF g$ = "L" AND b < a THEN LET ok = 1
 330 IF b = a THEN LET ok = 1
 340 IF ok = 0 THEN PRINT AT 15, 8; "Wrong!": STOP
 350 LET streak = streak + 1
 360 BORDER 4: BEEP 0.1, 10
 370 PRINT AT 15, 8; INK 4; "Correct!"
 380 PAUSE 30
 390 BORDER 0
 400 PRINT AT 15, 8; "        "
 410 LET a = b: LET sa = sb
 420 GO TO 210
 800 REM Draw card at cx, cy with value v and suit s
 810 PAPER 7: INK 0
 820 FOR i = 0 TO 6: PRINT AT cy + i, cx; "         ": NEXT i
 830 LET e$ = f$(v TO v)
 840 IF v = 10 THEN LET e$ = "10"
 850 PRINT AT cy, cx + 1; e$
 860 PRINT AT cy + 6, cx + 7 - LEN e$; e$
 870 IF s <= 2 THEN INK 2
 880 PRINT AT cy + 3, cx + 4; CHR$ (143 + s)
 890 PAPER 0: INK 7
 900 RETURN
 910 REM Draw face-down card at cx, cy
 920 PAPER 1: INK 5
 930 FOR i = 0 TO 6: PRINT AT cy + i, cx; "         ": NEXT i
 940 PRINT AT cy + 3, cx + 4; "?"
 950 PAPER 0: INK 7
 960 RETURN
