5 REM === COLOUR AND INK ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 REM INK sets the drawing colour.
25 REM 0=black, 1=blue, 2=red, 3=magenta
27 REM 4=green, 5=cyan, 6=yellow, 7=white
30 REM Draw white nodes (INK 7)
40 CIRCLE INK 7; 80, 100, 3
50 CIRCLE INK 7; 176, 100, 3
60 REM Draw a green line between them (INK 4)
70 PLOT INK 4; 80, 100
80 DRAW INK 4; 96, 0
90 PRINT AT 0, 0; INK 7; "White nodes, green connection"
100 REM Draw another pair with a cyan line
110 CIRCLE INK 7; 80, 60, 3
120 CIRCLE INK 7; 176, 60, 3
130 PLOT INK 5; 80, 60
140 DRAW INK 5; 96, 0
150 PRINT AT 2, 0; INK 5; "Cyan is colour 5"
160 PRINT AT 3, 0; INK 4; "Green is colour 4"
170 STOP
