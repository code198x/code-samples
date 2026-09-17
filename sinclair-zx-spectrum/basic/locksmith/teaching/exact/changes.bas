200 DIM c(4): LET c(1) = 1: LET c(2) = 1: LET c(3) = 2: LET c(4) = 2
220 LET t = 1: LET g$ = "": GO SUB 1000
410 GO SUB 3000
420 GO SUB 4000: PRINT AT 18,2; "                            "
470 GO TO 230
1020 PRINT AT 2,1; INK 7; "Practice code: 1122"
1030 PRINT AT 4,1; INK 5; "TRY"; AT 4,7; "CODE"; AT 4,19; "EXACT"
1040 PRINT AT 5,1; INK 1; "-"; AT 5,7; ". . . ."; AT 5,21; "."
3000 DIM g(4): LET bulls = 0
3010 FOR i = 1 TO 4: LET g(i) = VAL g$(i): IF g(i) = c(i) THEN LET bulls = bulls + 1
3020 NEXT i
3120 RETURN
4000 PRINT AT 4 + t,1; INK 7; t
4010 FOR i = 1 TO 4: PRINT AT 4 + t,5 + 2 * i; PAPER 1; INK 7; g$(i): NEXT i
4020 PRINT AT 4 + t,21; INK 4; bulls
4030 RETURN
