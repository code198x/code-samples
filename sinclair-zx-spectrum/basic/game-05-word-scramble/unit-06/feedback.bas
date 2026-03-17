   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" WORD SCRAMBLE "
  20 PRINT AT 4,10; INK 5;"Unscramble:"
  30 LET w$="trumpet"
  32 LET t$=w$
  34 LET s$=""
  36 IF LEN t$=0 THEN GO TO 44
  38 LET p=INT (RND*LEN t$)+1
  40 LET s$=s$+t$(p TO p)
  42 LET t$=t$(1 TO p-1)+t$(p+1 TO LEN t$)
  43 GO TO 36
  44 IF s$=w$ THEN GO TO 32
  50 LET c=(32-LEN s$*2)/2
  52 FOR i=1 TO LEN s$
  54 PRINT AT 8,c+i*2-2; PAPER 1;" "
  56 PRINT AT 9,c+i*2-2; PAPER 1;" "
  58 NEXT i
  60 FOR i=1 TO LEN s$
  62 PRINT AT 8,c+i*2-2; PAPER 1; INK 6; BRIGHT 1;s$(i TO i)
  64 BEEP 0.05,5+i*2
  66 NEXT i
  70 INPUT "Your guess? ";g$
  72 IF g$=w$ THEN GO TO 100
  74 REM === Wrong ===
  76 BORDER 2
  78 LET m$="Wrong!"
  80 PRINT AT 12,(32-LEN m$)/2; INK 2; BRIGHT 1;m$
  82 BEEP 0.3,-5
  84 BORDER 0
  86 PAUSE 15
  88 FOR i=1 TO LEN w$
  90 PRINT AT 8,c+i*2-2; PAPER 1; INK 2; BRIGHT 1;w$(i TO i)
  92 BEEP 0.08,i*2
  94 NEXT i
  96 STOP
 100 REM === Correct ===
 102 BORDER 4
 104 LET m$="Correct!"
 106 PRINT AT 12,(32-LEN m$)/2; INK 4; BRIGHT 1;m$
 108 FOR i=1 TO LEN w$
 110 PRINT AT 8,c+i*2-2; PAPER 4; INK 7; BRIGHT 1;w$(i TO i)
 112 BEEP 0.06,10+i*2
 114 NEXT i
 116 BEEP 0.1,24
 118 BORDER 0
