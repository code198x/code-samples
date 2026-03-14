5 REM === CUSTOM CHARACTERS ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 PRINT AT 3, 10; BRIGHT 1; "BLOCKSTORM"
30 PRINT AT 6, 2; INK 6; "Learning to define UDGs"
40 REM Define UDG A: a simple block alien
50 FOR i = 0 TO 7
60 READ a
70 POKE USR "A" + i, a
80 NEXT i
90 DATA 36, 126, 219, 255, 255, 102, 66, 0
100 PRINT AT 10, 14; INK 4; "A = "; CHR$ 144
110 PRINT AT 12, 2; INK 7; "That character is a UDG."
120 PRINT AT 13, 2; INK 7; "We defined it with POKE USR."
130 PRINT AT 15, 2; INK 6; "Each row is 8 pixels wide."
140 PRINT AT 16, 2; INK 6; "8 rows = 8 bytes of DATA."
150 PRINT AT 20, 6; INK 7; "Press any key"
160 PAUSE 0
