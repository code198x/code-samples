10 BORDER 0: PAPER 0: INK 7: CLS
20 INK 7
30 PRINT AT 5, 9; "NIGHT PATROL"
40 INK 5
50 PRINT AT 9, 3; "Sneak past the guards and"
60 PRINT AT 10, 3; "collect the objective."
70 PRINT AT 13, 3; "Controls:"
80 PRINT AT 14, 5; INK 5; "Q"; INK 7; " Up    "; INK 5; "A"; INK 7; " Down"
90 PRINT AT 15, 5; INK 5; "O"; INK 7; " Left   "; INK 5; "P"; INK 7; " Right"
100 PRINT AT 18, 3; "Avoid the guard sightlines!"
110 INK 3: PRINT AT 20, 5; "Press any key to start": INK 7
120 IF INKEY$ = "" THEN GO TO 120
