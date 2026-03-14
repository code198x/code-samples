10 BORDER 0
20 PAPER 0
30 INK 7
40 CLS
50 INK 6
60 PRINT AT 3, 8; "TREASURE HUNT"
70 INK 7
80 PRINT AT 7, 4; "Collect all the coins to"
90 PRINT AT 8, 4; "clear each level."
100 PRINT AT 11, 4; "Avoid the hazards! They"
110 PRINT AT 12, 4; "cost you a life."
120 PRINT AT 15, 4; "Controls:"
130 PRINT AT 16, 6; INK 5; "Q"; INK 7; " Up    "; INK 5; "A"; INK 7; " Down"
140 PRINT AT 17, 6; INK 5; "O"; INK 7; " Left   "; INK 5; "P"; INK 7; " Right"
150 INK 3
160 PRINT AT 20, 5; "Press any key to play"
170 INK 7
180 IF INKEY$ = "" THEN GO TO 180
