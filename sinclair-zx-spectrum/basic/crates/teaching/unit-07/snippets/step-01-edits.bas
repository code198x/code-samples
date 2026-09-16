20 DIM g(8,8): LET moves = 0: LET won = 0: GO SUB 4000
86 IF left = 0 THEN LET won = 1
4000 RESTORE 8000
4010 FOR r = 1 TO 8: READ m$
4020 FOR c = 1 TO 8: LET b$ = m$(c): LET v = -1
4030 IF b$ = "-" THEN LET v = 0
4040 IF b$ = "#" THEN LET v = 1
4050 IF b$ = "." THEN LET v = 2
4060 IF b$ = "C" THEN LET v = 3
4070 IF b$ = "*" THEN LET v = 4
4080 IF b$ = "P" OR b$ = "+" THEN LET pr = r: LET pc = c: LET v = 0
4090 IF b$ = "+" THEN LET v = 2
4100 LET g(r,c) = v
4110 NEXT c: NEXT r: RETURN
8000 DATA "########"
8010 DATA "#------#"
8020 DATA "#--#.--#"
8030 DATA "#--#---#"
8040 DATA "#--C---#"
8050 DATA "#-P----#"
8060 DATA "#------#"
8070 DATA "########"
