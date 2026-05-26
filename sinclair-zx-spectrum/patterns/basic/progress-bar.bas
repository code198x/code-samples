  10 REM Progress bar
  20 REM Pattern: reusable across games
  30 REM
  40 REM Usage:
  50 REM   LET v=75: LET vm=100: GO SUB 2200
  60 REM
  70 REM Parameters:
  80 REM   v  = current value
  90 REM   vm = maximum value
 100 REM
 110 REM Draws a 28-cell horizontal bar at row br
 120 REM Colour shifts: blue -> yellow -> red -> white
 130 REM Set br before first call (default row 15)
 140 REM
 150 REM Example: temperature bar
 160 REM   LET br=15: LET v=100-ABS(guess-target)
 170 REM   LET vm=100: GO SUB 2200
 180 REM
2200 REM === Progress bar ===
2210 LET h=INT (v*28/vm)
2220 IF h>28 THEN LET h=28
2230 IF h<0 THEN LET h=0
2240 FOR i=1 TO 28
2250 IF i>h THEN PRINT AT br,1+i; PAPER 0;" ": GO TO 2300
2260 IF i<=9 THEN PRINT AT br,1+i; PAPER 1;" "
2270 IF i>9 AND i<=18 THEN PRINT AT br,1+i; PAPER 6;" "
2280 IF i>18 AND i<=24 THEN PRINT AT br,1+i; PAPER 2;" "
2290 IF i>24 THEN PRINT AT br,1+i; PAPER 7;" "
2300 NEXT i
2310 RETURN
