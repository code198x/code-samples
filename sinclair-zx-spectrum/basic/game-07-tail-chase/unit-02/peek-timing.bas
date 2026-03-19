  10 REM Moving with PEEK timing
  20 BORDER 0: PAPER 0: INK 6: CLS
  30 LET x=2: LET y=10
  40 LET sp=8: LET sc=0
  50 REM === Game loop ===
  60 PRINT AT y,x;"@"
  70 REM === Wait for sp frames ===
  80 LET f=PEEK 23672
  90 IF PEEK 23672=f THEN GO TO 90
 100 LET sc=sc+1
 110 IF sc<sp THEN GO TO 80
 120 LET sc=0
 130 REM === Move ===
 140 PRINT AT y,x;" "
 150 LET x=x+1
 160 IF x>30 THEN STOP
 170 GO TO 60
