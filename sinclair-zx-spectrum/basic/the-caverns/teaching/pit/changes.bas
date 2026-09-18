250 LET rm = 1: LET pit = 7: LET found = 0: LET turns = 0
410 IF dest = pit THEN LET rm = dest: LET ending = 1: GO TO 5000
1120 IF v = pit THEN PRINT AT y,15; INK 6; "Cold draught"
5000 IF ending = 1 THEN LET h$ = "The cold tunnel hid a pit."
5030 GO SUB 1000
5040 PRINT AT 16,2; INK 6; "                            "
5060 IF ending <> 3 THEN PRINT AT 16,2; INK 6; "YOUR EXPEDITION ENDS."
5070 PRINT AT 20,2; INK 7; "R: try again   Q: quit       ": PRINT AT 21,2; "                            "
5080 GO SUB 9000
5090 LET k$ = INKEY$: IF k$ = "" THEN GO TO 5090
5100 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
5110 IF k$ = "r" OR k$ = "R" THEN GO TO 200
5120 GO TO 5090
