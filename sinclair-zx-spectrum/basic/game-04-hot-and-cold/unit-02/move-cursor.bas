  10 CLS
  20 LET x=15: LET y=10
  30 PRINT AT y,x;"+"
  40 LET k$=INKEY$
  50 IF k$="" THEN GO TO 40
  60 PRINT AT y,x;" "
  70 IF k$="q" THEN LET y=y-1
  80 IF k$="a" THEN LET y=y+1
  90 IF k$="o" THEN LET x=x-1
 100 IF k$="p" THEN LET x=x+1
 110 PRINT AT y,x;"+"
 120 IF INKEY$<>"" THEN GO TO 120
 130 GO TO 40
