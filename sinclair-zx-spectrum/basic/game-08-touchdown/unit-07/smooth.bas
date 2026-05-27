  10 BORDER 0: PAPER 0: INK 7: CLS
  90 CLS
 100 LET alt = 100
 110 LET spd = 0
 120 LET fuel = 50
 130 PRINT AT 1, 1; "ALT:         SPD:         FUEL:"
 140 PRINT AT 21, 0; "================================"
 150 LET spd = spd + 1
 160 IF INKEY$ = " " AND fuel > 0 THEN LET spd = spd - 2: LET fuel = fuel - 1
 170 IF spd < 0 THEN LET spd = 0
 180 LET prev = alt
 190 LET alt = alt - spd
 200 IF alt <= 0 THEN LET alt = 0
 210 PRINT AT 1, 6; alt; "  "
 220 PRINT AT 1, 18; spd; "  "
 230 PRINT AT 1, 31; fuel; "  "
 360 LET row = 20 - INT (alt / 5)
 370 IF row < 4 THEN LET row = 4
 380 IF row > 20 THEN LET row = 20
 390 LET prow = 20 - INT (prev / 5)
 400 IF prow < 4 THEN LET prow = 4
 410 IF prow > 20 THEN LET prow = 20
 420 PRINT AT prow, 15; " "
 430 PRINT AT row, 15; "V"
 440 PAUSE 3
 450 IF alt = 0 AND spd <= 2 THEN PRINT AT 10, 8; "PERFECT LANDING!": STOP
 460 IF alt = 0 AND spd <= 5 THEN PRINT AT 10, 8; "Bumpy but safe": STOP
 470 IF alt = 0 AND spd > 5 THEN PRINT AT 10, 8; "CRASH!": STOP
 480 GO TO 150
