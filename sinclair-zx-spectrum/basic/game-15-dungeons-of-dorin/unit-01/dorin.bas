5 REM === DUNGEONS OF DORIN ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 PRINT AT 3, 4; INK 7; BRIGHT 1; "DUNGEONS OF DORIN"
30 PRINT AT 6, 2; INK 6; "Descend ten floors of"
35 PRINT AT 7, 2; INK 6; "darkness. Find the Heart."
40 PRINT AT 10, 2; INK 7; "Press any key to begin"
50 PAUSE 0
60 CLS
70 REM === define stats ===
80 LET h = 20: LET z = 20: LET a = 3: LET f = 2
90 PRINT AT 3, 6; INK 7; BRIGHT 1; "YOUR HERO"
100 PRINT AT 6, 4; INK 7; "HP: "; h; "/"; z
110 PRINT AT 8, 4; INK 4; "Attack:  "; a
120 PRINT AT 10, 4; INK 5; "Defence: "; f
130 PRINT AT 14, 4; INK 6; "Your quest begins..."
140 STOP
