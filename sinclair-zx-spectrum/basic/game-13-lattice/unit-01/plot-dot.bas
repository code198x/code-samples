5 REM === PLOT A DOT ===
10 BORDER 0: PAPER 0: INK 7: CLS
20 REM The Spectrum screen is 256 pixels wide
25 REM and 176 pixels tall.
30 REM (0,0) is the bottom-left corner.
35 REM (255,175) is the top-right corner.
40 PLOT 128, 88
50 REM That dot is in the centre of the screen.
60 PRINT AT 0, 0; "A single white dot at 128,88"
70 STOP
