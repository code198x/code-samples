10 GO SUB 7000: GO SUB 5000
5000 BORDER 0: PAPER 0: INK 7: CLS
5010 PRINT AT 3,11; INK 5; "BRICK BASH"
5020 PRINT AT 6,3; "One ball. Eighteen bricks."
5030 PRINT AT 9,3; "O left     P right"
5040 PRINT AT 11,3; "SPACE serves when ready."
5050 PRINT AT 13,3; "Use the paddle edges to aim."
5060 PRINT AT 15,3; "Clear the wall to finish."
5070 PRINT AT 17,3; "R retries. Q quits."
5080 PRINT AT 20,10; INK 6; "S starts."
5090 LET k$ = INKEY$
5100 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5110 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5090
5120 RETURN
