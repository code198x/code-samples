10 GO SUB 7000: GO SUB 5000
5000 BORDER 0: PAPER 0: INK 7: CLS
5010 PRINT AT 3,11; INK 5; "QUICKSTEP"
5020 PRINT AT 6,3; "Six lanes. One halfway rest."
5030 PRINT AT 8,3; "I up   J left   K down"
5040 PRINT AT 9,3; "L right"
5050 PRINT AT 11,3; "Step into a gap, then watch."
5060 PRINT AT 13,3; "Plan beyond the next lane."
5070 PRINT AT 15,3; "Reach the green exit at top."
5080 PRINT AT 17,3; "R retries. Q quits."
5090 PRINT AT 20,11; INK 6; "S starts."
5100 LET k$ = INKEY$
5110 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5120 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5100
5130 RETURN
