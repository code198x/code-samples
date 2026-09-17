10 BORDER 0: PAPER 0: INK 7: BRIGHT 1: CLS
200 LET t = 1
220 LET g$ = "": GO SUB 1000
240 GO SUB 2000: STOP
1000 CLS
1010 PRINT AT 0,1; INK 5; "LOCKSMITH"; AT 0,21; INK 7; "PRACTICE"
1020 PRINT AT 2,1; INK 7; "Build a four-digit guess."
1050 PRINT AT 16,1; INK 5; "------------------------------"
1060 PRINT AT 20,1; INK 7; "Four spaces for four digits."
1080 RETURN
2000 PRINT AT 17,1; INK 5; "TRY "; t; " "; AT 17,7; INK 7; "_ _ _ _"
2020 RETURN
