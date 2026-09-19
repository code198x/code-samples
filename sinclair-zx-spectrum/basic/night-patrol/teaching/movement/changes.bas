10 GO SUB 7000: GO SUB 7100
100 LET x=3: LET y=16: LET steps=0
140 GO SUB 1000
200 LET k$=INKEY$
210 IF k$="q" OR k$="Q" THEN GO TO 9000
220 IF k$="r" OR k$="R" THEN GO SUB 8100: GO TO 100
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
370 GO TO 470
470 GO TO 200
1022 LET r=3: LET c=27: GO SUB 2000
1024 LET r=y: LET c=x: GO SUB 2000
1030 PRINT AT 20,1; "I up  J left  K down  L right"
1040 PRINT AT 21,1; "R retry              Q quit";
2000 LET z$=" ": LET colour=7: LET paper=0
2010 IF m$(r,c)=CHR$ 145 THEN LET z$=CHR$ 145: LET colour=1
2030 IF r=3 AND c=27 THEN LET z$=CHR$ 146: LET colour=5
2040 IF r=16 AND c=3 THEN LET z$=CHR$ 147: LET colour=4
2060 IF r=y AND c=x THEN LET z$=CHR$ 144: LET colour=7
2080 PRINT AT r+1,c; PAPER paper; INK colour; BRIGHT 1;z$: RETURN
8100 IF INKEY$<>"" THEN GO TO 8100
8110 RETURN
9000 PAPER 0: INK 7: BRIGHT 0: PRINT AT 21,0; "Finished. RUN to try again.     ";: STOP
