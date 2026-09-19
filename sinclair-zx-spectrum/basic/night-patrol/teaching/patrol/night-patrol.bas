10 GO SUB 7000: GO SUB 7100
100 LET x=3: LET y=16
120 LET gx=7: LET gy=5: LET gd=1
130 LET got=0: LET outcome=0: LET beat=0: LET steps=0
140 GO SUB 1000: GO SUB 3300: GO SUB 2500
150 LET tick=PEEK 23672
200 LET k$=INKEY$
210 IF k$="q" OR k$="Q" THEN GO TO 9000
220 IF k$="r" OR k$="R" THEN GO SUB 8100: GO TO 100
230 LET elapsed=PEEK 23672-tick: IF elapsed<0 THEN LET elapsed=elapsed+256
240 IF elapsed<8 THEN GO TO 200
250 LET k$=INKEY$
260 LET dx=0: LET dy=0
270 IF k$="i" OR k$="I" THEN LET dy=-1
280 IF k$="k" OR k$="K" THEN LET dy=1
290 IF k$="j" OR k$="J" THEN LET dx=-1
300 IF k$="l" OR k$="L" THEN LET dx=1
310 LET nx=x+dx: LET ny=y+dy
320 IF m$(ny,nx)=CHR$ 145 THEN GO TO 370
330 IF nx=x AND ny=y THEN GO TO 370
340 LET r=y: LET c=x: LET x=nx: LET y=ny: GO SUB 2000
350 LET steps=steps+1: LET r=y: LET c=x: GO SUB 2000
370 IF x=gx AND y=gy THEN LET outcome=1: GO TO 4000
380 IF x=27 AND y=3 AND got=0 THEN LET got=1: GO SUB 2500
390 IF x=3 AND y=16 AND got=1 THEN LET outcome=2: GO TO 4000
400 LET beat=beat+1: IF beat<2 THEN GO TO 470
410 LET beat=0: LET r=gy: LET c=gx
430 IF (gd=1 AND gx=24) OR (gd=2 AND gy=14) OR (gd=3 AND gx=7) OR (gd=4 AND gy=5) THEN LET gd=gd+1: IF gd=5 THEN LET gd=1
440 LET gx=gx+a(gd): LET gy=gy+b(gd): GO SUB 2000
455 GO SUB 3300
460 IF x=gx AND y=gy THEN LET outcome=1: GO TO 4000
470 LET tick=PEEK 23672: GO TO 200
1000 BORDER 0: PAPER 0: INK 7: BRIGHT 0: CLS
1010 PRINT AT 0,1; INK 5; BRIGHT 1; "NIGHT PATROL"; AT 0,20; "THE ARCHIVE"
1020 FOR r=1 TO 18: PRINT AT r+1,1; INK 1; BRIGHT 1;m$(r): NEXT r
1022 LET r=3: LET c=27: GO SUB 2000
1024 LET r=y: LET c=x: GO SUB 2000
1030 PRINT AT 20,1; "I up  J left  K down  L right"
1040 PRINT AT 21,1; "R retry              Q quit";
1050 RETURN
2000 LET z$=" ": LET colour=7: LET paper=0
2010 IF m$(r,c)=CHR$ 145 THEN LET z$=CHR$ 145: LET colour=1
2030 IF r=3 AND c=27 AND got=0 THEN LET z$=CHR$ 146: LET colour=5
2040 IF r=16 AND c=3 THEN LET z$=CHR$ 147: LET colour=4
2050 IF r=gy AND c=gx THEN LET z$=g$(gd): LET colour=6
2060 IF r=y AND c=x THEN LET z$=CHR$ 144: LET colour=7
2080 PRINT AT r+1,c; PAPER paper; INK colour; BRIGHT 1;z$: RETURN
2500 PRINT AT 1,1; INK 5; "TAKE THE FILE. RETURN TO EXIT. "
2510 IF got=1 THEN PRINT AT 1,1; INK 4; "FILE TAKEN. GET BACK TO EXIT.  "
2520 RETURN
3300 LET r=gy: LET c=gx: GO SUB 2000: RETURN
4000 LET r=y: LET c=x: GO SUB 2000
4010 IF outcome=1 THEN PRINT AT 1,1; INK 2; BRIGHT 1; "CAUGHT! Keep clear of the guard."
4020 IF outcome=2 THEN PRINT AT 1,1; INK 4; BRIGHT 1; "FILE RECOVERED. CLEAN GETAWAY! "
4030 PRINT AT 20,1; "R tries again. Q quits.      "
4040 GO SUB 8000
4050 IF k$="r" OR k$="R" THEN GO SUB 8100: GO TO 100
4060 IF k$="q" OR k$="Q" THEN GO TO 9000
4070 GO TO 4040
7000 RESTORE 7500: FOR j=0 TO 31: READ a: POKE USR "a"+j,a: NEXT j
7010 DIM a(4): DIM b(4): LET a(1)=1: LET b(2)=1: LET a(3)=-1: LET b(4)=-1
7020 LET g$=">v<"+CHR$ 94: RETURN
7100 DIM m$(18,30): RESTORE 7200
7110 FOR r=1 TO 18: READ m$(r): FOR c=1 TO 30
7120 IF m$(r,c)="#" THEN LET m$(r,c)=CHR$ 145
7130 NEXT c: NEXT r: RETURN
7200 DATA "##############################"
7210 DATA "##############################"
7220 DATA "###########  ############# ###"
7230 DATA "#####        #######     # ###"
7240 DATA "#####                      ###"
7250 DATA "#####     ######   #     #####"
7260 DATA "###### #########  ##### ######"
7270 DATA "######   ############   ######"
7280 DATA "######   ############   ######"
7290 DATA "######  ##############  ######"
7300 DATA "####   ################   ####"
7310 DATA "####   ####  ##########   ####"
7320 DATA "#####        #######     #####"
7330 DATA "#####                    #####"
7340 DATA "#####     ######   #     #####"
7350 DATA "##     #########  ############"
7360 DATA "##############################"
7370 DATA "##############################"
7500 DATA 24,24,0,60,90,24,36,66
7510 DATA 255,128,128,255,8,8,8,255
7520 DATA 126,66,90,66,90,66,126,0
7530 DATA 126,66,66,74,66,66,126,0
8000 GO SUB 8100
8010 LET k$=INKEY$: IF k$="" THEN GO TO 8010
8020 RETURN
8100 IF INKEY$<>"" THEN GO TO 8100
8110 RETURN
9000 PAPER 0: INK 7: BRIGHT 0: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
