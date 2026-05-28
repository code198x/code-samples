  10 BORDER 0: PAPER 0: INK 7: CLS
 100 CLS
 110 GO SUB 600
 120 STOP
 600 REM --- Draw all panels ---
 610 PAPER 2
 620 FOR r = 2 TO 9: PRINT AT r, 1; "       1      ": NEXT r
 630 PAPER 1
 640 FOR r = 2 TO 9: PRINT AT r, 17; "       2      ": NEXT r
 650 PAPER 4
 660 FOR r = 12 TO 19: PRINT AT r, 1; "       3      ": NEXT r
 670 PAPER 6
 680 FOR r = 12 TO 19: PRINT AT r, 17; "       4      ": NEXT r
 690 PAPER 0: RETURN

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
