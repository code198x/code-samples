85 GO SUB 6000
475 IF v = 4 THEN LET left = left + 1
476 IF bv = 2 THEN LET left = left - 1
2505 PRINT AT 1, 18; INK 5; "GOALS "; total - left; "/"; total
6000 LET left = 0: LET total = 0: FOR r = 1 TO 8: FOR c = 1 TO 8
6010 IF g(r,c) = 2 THEN LET left = left + 1
6015 IF g(r,c) = 2 OR g(r,c) = 4 THEN LET total = total + 1
6020 NEXT c: NEXT r: RETURN
