10 BORDER 0: PAPER 0: INK 7: BRIGHT 0: CLS
200 LET wins=0: LET losses=0: LET round=1
210 LET w$="BOTTLE"
250 LET d$="": LET t$="": LET m$="": LET left=7: LET u$="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
260 FOR i=1 TO LEN w$: LET d$=d$+"_": NEXT i
270 LET a$="Choose a letter.": GO SUB 2000
300 GO SUB 2500
310 GO SUB 8000
320 IF CODE k$=13 THEN GO TO 600
330 LET c=CODE k$
340 IF c<97 OR c>122 THEN GO TO 310
350 LET g$=CHR$ (c-32): LET seen=0
355 IF t$="" THEN GO TO 390
360 FOR i=1 TO LEN t$: IF t$(i)=g$ THEN LET seen=1
370 NEXT i
380 IF seen=1 THEN LET a$=g$+" already tried. No cost.": GO TO 300
390 LET t$=t$+g$: LET found=0: LET u$(c-96 TO c-96)="."
395 PRINT AT 14+INT ((c-97)/13),3+2*((c-97)-13*INT ((c-97)/13)); "."
400 FOR i=1 TO LEN w$
410 IF w$(i)=g$ THEN LET d$(i TO i)=g$: LET found=found+1
420 NEXT i
430 IF found>0 THEN LET a$=g$+" reveals "+STR$ found+" letter(s)."
440 IF found=0 THEN LET left=left-1: LET m$=m$+g$: LET a$=g$+" is not in the word."
450 IF d$=w$ THEN LET wins=wins+1: LET a$="Word found!": GO TO 700
460 IF left=0 THEN LET losses=losses+1: LET a$="No guesses left. Word revealed.": GO TO 700
470 GO TO 300
600 CLS: PRINT AT 3,10; INK 5; BRIGHT 1; "C I P H E R"
610 PRINT AT 7,3; "PAUSED - word stays hidden."
620 PRINT AT 10,3; "C continues this word."
630 PRINT AT 12,3; "R resets words and scores."
640 PRINT AT 14,3; "Q quits to BASIC."
650 GO SUB 8000
660 IF k$="q" THEN STOP
670 IF k$="r" THEN GO TO 200
680 IF k$="c" THEN GO SUB 2000: GO TO 300
690 GO TO 650
700 GO SUB 2000
710 PRINT AT 6,16-LEN w$; INK 4; BRIGHT 1;
720 FOR i=1 TO LEN w$: PRINT w$(i);" ";: NEXT i
730 IF left=0 THEN PRINT AT 6,16-LEN w$; INK 6; BRIGHT 1;: FOR i=1 TO LEN w$: PRINT w$(i);" ";: NEXT i
740 PRINT AT 21,1; "SPACE next. R resets. Q quits. "
750 GO SUB 8000
760 IF k$="q" THEN STOP
770 IF k$="r" THEN GO TO 200
780 IF k$=" " THEN LET round=round+1: GO TO 210
790 GO TO 750
2000 CLS
2010 PRINT AT 1,2; INK 5; BRIGHT 1; "CIPHER"; AT 1,19; "WORD ";round
2020 PRINT AT 3,2; "Won ";wins;"   Lost ";losses
2110 PRINT AT 12,2; INK 5; "UNTRIED LETTERS"
2120 FOR j=1 TO 26
2160 PRINT AT 14+INT ((j-1)/13),3+2*((j-1)-13*INT ((j-1)/13)); INK 7;
2170 PRINT u$(j);
2190 NEXT j
2200 PRINT AT 21,1; "Letter guesses. ENTER pauses."
2205 GO SUB 2500
2210 RETURN
2500 PRINT AT 6,16-LEN d$; INK 7; BRIGHT 1;
2510 FOR i=1 TO LEN d$: PRINT d$(i);" ";: NEXT i
2520 PRINT AT 9,2; INK 6; "MISTAKES LEFT: ";left
2530 PRINT AT 10,2; INK 6;
2540 FOR i=1 TO 7
2550 IF i<=left THEN PRINT "O ";
2560 IF i>left THEN PRINT ". ";
2570 NEXT i
2580 PRINT AT 17,2; "Misses: ";m$
2590 LET b$=a$+"                              ": PRINT AT 19,1; INK 6; b$(TO 30)
2600 RETURN
8000 LET k$=INKEY$
8010 IF INKEY$<>"" THEN GO TO 8010
8020 LET k$=INKEY$: IF k$="" THEN GO TO 8020
8030 IF CODE k$>=65 AND CODE k$<=90 THEN LET k$=CHR$ (CODE k$+32)
8040 RETURN
