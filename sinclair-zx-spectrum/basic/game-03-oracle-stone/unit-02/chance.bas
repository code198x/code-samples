  10 BORDER 1: PAPER 1: INK 7: CLS
  20 RANDOMIZE
  40 PRINT "  *** THE ORACLE STONE ***"
  50 PRINT
  60 PRINT "  Ask any yes-or-no question."
  90 INPUT "  Speak, mortal: "; q$
 200 LET r = INT (RND * 3) + 1
 230 IF r = 1 THEN PRINT "  YES"
 240 IF r = 2 THEN PRINT "  NO"
 250 IF r = 3 THEN PRINT "  PERHAPS"

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
