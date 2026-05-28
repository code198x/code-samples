  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 LET best = 0
  40 LET a$ = "*** HI-LO ***": LET y = 5: GO SUB 9000
  50 PRINT AT 8, 4; "Guess if the next number"
  60 PRINT AT 9, 4; "will be higher or lower."
  70 PRINT AT 12, 4; "Press H or L each round."
  80 PRINT AT 14, 4; "How long can your streak last?"
  90 PRINT AT 18, 4; "Press any key to start"
 100 PAUSE 0
 110 LET a = INT (RND * 13) + 1
 120 LET streak = 0
 130 CLS
 140 LET a$ = "*** HI-LO ***": LET y = 1: GO SUB 9000
 150 PRINT AT 3, 8; "Number: "; a; "   "
 160 PRINT AT 5, 8; "Streak: "; streak; "   "
 170 PRINT AT 6, 8; "Best:   "; best; "   "
 180 PRINT AT 9, 4;
 190 INPUT "Higher or lower (H/L)? "; g$
 200 LET b = INT (RND * 13) + 1
 210 PRINT AT 11, 8; "Next: "; b; "   "
 220 LET ok = 0
 230 IF g$ = "H" AND b > a THEN LET ok = 1
 240 IF g$ = "L" AND b < a THEN LET ok = 1
 250 IF b = a THEN LET ok = 1
 260 IF ok = 0 THEN GO TO 400
 270 LET streak = streak + 1
 280 BORDER 4: BEEP 0.1, 10
 290 PRINT AT 13, 8; INK 4; "Correct!        "
 300 PAUSE 30
 310 BORDER 0
 320 PRINT AT 13, 8; "                "
 330 LET a = b
 340 GO TO 130
 400 BORDER 2: BEEP 0.3, -10
 410 IF streak > best THEN LET best = streak
 420 CLS
 430 LET a$ = "*** HI-LO ***": LET y = 5: GO SUB 9000
 440 PRINT AT 8, 8; "GAME OVER"
 450 PRINT AT 10, 8; "Streak: "; streak
 460 PRINT AT 11, 8; "Best:   "; best
 520 PRINT AT 18, 4; "Press any key to play again"
 530 PAUSE 0
 540 BORDER 0
 550 GO TO 110

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
