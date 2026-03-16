  48 IF INKEY$="" THEN GO TO 48
  50 LET k$=INKEY$
  52 PRINT AT r,c;" "
  54 IF k$="q" AND r>1 THEN LET r=r-1
  56 IF k$="a" AND r<20 THEN LET r=r+1
  58 IF k$="o" AND c>0 THEN LET c=c-1
  60 IF k$="p" AND c<31 THEN LET c=c+1
  62 LET m=m+1
  64 PRINT AT 21,15; INK 5;m;"  "
  66 IF INKEY$<>"" THEN GO TO 66
  68 GO TO 30
