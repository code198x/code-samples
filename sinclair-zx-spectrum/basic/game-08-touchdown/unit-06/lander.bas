  10 BORDER 0: PAPER 0: INK 7: CLS
  20 LET alt = 100
  30 LET spd = 0
  40 LET fuel = 50
  50 PRINT AT 1, 2; "ALT:         SPD:         FUEL:"
  60 PRINT AT 21, 0; "================================"
  70 LET spd = spd + 1
  80 IF INKEY$ = " " AND fuel > 0 THEN LET spd = spd - 2: LET fuel = fuel - 1
  90 IF spd < 0 THEN LET spd = 0
 100 LET prev = alt
 110 LET alt = alt - spd
 120 IF alt <= 0 THEN LET alt = 0
 130 PRINT AT 1, 7; alt; "  "
 140 PRINT AT 1, 19; spd; "  "
 150 PRINT AT 1, 31; fuel; "  "
 160 LET row = 20 - INT (alt / 5)
 170 IF row < 3 THEN LET row = 3
 180 IF row > 20 THEN LET row = 20
 190 LET prow = 20 - INT (prev / 5)
 200 IF prow < 3 THEN LET prow = 3
 210 IF prow > 20 THEN LET prow = 20
 220 PRINT AT prow, 15; " "
 230 PRINT AT row, 15; "V"
 240 PAUSE 3
 250 IF alt = 0 AND spd <= 3 THEN GO TO 400
 260 IF alt = 0 AND spd > 3 THEN GO TO 500
 270 GO TO 70
 400 PRINT AT 10, 10; INK 4; "TOUCHDOWN!"
 410 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20
 420 STOP
 500 PRINT AT 10, 10; INK 2; "CRASH!"
 510 BEEP 0.5, -10
 520 STOP
