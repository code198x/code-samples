  10 REM Progress bar
  20 REM Pattern: reusable across games
  30 REM
  40 REM Usage:
  50 REM   LET br=15: LET v=75: LET vm=100: GO SUB 2200
  60 REM
  70 REM Parameters:
  80 REM   v  = current value
  90 REM   vm = maximum value
 100 REM
 110 REM Draws a 28-cell horizontal bar at row br
 120 REM One colour for the whole bar: red when low,
 125 REM yellow in the middle, green when high
 130 REM Set br before first call (for example, 15)
 140 REM
 150 REM Example: closeness bar
 160 REM   LET br=15: LET v=100-ABS(guess-target)
 170 REM   LET vm=100: GO SUB 2200
 180 REM
2200 REM === Progress bar ===
2210 LET h=INT (v*28/vm)
2220 IF h>28 THEN LET h=28
2230 IF h<0 THEN LET h=0
2240 LET c=4: IF h<19 THEN LET c=6
2250 IF h<10 THEN LET c=2
2260 FOR i=1 TO 28
2270 IF i>h THEN PRINT AT br,1+i; PAPER 0;" ": GO TO 2290
2280 PRINT AT br,1+i; PAPER c;" "
2290 NEXT i
2300 RETURN
