  10 REM Screen frame
  20 REM Pattern: reusable across games
  30 REM
  40 REM Usage:
  50 REM   LET fc=1: GO SUB 3200
  60 REM
  70 REM Parameters:
  80 REM   fc = frame PAPER colour (e.g. 1=blue)
  90 REM
 100 REM Draws a 1-cell border around rows 0-21
 110 REM Interior is rows 1-20, cols 1-30
 120 REM Row 0 and 21 are solid bars (for title/footer)
 130 REM Cols 0 and 31 are side borders
 140 REM
 150 REM After calling, use centre text (GO SUB 3000)
 160 REM to place title in row 0 and footer in row 21:
 170 REM   LET r=0: LET t$="GAME TITLE": PAPER fc
 180 REM   INK 6: BRIGHT 1: GO SUB 3000
 190 REM
3200 REM === Draw screen frame in PAPER fc ===
3210 FOR i=0 TO 31
3220 PRINT AT 0,i; PAPER fc;" "
3230 PRINT AT 21,i; PAPER fc;" "
3240 NEXT i
3250 FOR i=1 TO 20
3260 PRINT AT i,0; PAPER fc;" "
3270 PRINT AT i,31; PAPER fc;" "
3280 NEXT i
3290 RETURN
