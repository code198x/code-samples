  10 REM Steering with dx/dy
  20 BORDER 0: PAPER 0: INK 6: CLS
  30 LET x=15: LET y=10
  40 LET dx=1: LET dy=0
  50 LET sp=8: LET sc=0
  60 REM === Game loop ===
  70 PRINT AT y,x;"@"
  80 REM === PEEK timing ===
  90 LET f=PEEK 23672
 100 IF PEEK 23672=f THEN GO TO 100
 110 LET sc=sc+1
 120 IF sc<sp THEN GO TO 90
 130 LET sc=0
 140 REM === Input ===
 150 LET k$=INKEY$
 160 IF k$="o" THEN IF dx<>1 THEN LET dx=-1: LET dy=0
 170 IF k$="p" THEN IF dx<>-1 THEN LET dx=1: LET dy=0
 180 IF k$="q" THEN IF dy<>1 THEN LET dx=0: LET dy=-1
 190 IF k$="a" THEN IF dy<>-1 THEN LET dx=0: LET dy=1
 200 REM === Move ===
 210 PRINT AT y,x;" "
 220 LET x=x+dx: LET y=y+dy
 230 IF x<0 OR x>31 OR y<0 OR y>21 THEN STOP
 240 GO TO 70
