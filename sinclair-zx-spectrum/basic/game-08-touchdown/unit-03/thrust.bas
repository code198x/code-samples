  10 CLS
  20 LET alt = 100
  30 LET spd = 0
  40 LET spd = spd + 1
  50 IF INKEY$ = " " THEN LET spd = spd - 2
  60 IF spd < 0 THEN LET spd = 0
  70 LET alt = alt - spd
  80 IF alt <= 0 THEN LET alt = 0
  90 PRINT AT 10, 10; "Alt: "; alt; "   "
 100 PRINT AT 11, 10; "Spd: "; spd; "   "
 110 PAUSE 3
 120 IF alt = 0 AND spd <= 3 THEN PRINT AT 13, 10; "TOUCHDOWN!": STOP
 130 IF alt = 0 AND spd > 3 THEN PRINT AT 13, 10; "CRASH!": STOP
 140 GO TO 40
