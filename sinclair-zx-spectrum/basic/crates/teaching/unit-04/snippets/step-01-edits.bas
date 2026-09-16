130 IF k$ = "r" OR k$ = "R" THEN GO TO 20
240 IF v = 1 THEN GO TO 700
250 IF v = 3 OR v = 4 THEN GO TO 400
400 LET br = nr + dr: LET bc = nc + dc
410 IF br < 1 OR br > 8 OR bc < 1 OR bc > 8 THEN GO TO 700
420 LET bv = g(br,bc)
430 IF bv <> 0 THEN GO TO 700
440 LET g(nr,nc) = 0
460 LET g(br,bc) = 3
480 LET r = br: LET c = bc: GO SUB 2000
1030 PRINT AT 21, 6; INK 5; "R restart     Q quit";
