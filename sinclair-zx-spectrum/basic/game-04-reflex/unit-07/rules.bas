  10 BORDER 0: PAPER 0: INK 7: CLS
  20 RANDOMIZE
  30 PRINT AT 3, 9; BRIGHT 1; "*** REFLEX ***"
  40 PRINT
  50 PRINT "Wait for the screen to"
  60 PRINT "flash red, then press"
  70 PRINT "any key as fast as you can."
  80 PRINT
  90 PAUSE 0
 100 CLS
 110 PRINT "Get ready..."
 120 PRINT
 150 FOR x = 28 TO 228
 160 PLOT x, 87
 180 NEXT x
 190 PAPER 2: BORDER 2: CLS
 200 PRINT "NOW!"
 210 LET t = 0
 220 IF INKEY$ <> "" THEN GO TO 250
 230 LET t = t + 1
 240 GO TO 220
 250 PAPER 0: BORDER 0: CLS
 260 PRINT AT 3, 9; BRIGHT 1; "*** REFLEX ***"
 270 PRINT
 280 PRINT "Your time: "; t
 290 PRINT
 300 IF t < 5 THEN INK 4: PRINT "Lightning!"
 310 IF t >= 5 AND t < 15 THEN INK 5: PRINT "Quick!"
 320 IF t >= 15 AND t < 30 THEN INK 6: PRINT "OK"
 330 IF t >= 30 THEN INK 2: PRINT "Slow..."

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
