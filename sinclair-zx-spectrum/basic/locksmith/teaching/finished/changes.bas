20 PRINT AT 3,7; INK 5; "L O C K S M I T H"
30 PRINT AT 5,5; INK 6; "+--------------------+"
40 PRINT AT 6,5; INK 6; "+   ?   ?   ?   ?    +"
50 PRINT AT 7,5; INK 6; "+--------------------+"
60 PRINT AT 10,2; INK 7; "Four digits. Each from 1 to 6."
70 PRINT AT 11,2; "Digits may repeat. Ten tries."
80 PRINT AT 13,2; INK 4; "EXACT: right digit and place"
90 PRINT AT 14,2; INK 6; "OTHER: right digit elsewhere"
100 PRINT AT 16,2; INK 7; "Each digit counts only once."
110 PRINT AT 19,6; INK 5; "S starts. Q quits."
120 GO SUB 9000
130 LET k$ = INKEY$: IF k$ = "" THEN GO TO 130
140 IF k$ = "q" OR k$ = "Q" THEN GO TO 8000
150 IF k$ <> "s" AND k$ <> "S" THEN GO TO 130
