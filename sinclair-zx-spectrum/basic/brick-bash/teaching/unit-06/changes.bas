100 DIM g(3,6): LET left = 18: LET p = 14: LET x = 127: LET y = 40
120 FOR r = 1 TO 3: FOR c = 1 TO 6: LET g(r,c) = 1: NEXT c: NEXT r
130 GO SUB 1000
200 INPUT "Ball X (-1 quits)? ";tx
210 IF tx = -1 THEN GO TO 9000
220 INPUT "Ball Y? ";ty
230 GO SUB 2000
240 PRINT AT 20,0; "                                "; AT 20,0; "ROW ";br;" COL ";bc;" HIT ";hit
250 IF hit = 1 THEN GO SUB 2500
260 GO TO 200
1010 PRINT AT 0,2; INK 5; "BRICK BASH"; AT 0,21; INK 7; "BRICKS 18"
1020 PRINT AT 1,2; "Probe a ball position."
1040 FOR r = 1 TO 3: LET inkcol = 6
1050 IF r = 2 THEN LET inkcol = 3
1060 IF r = 3 THEN LET inkcol = 5
1070 FOR c = 1 TO 6: PRINT AT 2+2*r,4*c; INK inkcol; b$: NEXT c: NEXT r
1090 PRINT AT 21,2; INK 5; "X = -1 quits the inspector";
2000 LET hit = 0: LET br = 1 + INT ((143 - ty) / 16): LET bc = 1 + INT ((tx + 1 - 32) / 32)
2010 IF br < 1 OR br > 3 OR bc < 1 OR bc > 6 THEN RETURN
2020 IF ty + 1 < 152 - 16 * br OR tx > 32 * bc + 23 THEN RETURN
2030 IF g(br,bc) = 0 THEN RETURN
2040 LET hit = 1: RETURN
2500 LET g(br,bc) = 0: LET left = left - 1
2510 PRINT AT 2+2*br,4*bc; "   "; AT 0,28; INK 7; left; " "
