 100 CLS
 110 GO SUB 800
 115 STOP
 800 REM --- Draw all panels ---
 810 PAPER 2
 820 FOR r = 2 TO 9: PRINT AT r, 1; "       1      ": NEXT r
 830 PAPER 1
 840 FOR r = 2 TO 9: PRINT AT r, 17; "       2      ": NEXT r
 850 PAPER 4
 860 FOR r = 12 TO 19: PRINT AT r, 1; "       3      ": NEXT r
 870 PAPER 6
 880 FOR r = 12 TO 19: PRINT AT r, 17; "       4      ": NEXT r
 890 PAPER 0: RETURN
