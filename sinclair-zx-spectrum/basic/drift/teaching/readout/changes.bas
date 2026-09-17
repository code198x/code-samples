110 GO SUB 1000: GO SUB 3000: GO SUB 6000
355 IF k$ = " " THEN GO SUB 6000
1020 PRINT AT 1,2; "SPEED"
1070 PRINT AT 20,2; INK 7; "DRIFT"
6000 LET speed = SQR (vx * vx + vy * vy)
6010 PRINT AT 1,8; INK 7; INT (10 * speed + .5) / 10; "  "
6020 IF vx * vx + vy * vy <= .16 THEN PRINT AT 1,17; INK 4; "SLOW    "
6030 IF vx * vx + vy * vy > .16 THEN PRINT AT 1,17; INK 6; "TOO FAST"
6040 LET u$ = "E": LET w$ = "N"
6050 IF vx < -.001 THEN LET u$ = "W"
6060 IF vy < -.001 THEN LET w$ = "S"
6070 IF ABS vx < .001 THEN LET u$ = "-"
6080 IF ABS vy < .001 THEN LET w$ = "-"
6090 PRINT AT 20,8; INK 7; u$; " "; INT (10 * ABS vx + .5) / 10; "  "; AT 20,16; w$; " "; INT (10 * ABS vy + .5) / 10; "  ": RETURN
