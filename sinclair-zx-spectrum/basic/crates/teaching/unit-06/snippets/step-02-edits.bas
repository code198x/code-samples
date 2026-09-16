10 GO SUB 7000: GO SUB 5000
140 IF won = 1 THEN GO TO 110
590 IF left = 0 THEN LET won = 1
2510 IF won = 1 THEN PRINT AT 19, 2; INK 4; "Delivered! R replay / Q quit"
5000 BORDER 0: PAPER 0: INK 7: CLS: LET h$ = ""
5010 PRINT AT 2, 12; INK 5; "CRATES"
5020 PRINT AT 5, 2; INK 7; "A small warehouse puzzle."
5030 PRINT AT 7, 1; "I up, J left, K down, L right."
5040 PRINT AT 9, 1; "Push crates onto the targets."
5050 PRINT AT 11, 1; "You can push, but never pull."
5060 PRINT AT 13, 1; "R restarts the room. Q quits."
5070 PRINT AT 15, 1; "One step per press. Take time."
5080 PRINT AT 18, 1; "S starts. Q quits."
5090 GO SUB 3000
5100 IF k$ = "q" OR k$ = "Q" THEN GO TO 9000
5110 IF k$ <> "s" AND k$ <> "S" THEN GO TO 5090
5120 RETURN
