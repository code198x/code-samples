  90 CLS
 100 LET alt = 100
 110 LET spd = 0
 150 LET spd = spd + 1
 160 IF INKEY$ = " " THEN LET spd = spd - 2
 170 IF spd < 0 THEN LET spd = 0
 190 LET alt = alt - spd
 200 IF alt <= 0 THEN LET alt = 0
 210 PRINT "ALT: "; alt; "  SPD: "; spd
 480 IF alt > 0 THEN GO TO 150
