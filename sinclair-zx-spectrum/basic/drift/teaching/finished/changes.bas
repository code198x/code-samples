10 GO SUB 7000: GO SUB 5000
5000 BORDER 0: PAPER 0: INK 7: CLS
5010 PRINT AT 3,13; INK 5; "DRIFT"
5020 PRINT AT 6,3; "Space has no brakes."
5030 PRINT AT 8,3; "O/P turn. SPACE fires thrust."
5040 PRINT AT 10,3; "Release thrust: keep drifting."
5050 PRINT AT 12,3; "Turn back and burn to brake."
5060 PRINT AT 14,3; "DOCK OK means slow enough."
5070 PRINT AT 16,3; "DRIFT: E/W and N/S motion."
5080 PRINT AT 18,3; "R retries. Q quits."
5090 PRINT AT 20,11; INK 6; "S starts."
5100 LET k$ = INKEY$
5110 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5120 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5100
5130 RETURN
