5 REM === DESIGNING UDGs ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 REM Define UDG I: player ship
30 FOR i = 0 TO 7
40 READ a
50 POKE USR "I" + i, a
60 NEXT i
70 DATA 16, 56, 56, 124, 254, 254, 130, 0
80 REM Define UDG E: bullet
90 FOR i = 0 TO 7
100 READ a
110 POKE USR "E" + i, a
120 NEXT i
130 DATA 16, 56, 16, 16, 0, 0, 0, 0
140 PRINT AT 3, 10; BRIGHT 1; "BLOCKSTORM"
150 PRINT AT 6, 2; INK 6; "Designing UDGs on paper"
160 PRINT AT 8, 4; INK 7; "Player ship: "; CHR$ 152
170 PRINT AT 10, 4; INK 7; "Bullet:      "; CHR$ 148
180 PRINT AT 13, 2; INK 6; "Each 1 in binary = pixel on"
190 PRINT AT 14, 2; INK 6; "Each 0 in binary = pixel off"
200 PRINT AT 16, 2; INK 7; "Row 1: 00010000 = 16"
210 PRINT AT 17, 2; INK 7; "Row 2: 00111000 = 56"
220 PRINT AT 20, 6; INK 7; "Press any key"
230 PAUSE 0
