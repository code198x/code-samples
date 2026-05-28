  10 BORDER 0: PAPER 0: INK 7: CLS
  30 PRINT AT 3, 6; BRIGHT 1; "*** STORY BUILDER ***"
  40 PLOT 148, 120: DRAW -20, -30: DRAW 3, 0: DRAW 17, 30: PLOT 128, 90: DRAW -8, -12
  50 INPUT "What is your name? "; n$
  60 INPUT "Name an adjective: "; a$
  70 INPUT "Name an animal: "; b$
  80 INPUT "Name a place: "; p$
  90 INPUT "Name a food: "; f$
 100 CLS
 110 PAUSE 50: BEEP 0.1, 24
 120 INK 5
 130 PRINT "Once upon a time, "; n$
 140 PRINT "found a "; a$; " "; b$
 150 PRINT "hiding in "; p$; "."
 160 PRINT
 170 PRINT "They fed it "; f$
 180 PRINT "and it followed them home."
 190 PRINT
 200 INK 7: PRINT "The end."
