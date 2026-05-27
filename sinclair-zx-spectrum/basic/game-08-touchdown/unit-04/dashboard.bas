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
 190 LET alt = alt - spd
 200 IF alt <= 0 THEN LET alt = 0
 210 PRINT AT 1, 6; alt; "  "
 220 PRINT AT 1, 18; spd; "  "
 230 PRINT AT 1, 31; fuel; "  "
 480 IF alt > 0 THEN GO TO 150

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
