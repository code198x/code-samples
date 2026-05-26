  10 CLS
  20 LET alt = 100
  30 LET spd = 0
  40 LET spd = spd + 1
  50 LET alt = alt - spd
  60 IF alt <= 0 THEN LET alt = 0
  70 PRINT AT 10, 10; "Alt: "; alt; "   "
  80 PRINT AT 11, 10; "Spd: "; spd; "   "
  90 PAUSE 5
 100 IF alt = 0 AND spd <= 5 THEN PRINT AT 13, 10; "TOUCHDOWN!": STOP
 110 IF alt = 0 AND spd > 5 THEN PRINT AT 13, 10; "CRASH!": STOP
 120 GO TO 40
