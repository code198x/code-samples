  10 REM Hot and Cold
  20 RANDOMIZE
  30 BORDER 0: PAPER 0: INK 7: CLS
  40 REM === Title ===
  50 FOR i=0 TO 31: PRINT AT 0,i; PAPER 3;" ": NEXT i
  60 LET r=0: LET t$="HOT AND COLD": PAPER 3: INK 7: BRIGHT 1: GO SUB 3000: BRIGHT 0: PAPER 0
  70 LET tm=0
  80 REM === Five rounds ===
  90 FOR n=1 TO 5
 100 LET tr=INT (RND*18)+2
 110 LET tc=INT (RND*28)+2
 120 LET y=10: LET x=15
 130 LET m=0
 140 PRINT AT 21,0; INK 5;"Round ";n;"  Moves: 0    Total: ";tm;"  "
 150 REM === Draw player ===
 160 PRINT AT y,x; INK 6; BRIGHT 1;"+"
 200 REM === Game loop ===
 210 LET d=SQR ((x-tc)^2+(y-tr)^2)
 220 IF d<1 THEN GO TO 500
 230 REM === Border feedback ===
 240 IF d<=3 THEN BORDER 7
 250 IF d>3 THEN IF d<=6 THEN BORDER 6
 260 IF d>6 THEN IF d<=10 THEN BORDER 2
 270 IF d>10 THEN IF d<=16 THEN BORDER 3
 280 IF d>16 THEN IF d<=24 THEN BORDER 1
 290 IF d>24 THEN BORDER 0
 300 REM === Wait for key ===
 310 IF INKEY$="" THEN GO TO 310
 320 LET k$=INKEY$
 330 REM === Erase player ===
 340 PRINT AT y,x;" "
 350 REM === Move ===
 360 IF k$="q" THEN IF y>1 THEN LET y=y-1
 370 IF k$="a" THEN IF y<20 THEN LET y=y+1
 380 IF k$="o" THEN IF x>1 THEN LET x=x-1
 390 IF k$="p" THEN IF x<30 THEN LET x=x+1
 400 REM === Draw player ===
 410 PRINT AT y,x; INK 6; BRIGHT 1;"+"
 420 LET m=m+1
 430 PRINT AT 21,15; INK 5;m;"  "
 440 REM === Key drain ===
 450 IF INKEY$<>"" THEN GO TO 450
 460 GO TO 200
 500 REM === Found! ===
 510 PRINT AT y,x; INK 4; BRIGHT 1; FLASH 1;"*"; FLASH 0
 520 BORDER 7
 530 BEEP 0.1,10: BEEP 0.1,15: BEEP 0.1,20: BEEP 0.2,25
 540 LET tm=tm+m
 550 PRINT AT 21,0; INK 4; BRIGHT 1;"Found! ";m;" moves  Total: ";tm;"    "; BRIGHT 0
 560 PAUSE 75
 570 PRINT AT y,x;" "
 580 BORDER 0
 590 NEXT n
 600 REM === Results ===
 610 CLS
 620 FOR i=0 TO 31: PRINT AT 0,i; PAPER 3;" ": NEXT i
 630 LET r=0: LET t$="HOT AND COLD": PAPER 3: INK 7: BRIGHT 1: GO SUB 3000: BRIGHT 0: PAPER 0
 640 LET r=4: LET t$="RESULTS": INK 7: BRIGHT 1: GO SUB 3000: BRIGHT 0
 650 LET r=7: LET t$="Total moves: "+STR$ tm: INK 5: GO SUB 3000
 660 IF tm<=40 THEN LET r=10: LET t$="Treasure hunter!": INK 4: BRIGHT 1: GO SUB 3000: BRIGHT 0
 670 IF tm>40 THEN IF tm<=70 THEN LET r=10: LET t$="Good instincts!": INK 6: GO SUB 3000
 680 IF tm>70 THEN IF tm<=100 THEN LET r=10: LET t$="Getting warmer!": INK 5: GO SUB 3000
 690 IF tm>100 THEN LET r=10: LET t$="Keep searching!": INK 3: GO SUB 3000
 700 STOP
3000 REM === Centre text t$ on row r ===
3010 PRINT AT r,(32-LEN t$)/2;t$
3020 RETURN
