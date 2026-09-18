4040 IF b(5) = 0 THEN LET mv = 5: LET a$ = "centre": RETURN
4050 RESTORE 9530
4060 FOR j = 1 TO 4: READ v
4070 IF mv = 0 AND b(v) = 0 THEN LET mv = v
4080 NEXT j
4090 IF mv > 0 THEN LET a$ = "corner": RETURN
4100 FOR j = 1 TO 9: IF b(j) = 0 THEN LET mv = j
4110 NEXT j: LET a$ = "edge": RETURN
9530 DATA 1,3,7,9
