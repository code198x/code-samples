  10 CLS
  20 LET alt = 100
  30 LET spd = 0
  40 LET fuel = 50
  50 LET spd = spd + 1
  60 IF INKEY$ = " " AND fuel > 0 THEN LET spd = spd - 2: LET fuel = fuel - 1
  70 IF spd < 0 THEN LET spd = 0
  80 LET alt = alt - spd
  90 IF alt <= 0 THEN LET alt = 0
 100 PRINT AT 10, 10; "Alt:  "; alt; "   "
 110 PRINT AT 11, 10; "Spd:  "; spd; "   "
 120 PRINT AT 12, 10; "Fuel: "; fuel; "   "
 130 PAUSE 3
 140 IF alt = 0 AND spd <= 3 THEN PRINT AT 14, 10; "TOUCHDOWN!": STOP
 150 IF alt = 0 AND spd > 3 THEN PRINT AT 14, 10; "CRASH!": STOP
 160 GO TO 50
