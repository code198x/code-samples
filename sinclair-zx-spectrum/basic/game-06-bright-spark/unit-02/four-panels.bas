  10 BORDER 0: PAPER 0: INK 7: CLS
 110 CLS
 120 GO SUB 540
 130 STOP
 540 REM --- Draw all panels ---
 550 PAPER 2
 560 FOR r = 2 TO 9: PRINT AT r, 1; "       1      ": NEXT r
 570 PAPER 1
 580 FOR r = 2 TO 9: PRINT AT r, 17; "       2      ": NEXT r
 590 PAPER 4
 600 FOR r = 12 TO 19: PRINT AT r, 1; "       3      ": NEXT r
 610 PAPER 6
 620 FOR r = 12 TO 19: PRINT AT r, 17; "       4      ": NEXT r
 630 PAPER 0: RETURN

9000 PRINT AT y, (32 - LEN a$) / 2; BRIGHT 1; a$
9010 RETURN
