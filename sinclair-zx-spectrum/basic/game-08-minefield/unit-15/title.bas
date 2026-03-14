10 BORDER 0: PAPER 0: INK 7: CLS
20 INK 6
30 PRINT AT 3, 10; "MINEFIELD"
40 INK 7
50 PRINT AT 7, 3; "Reveal all safe cells to win."
60 PRINT AT 8, 3; "Hit a mine and its game over!"
70 PRINT AT 11, 3; "Controls:"
80 PRINT AT 12, 5; INK 5; "Q"; INK 7; " Up    "; INK 5; "A"; INK 7; " Down"
90 PRINT AT 13, 5; INK 5; "O"; INK 7; " Left   "; INK 5; "P"; INK 7; " Right"
100 PRINT AT 14, 5; INK 5; "SPACE"; INK 7; " Reveal cell"
110 PRINT AT 15, 5; INK 5; "F"; INK 7; " Flag/unflag"
120 PRINT AT 18, 3; "Symbols:"
130 PRINT AT 19, 5; INK 1; "."; INK 7; " Hidden  "; INK 6; "3"; INK 7; " Number  "; INK 3; "F"; INK 7; " Flag"
140 INK 3
150 PRINT AT 21, 5; "Press any key to play"
160 INK 7
170 IF INKEY$ = "" THEN GO TO 170
