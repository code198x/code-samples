200 LET wins=0: LET losses=0: LET round=1
210 LET w$="BOTTLE"
250 LET d$="": LET t$="": LET m$="": LET left=7
270 LET a$="Choose a letter.": GO SUB 2000
300 GO SUB 2500
320 IF CODE k$=13 THEN GO TO 600
350 LET g$=CHR$ (c-32): LET seen=0
355 IF t$="" THEN GO TO 390
360 FOR i=1 TO LEN t$: IF t$(i)=g$ THEN LET seen=1
370 NEXT i
380 IF seen=1 THEN LET a$=g$+" already tried. No cost.": GO TO 300
390 LET t$=t$+g$: LET found=0
440 IF found=0 THEN LET left=left-1: LET m$=m$+g$: LET a$=g$+" is not in the word."
450 IF d$=w$ THEN LET wins=wins+1: LET a$="Word found!": GO TO 700
460 IF left=0 THEN LET losses=losses+1: LET a$="No guesses left. Word revealed.": GO TO 700
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
710 PRINT AT 6,2;w$
740 PRINT AT 21,1; "SPACE next. R resets. Q quits. "
750 GO SUB 8000
760 IF k$="q" THEN STOP
770 IF k$="r" THEN GO TO 200
780 IF k$=" " THEN LET round=round+1: GO TO 210
790 GO TO 750
2000 CLS
2010 PRINT AT 1,2; INK 5; BRIGHT 1; "CIPHER"; AT 1,19; "WORD ";round
2020 PRINT AT 3,2; "Won ";wins;"   Lost ";losses
2200 PRINT AT 21,1; "Letter guesses. ENTER pauses."
2205 GO SUB 2500
2210 RETURN
2500 PRINT AT 6,2;d$
2520 PRINT AT 9,2; INK 6; "MISTAKES LEFT: ";left
2580 PRINT AT 17,2; "Misses: ";m$
2590 LET b$=a$+"                              ": PRINT AT 19,1; INK 6; b$(TO 30)
2600 RETURN
