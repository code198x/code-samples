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
  46 PRINT AT 18,4;
  48 INPUT "Answer? ";k$
  50 IF k$=r$ THEN PRINT AT 18,4; INK 4; BRIGHT 1;"Correct!": LET sc=sc+1: GO TO 60
  52 PRINT AT 18,4; INK 2; BRIGHT 1;"Wrong! It was ";r$
  60 PAUSE 50
  62 NEXT n
  64 CLS
  66 PRINT AT 4,10; INK 5;"Score: ";sc;" out of 4"
 500 DATA "Closest planet to the Sun?","Mercury","Venus","Earth","Mars","a"
 510 DATA "Who built the pyramids?","Romans","Egyptians","Vikings","Greeks","b"
 520 DATA "Capital of France?","London","Berlin","Madrid","Paris","d"
 530 DATA "Instrument with 88 keys?","Guitar","Drums","Violin","Piano","d"
