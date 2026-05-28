  10 BORDER 0: PAPER 0: INK 7: CLS
  90 CLS
 100 LET alt = 100
 110 LET spd = 0
 150 LET spd = spd + 1
 190 LET alt = alt - spd
 210 PRINT "ALT: "; alt; "  SPD: "; spd
 480 IF alt > 0 THEN GO TO 150

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
