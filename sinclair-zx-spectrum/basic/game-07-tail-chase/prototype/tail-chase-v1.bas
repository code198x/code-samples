  10 REM Tail Chase
  20 RANDOMIZE
  30 BORDER 0: PAPER 0: INK 7: CLS
  40 REM === Title ===
  50 LET r=0: LET t$="TAIL CHASE": INK 4: BRIGHT 1: GO SUB 3000: BRIGHT 0
  60 LET r=21: LET t$="Q/A/O/P to steer": INK 5: GO SUB 3000
  70 REM === Draw walls ===
  80 FOR i=1 TO 30
  90 PRINT AT 1,i; INK 1;"#"
 100 PRINT AT 20,i; INK 1;"#"
 110 NEXT i
 120 FOR i=1 TO 20
 130 PRINT AT i,1; INK 1;"#"
 140 PRINT AT i,30; INK 1;"#"
 150 NEXT i
 160 REM === Snake setup ===
 170 DIM x(200): DIM y(200)
 180 LET h=3: REM head index
 190 LET x(1)=14: LET y(1)=10
 200 LET x(2)=15: LET y(2)=10
 210 LET x(3)=16: LET y(3)=10
 220 LET dx=1: LET dy=0
 230 LET sc=0: LET sp=8
 240 REM === Draw initial snake ===
 250 FOR i=1 TO h
 260 PRINT AT y(i),x(i); INK 4;"o"
 270 NEXT i
 280 PRINT AT y(h),x(h); INK 6; BRIGHT 1;"@"
 290 REM === Place food ===
 300 GO SUB 2500
 310 REM === Score display ===
 320 PRINT AT 0,22; INK 6;"Score: ";sc;"  "
 400 REM === Game loop ===
 410 REM === Timing — wait for frame counter ===
 420 LET f=PEEK 23672
 430 IF PEEK 23672=f THEN GO TO 430
 440 LET sp=sp-1
 450 IF sp>0 THEN GO TO 420
 460 LET sp=8
 470 REM === Read input ===
 480 LET k$=INKEY$
 490 IF k$="o" THEN IF dx<>1 THEN LET dx=-1: LET dy=0
 500 IF k$="p" THEN IF dx<>-1 THEN LET dx=1: LET dy=0
 510 IF k$="q" THEN IF dy<>1 THEN LET dx=0: LET dy=-1
 520 IF k$="a" THEN IF dy<>-1 THEN LET dx=0: LET dy=1
 530 REM === Calculate new head position ===
 540 LET nx=x(h)+dx
 550 LET ny=y(h)+dy
 560 REM === Collision check ===
 570 IF nx<=1 OR nx>=30 THEN GO TO 800
 580 IF ny<=1 OR ny>=20 THEN GO TO 800
 590 REM === Self collision ===
 600 FOR i=1 TO h
 610 IF nx=x(i) AND ny=y(i) THEN GO TO 800
 620 NEXT i
 630 REM === Check food ===
 640 LET ate=0
 650 IF nx=fx AND ny=fy THEN LET ate=1: LET sc=sc+1: BEEP 0.05,20: PRINT AT 0,29; INK 6;sc;"  ": GO SUB 2500
 660 REM === Move snake ===
 670 IF ate=0 THEN PRINT AT y(1),x(1);" ": FOR i=1 TO h-1: LET x(i)=x(i+1): LET y(i)=y(i+1): NEXT i: LET x(h)=nx: LET y(h)=ny
 680 IF ate=1 THEN LET h=h+1: LET x(h)=nx: LET y(h)=ny
 690 REM === Draw snake ===
 700 IF h>1 THEN PRINT AT y(h-1),x(h-1); INK 4;"o"
 710 PRINT AT y(h),x(h); INK 6; BRIGHT 1;"@"
 720 GO TO 400
 800 REM === Game over ===
 810 BORDER 2
 820 FOR i=1 TO 10
 830 BEEP 0.03,INT (RND*20)
 840 NEXT i
 850 BORDER 0
 860 LET r=10: LET t$="GAME OVER": INK 2: BRIGHT 1: FLASH 1: GO SUB 3000: FLASH 0: BRIGHT 0
 870 LET r=12: LET t$="Score: "+STR$ sc: INK 5: GO SUB 3000
 880 LET r=14: LET t$="Length: "+STR$ h: INK 7: GO SUB 3000
 890 STOP
2500 REM === Place food ===
2510 LET fx=INT (RND*27)+2
2520 LET fy=INT (RND*17)+2
2530 REM === Check not on snake ===
2540 FOR i=1 TO h
2550 IF fx=x(i) AND fy=y(i) THEN GO TO 2510
2560 NEXT i
2570 PRINT AT fy,fx; INK 2; BRIGHT 1; FLASH 1;"*"; FLASH 0
2580 RETURN
3000 REM === Centre text t$ on row r ===
3010 PRINT AT r,(32-LEN t$)/2;t$
3020 RETURN
