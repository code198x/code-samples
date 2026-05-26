  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 LET a = INT (RND * 13) + 1
  40 LET streak = 0
  50 CLS
  60 PRINT AT 2, 10; "*** HI-LO ***"
  70 PRINT AT 5, 8; "Number: "; a; "   "
  80 PRINT AT 7, 8; "Streak: "; streak; "   "
  90 PRINT AT 10, 4;
 100 INPUT "Higher or lower (H/L)? "; g$
 110 LET b = INT (RND * 13) + 1
 120 PRINT AT 12, 8; "Next: "; b; "   "
 130 LET ok = 0
 140 IF g$ = "H" AND b > a THEN LET ok = 1
 150 IF g$ = "L" AND b < a THEN LET ok = 1
 160 IF b = a THEN LET ok = 1
 170 IF ok = 0 THEN GO TO 300
 180 LET streak = streak + 1
 190 BORDER 4: BEEP 0.1, 10
 200 PRINT AT 14, 8; INK 4; "Correct!"
 210 PAUSE 30
 220 BORDER 0
 230 LET a = b
 240 GO TO 50
 300 BORDER 2: BEEP 0.3, -10
 310 PRINT AT 14, 8; INK 2; "Wrong!"
 320 PRINT AT 16, 8; "Final streak: "; streak
 330 IF streak >= 10 THEN PRINT AT 17, 8; INK 4; "Unstoppable!"
 340 IF streak >= 5 AND streak < 10 THEN PRINT AT 17, 8; INK 5; "Impressive!"
 350 IF streak < 5 THEN PRINT AT 17, 8; INK 6; "Try again..."
