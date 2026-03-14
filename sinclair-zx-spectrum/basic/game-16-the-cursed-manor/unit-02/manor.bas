5 REM === THE CURSED MANOR ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 LET r$ = "Entrance Hall"
30 LET d$ = "A grand hall. A chandelier hangs still."
40 PRINT AT 0, 0; INK 7; BRIGHT 1; r$
50 PRINT AT 2, 0; INK 5; d$
60 PRINT AT 20, 0; INK 7; "> ";
70 INPUT LINE i$
80 PRINT AT 18, 0; INK 2; "Nothing happens yet."
90 GO TO 60
