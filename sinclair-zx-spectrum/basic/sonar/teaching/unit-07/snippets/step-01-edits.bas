15 GO SUB 5000
300 IF d = 0 THEN GO TO 6000
5000 BORDER 1: PAPER 0: INK 7: CLS
5010 PRINT AT 2, 9; "SONAR - BANDS"
5020 PRINT AT 5, 1; "Find one object on an 8x8 grid."
5030 PRINT AT 7, 1; "Enter a row, then a column."
5040 PRINT AT 9, 1; "N = near 1-2. M = medium 3-4."
5050 PRINT AT 11, 1; "F = far 5+. Rows plus columns."
5060 PRINT AT 13, 1; "Old clues stay. > marks latest."
5070 PRINT AT 15, 1; "* means found. No probe limit."
5080 PRINT AT 18, 1; "Q leaves from any prompt."
5090 INPUT "ENTER to search, Q quits: "; LINE a$
5100 IF a$ = "q" OR a$ = "Q" THEN GO TO 9000
5110 IF a$ <> "" THEN GO TO 5000
5120 RETURN
6000 INPUT "R another round, Q quits: "; LINE a$
6010 IF LEN a$ > 16 THEN GO SUB 1000
6020 IF a$ = "q" OR a$ = "Q" THEN GO TO 9000
6030 IF a$ = "r" OR a$ = "R" THEN GO TO 20
6040 LET s$ = "Enter R for another round or Q.": GO SUB 2600
6050 GO TO 6000
