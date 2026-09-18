4000 LET mark = 2: GO SUB 4500
4010 IF mv > 0 THEN LET a$ = "win": RETURN
4020 LET mark = 1: GO SUB 4500
4030 IF mv > 0 THEN LET a$ = "block": RETURN
4040 FOR j = 1 TO 9
4050 IF mv = 0 AND b(j) = 0 THEN LET mv = j
4060 NEXT j: LET a$ = "first empty": RETURN
4500 LET mv = 0: RESTORE 9500
4510 FOR w = 1 TO 8: READ p,q,f
4520 IF mv = 0 AND b(p) = mark AND b(q) = mark AND b(f) = 0 THEN LET mv = f
4530 IF mv = 0 AND b(p) = mark AND b(f) = mark AND b(q) = 0 THEN LET mv = q
4540 IF mv = 0 AND b(q) = mark AND b(f) = mark AND b(p) = 0 THEN LET mv = p
4550 NEXT w: RETURN
