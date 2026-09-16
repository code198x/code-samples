10 GO SUB 7000: LET h$ = ""
15 LET room = 1
20 DIM g(8,8)
30 FOR r = 1 TO 8: FOR c = 1 TO 8
40 IF r = 1 OR r = 8 OR c = 1 OR c = 8 THEN LET g(r,c) = 1
50 NEXT c: NEXT r
60 LET g(3,4) = 1: LET g(4,4) = 1
70 LET g(3,5) = 2: LET g(5,4) = 3
80 LET pr = 6: LET pc = 3: LET moves = 0: LET won = 0
100 GO SUB 1000
110 STOP
1000 BORDER 0: PAPER 0: INK 7: CLS
1010 PRINT AT 0, 2; INK 5; "CRATES"; AT 0, 24; INK 7; "ROOM 0"; room
1040 FOR r = 1 TO 8: FOR c = 1 TO 8
1050 GO SUB 2000
1060 NEXT c: NEXT r
1080 RETURN
2000 LET y = 3 + 2 * (r - 1): LET x = 8 + 2 * (c - 1)
2010 LET z = g(r,c) + 1
2030 PRINT AT y,x; INK a(z); t$(z,1 TO 2); AT y+1,x; t$(z,3 TO 4)
2040 RETURN
