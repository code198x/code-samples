  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
 110 LET a = INT (RND * 13) + 1
 130 CLS
 150 PRINT "Number: "; a
 190 INPUT "Higher or lower (H/L)? "; g$
 200 LET b = INT (RND * 13) + 1
 210 PRINT "Next:   "; b
 220 LET ok = 0
 230 IF g$ = "H" AND b > a THEN LET ok = 1
 240 IF g$ = "L" AND b < a THEN LET ok = 1
 250 IF b = a THEN LET ok = 1
 260 IF ok = 0 THEN PRINT "Wrong!"
 290 IF ok = 1 THEN PRINT "Correct!"
