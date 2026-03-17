   1 REM Word Scramble - Unit 7
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 PRINT AT 0,1; PAPER 2; INK 7;"Round 1"
  18 PRINT AT 0,22; PAPER 2; INK 6;"Score: 0"
  20 LET sc=0
  30 FOR n=1 TO 10
  32 READ w$
  34 REM === Scramble ===
  36 LET t$=w$
  38 LET s$=""
  40 IF LEN t$=0 THEN GO TO 48
  42 LET p=INT (RND*LEN t$)+1
  44 LET s$=s$+t$(p TO p)
  46 LET t$=t$(1 TO p-1)+t$(p+1 TO LEN t$)
  47 GO TO 40
  48 IF s$=w$ THEN GO TO 36
  50 REM === Display round ===
  52 CLS
  54 FOR i=0 TO 31
  56 PRINT AT 0,i; PAPER 2;" "
  58 NEXT i
  60 PRINT AT 0,1; PAPER 2; INK 7;"Round ";n
  62 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
  64 PRINT AT 4,10; INK 5;"Unscramble:"
  66 LET c=(32-LEN s$*2)/2
  68 FOR i=1 TO LEN s$
  70 PRINT AT 8,c+i*2-2; PAPER 1;" "
  72 PRINT AT 9,c+i*2-2; PAPER 1;" "
  74 NEXT i
  76 FOR i=1 TO LEN s$
  78 PRINT AT 8,c+i*2-2; PAPER 1; INK 6; BRIGHT 1;s$(i TO i)
  80 BEEP 0.05,5+i*2
  82 NEXT i
  84 INPUT "Your guess? ";g$
  86 IF g$=w$ THEN GO TO 120
  88 REM === Wrong ===
  90 BORDER 2
  92 LET m$="Wrong!"
  94 PRINT AT 12,(32-LEN m$)/2; INK 2; BRIGHT 1;m$
  96 BEEP 0.3,-5
  98 BORDER 0
 100 PAUSE 15
 102 FOR i=1 TO LEN w$
 104 PRINT AT 8,c+i*2-2; PAPER 1; INK 2; BRIGHT 1;w$(i TO i)
 106 BEEP 0.08,i*2
 108 NEXT i
 110 PAUSE 60
 112 GO TO 150
 120 REM === Correct ===
 122 LET sc=sc+1
 124 BORDER 4
 126 LET m$="Correct!"
 128 PRINT AT 12,(32-LEN m$)/2; INK 4; BRIGHT 1;m$
 130 FOR i=1 TO LEN w$
 132 PRINT AT 8,c+i*2-2; PAPER 4; INK 7; BRIGHT 1;w$(i TO i)
 134 BEEP 0.06,10+i*2
 136 NEXT i
 138 BEEP 0.1,24
 140 PAUSE 40
 142 BORDER 0
 150 NEXT n
 160 CLS
 170 PRINT AT 4,8; INK 5;"Score: ";sc;" out of 10"
 900 DATA "cat","sun","bird","fish","lemon"
 910 DATA "planet","castle","trumpet","dinosaur","adventure"
