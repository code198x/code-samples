  10 REM Treasure Hunt — text version
  20 RANDOMIZE
  30 CLS
  40 LET tx=INT (RND*28)+2
  50 LET ty=INT (RND*18)+2
  60 LET x=15: LET y=10
  70 LET m=0
  80 PRINT AT y,x;"+"
  90 REM === Game loop ===
 100 LET k$=INKEY$
 110 IF k$="" THEN GO TO 100
 120 PRINT AT y,x;" "
 130 IF k$="q" THEN IF y>1 THEN LET y=y-1
 140 IF k$="a" THEN IF y<20 THEN LET y=y+1
 150 IF k$="o" THEN IF x>1 THEN LET x=x-1
 160 IF k$="p" THEN IF x<30 THEN LET x=x+1
 170 PRINT AT y,x;"+"
 180 LET m=m+1
 190 LET d=SQR ((x-tx)^2+(y-ty)^2)
 200 IF d<=3 THEN BORDER 7
 210 IF d>3 THEN IF d<=8 THEN BORDER 2
 220 IF d>8 THEN IF d<=16 THEN BORDER 1
 230 IF d>16 THEN BORDER 0
 240 IF x=tx THEN IF y=ty THEN PRINT AT 0,0;"Found in ";m;" moves!": STOP
 250 IF INKEY$<>"" THEN GO TO 250
 260 GO TO 100
