  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET alt = 100
  30 LET spd = 0
  40 LET fuel = 50
  50 PRINT AT 1, 2; "ALT:         SPD:         FUEL:"
  60 LET spd = spd + 1
  70 IF INKEY$ = " " AND fuel > 0 THEN LET spd = spd - 2: LET fuel = fuel - 1
  80 IF spd < 0 THEN LET spd = 0
  90 LET alt = alt - spd
 100 IF alt <= 0 THEN LET alt = 0
 110 PRINT AT 1, 7; alt; "  "
 120 PRINT AT 1, 19; spd; "  "
 130 PRINT AT 1, 31; fuel; "  "
 140 PAUSE 3
 150 IF alt = 0 AND spd <= 3 THEN GO TO 200
 160 IF alt = 0 AND spd > 3 THEN GO TO 300
 170 GO TO 60
 200 PRINT AT 10, 10; INK 4; "TOUCHDOWN!"
 210 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 220 STOP
 300 PRINT AT 10, 10; INK 2; "CRASH!"
 310 BEEP 0.5, -10
 320 STOP
