   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 LET sc=0
  20 FOR n=1 TO 4
  22 READ q$,a$,b$,c$,d$,r$
  24 CLS
  26 FOR i=0 TO 31
  28 PRINT AT 0,i; PAPER 2;" "
  30 NEXT i
  32 PRINT AT 0,1; PAPER 2; INK 7;"Q";n;" of 4"
  34 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
  36 PRINT AT 4,4; INK 7;q$
  38 PRINT AT 8,6; INK 7;"A: ";a$
  40 PRINT AT 10,6; INK 7;"B: ";b$
  42 PRINT AT 12,6; INK 7;"C: ";c$
  44 PRINT AT 14,6; INK 7;"D: ";d$
  46 PRINT AT 18,4; INK 5;"Press A, B, C or D"
  48 LET k$=INKEY$
  50 IF k$<>"a" AND k$<>"b" AND k$<>"c" AND k$<>"d" THEN GO TO 48
  52 IF k$=r$ THEN GO TO 80
  54 REM === Wrong ===
  56 BORDER 2
  58 LET y=0
  60 IF k$="a" THEN LET y=8
  62 IF k$="b" THEN LET y=10
  64 IF k$="c" THEN LET y=12
  66 IF k$="d" THEN LET y=14
  68 PRINT AT y,4; INK 2; BRIGHT 1;">"
  70 LET y=0
  72 IF r$="a" THEN LET y=8
  74 IF r$="b" THEN LET y=10
  76 IF r$="c" THEN LET y=12
  78 IF r$="d" THEN LET y=14
  79 PRINT AT y,4; INK 4; BRIGHT 1;">"
  77 BEEP 0.3,-5
  78 BORDER 0
  79 PAUSE 75
  GO TO 100
  80 REM === Correct ===
  82 LET sc=sc+1
  84 BORDER 4
  86 LET y=0
  88 IF k$="a" THEN LET y=8
  90 IF k$="b" THEN LET y=10
  92 IF k$="c" THEN LET y=12
  94 IF k$="d" THEN LET y=14
  96 PRINT AT y,4; INK 4; BRIGHT 1;">"
  97 BEEP 0.1,12: BEEP 0.1,16: BEEP 0.15,19
  98 BORDER 0
  99 PAUSE 50
 100 NEXT n
 110 CLS
 120 PRINT AT 4,10; INK 5;"Score: ";sc;" out of 4"
 500 DATA "Closest planet to the Sun?","Mercury","Venus","Earth","Mars","a"
 510 DATA "Who built the pyramids?","Romans","Egyptians","Vikings","Greeks","b"
 520 DATA "Capital of France?","London","Berlin","Madrid","Paris","d"
 530 DATA "Instrument with 88 keys?","Guitar","Drums","Violin","Piano","d"
