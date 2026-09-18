330 GO SUB 3000: IF winner > 0 OR moves = 9 THEN GO TO 4900
3000 LET winner = 0: LET wl = 0: RESTORE 9500
3010 FOR w = 1 TO 8: READ p,q,f
3020 IF b(p) <> 0 AND b(p) = b(q) AND b(q) = b(f) THEN LET winner = b(p): LET wl = w
3030 NEXT w: RETURN
4900 LET r$ = "DRAW. No line completed."
4910 IF winner = 1 THEN LET r$ = "X WINS. Three in a row."
4920 IF winner = 2 THEN LET r$ = "O WINS. Three in a row."
4930 IF wl > 0 THEN GO SUB 6000
4940 PRINT AT 18,2; INK 6; r$; "      "
6000 RESTORE 9500: FOR w = 1 TO wl: READ p,q,f: NEXT w
6010 LET row = INT ((p - 1) / 3): LET col = p - 1 - row * 3
6020 LET sx = 80 + col * 48: LET sy = 132 - row * 40
6030 LET row = INT ((f - 1) / 3): LET col = f - 1 - row * 3
6040 INK 6: PLOT sx,sy: DRAW 80 + col * 48 - sx,132 - row * 40 - sy: RETURN
9500 DATA 1,2,3,4,5,6,7,8,9
9510 DATA 1,4,7,2,5,8,3,6,9
9520 DATA 1,5,9,3,5,7
