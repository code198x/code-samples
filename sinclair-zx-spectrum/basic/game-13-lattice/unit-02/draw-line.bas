5 REM === DRAW A LINE ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 REM PLOT sets a starting pixel.
25 REM DRAW moves relative to that point.
30 REM DRAW dx, dy where dx and dy are offsets.
40 PLOT 64, 88
50 DRAW 128, 0
60 REM That drew a horizontal line from (64,88)
65 REM to (192,88). The DRAW offsets were
67 REM dx=128, dy=0.
70 PRINT AT 0, 0; "Horizontal line from PLOT+DRAW"
80 REM Now a diagonal line
90 PLOT 64, 140
100 DRAW 128, -80
110 PRINT AT 2, 0; "Diagonal line: DRAW 128,-80"
120 STOP
