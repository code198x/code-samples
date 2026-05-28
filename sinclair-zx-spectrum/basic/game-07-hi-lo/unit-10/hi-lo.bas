  10 BORDER 0: PAPER 0: INK 7: CLS
  12 DATA 0,102,255,255,255,126,60,24
  13 DATA 24,60,126,255,126,60,24,0
  14 DATA 0,102,255,255,255,126,60,24
  15 DATA 24,60,126,126,126,60,24,0
  16 FOR u = 0 TO 3: FOR j = 0 TO 7: READ b: POKE USR CHR$ (144 + u) + j, b: NEXT j: NEXT u
  17 LET f$ = "A234567890JQK"
  20 RANDOMIZE
  30 LET best = 0
  40 PRINT AT 5, 10; BRIGHT 1; "*** HI-LO ***"
  50 PRINT AT 8, 4; "Guess if the next card"
  60 PRINT AT 9, 4; "will be higher or lower."
  70 PRINT AT 12, 4; "Press H or L each round."
  80 PRINT AT 14, 4; "How long can your streak last?"
  90 PRINT AT 18, 4; "Press any key to start"
  95 PRINT AT 6, 12; INK 2; CHR$ 144; " "; CHR$ 145; INK 7; " "; CHR$ 146; " "; CHR$ 147
 100 PAUSE 0
 110 LET a = INT (RND * 13) + 1
 112 LET sa = INT (RND * 4) + 1
 120 LET streak = 0
 130 CLS
 140 INVERSE 1: PRINT AT 0, 0; " *** HI-LO ***  S:"; streak; " B:"; best; "     ": INVERSE 0
 150 LET v = a: LET s = sa: LET cx = 5: LET cy = 4: GO SUB 800
 160 LET cx = 18: GO SUB 850
 180 PRINT AT 17, 4;
 190 INPUT "Higher or lower (H/L)? "; g$
 200 LET b = INT (RND * 13) + 1
 202 LET sb = INT (RND * 4) + 1
 210 LET v = b: LET s = sb: LET cx = 18: LET cy = 4: GO SUB 800
 220 LET ok = 0
 230 IF g$ = "H" AND b > a THEN LET ok = 1
 240 IF g$ = "L" AND b < a THEN LET ok = 1
 250 IF b = a THEN LET ok = 1
 260 IF ok = 0 THEN GO TO 400
 270 LET streak = streak + 1
 280 BORDER 4: BEEP 0.1, 10
 290 PRINT AT 15, 8; INK 4; "Correct!"
 300 PAUSE 30
 310 BORDER 0
 320 PRINT AT 15, 8; "        "
 330 LET a = b: LET sa = sb
 340 GO TO 130
 400 BORDER 2: BEEP 0.3, -10
 410 IF streak > best THEN LET best = streak
 420 CLS
 430 PRINT AT 5, 10; BRIGHT 1; "*** HI-LO ***"
 440 PRINT AT 8, 8; "GAME OVER"
 450 PRINT AT 10, 8; "Streak: "; streak
 460 PRINT AT 11, 8; "Best:   "; best
 470 PRINT AT 14, 8;
 480 IF streak >= 10 THEN INK 4: PRINT "Unstoppable!"
 490 IF streak >= 5 AND streak < 10 THEN INK 5: PRINT "Impressive!"
 500 IF streak < 5 THEN INK 6: PRINT "Try again..."
 510 INK 7
 520 PRINT AT 18, 4; "Press any key to play again"
 530 PAUSE 0
 540 BORDER 0
 550 GO TO 110
 800 REM Draw card at cx, cy with value v and suit s
 802 PAPER 7: INK 0
 804 FOR i = 0 TO 6: PRINT AT cy + i, cx; "         ": NEXT i
 806 LET e$ = f$(v TO v)
 808 IF v = 10 THEN LET e$ = "10"
 810 PRINT AT cy, cx + 1; e$
 812 PRINT AT cy + 6, cx + 7 - LEN e$; e$
 814 IF s <= 2 THEN INK 2
 816 PRINT AT cy + 3, cx + 4; CHR$ (143 + s)
 818 PAPER 0: INK 7
 820 RETURN
 850 REM Draw face-down card at cx, cy
 852 PAPER 1: INK 5
 854 FOR i = 0 TO 6: PRINT AT cy + i, cx; "         ": NEXT i
 856 PRINT AT cy + 3, cx + 4; "?"
 858 PAPER 0: INK 7
 860 RETURN
9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
