10 GO SUB 7000: GO SUB 5000
440 IF eaten = 8 THEN LET e$ = "Eight snacks. Nicely done!": GO TO 4000
1020 PRINT AT 2,5; INK 7; "Keep some room to turn."
2500 PRINT AT 1,4; INK 7; "FOOD "; eaten; "/8"; AT 1,18; "LENGTH "; n; " "
5000 BORDER 0: PAPER 0: INK 7: CLS
5010 PRINT AT 3,11; INK 5; "TAIL CHASE"
5020 PRINT AT 6,1; "Eight snacks. One hungry snake."
5030 PRINT AT 9,3; "I up   J left   K down"
5040 PRINT AT 10,3; "L right"
5050 PRINT AT 12,1; "Keep moving. Leave room to turn."
5060 PRINT AT 14,1; "Walls and your own body end it."
5070 PRINT AT 16,1; "R retries. Q quits at any time."
5080 PRINT AT 19,6; INK 6; "S starts. Take a breath."
5090 LET k$ = INKEY$
5100 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5110 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5090
5120 RANDOMIZE: RETURN
