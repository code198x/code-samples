  10 BORDER 0: PAPER 0: INK 7: CLS
 100 LET pop = 100: LET grain = 2800
 110 LET land = 1000
 120 CLS
 130 LET a$ = "*** YEARFALL ***": LET y = 0: GO SUB 9000
 150 PRINT AT 3, 2; "Population: "; pop
 160 PRINT AT 4, 2; "Grain: "; grain
 170 PRINT AT 5, 2; "Land: "; land; " acres"

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
