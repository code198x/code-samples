   1 REM Colour Flood v2 - Simon Says
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Game screen ===
  12 FOR i=0 TO 31
  14 PRINT AT 0,i; PAPER 1;" "
  16 NEXT i
  18 PRINT AT 0,8; PAPER 1; INK 7; BRIGHT 1;" COLOUR FLOOD "
  20 REM === Colour key ===
  22 FOR i=1 TO 7
  24 PRINT AT 2+i,1; PAPER i;" ";i;" "
  26 NEXT i
  28 PRINT AT 11,1; INK 5;"Score: 0"
  30 PRINT AT 13,1; INK 6;"Watch the border..."
  32 LET s$=""
  34 LET sc=0
  40 REM === New round ===
  42 LET s$=s$+STR$ (INT (RND*7)+1)
  44 PRINT AT 11,8; INK 5;sc;"  "
  46 PRINT AT 13,1; INK 6;"Watch...            "
  48 PAUSE 30
  50 REM === Play sequence ===
  52 FOR i=1 TO LEN s$
  54 LET c=VAL s$(i)
  56 BORDER c
  58 BEEP 0.3,c*3
  60 PAUSE 10
  62 BORDER 0
  64 PAUSE 8
  66 NEXT i
  70 REM === Player repeats ===
  72 PRINT AT 13,1; INK 2; BRIGHT 1;"Your turn!          "
  74 FOR i=1 TO LEN s$
  76 IF INKEY$<>"" THEN GO TO 76
  78 IF INKEY$="" THEN GO TO 78
  80 LET k$=INKEY$
  82 LET c=VAL s$(i)
  84 IF k$=STR$ c THEN GO TO 100
  86 REM === Wrong! ===
  88 BORDER 2
  90 BEEP 0.5,-10
  92 PRINT AT 13,1; INK 2; BRIGHT 1;"Wrong! Game over.   "
  94 PRINT AT 15,1; INK 7;"You scored ";sc
  96 IF sc<=3 THEN PRINT AT 17,1; INK 3;"Keep practising!"
  97 IF sc>3 AND sc<=7 THEN PRINT AT 17,1; INK 6;"Good memory!"
  98 IF sc>7 THEN PRINT AT 17,1; INK 4; BRIGHT 1;"Incredible!"
  99 BORDER 0: STOP
 100 REM === Correct keypress ===
 102 BORDER VAL k$
 104 BEEP 0.15,VAL k$*3
 106 PAUSE 5
 108 BORDER 0
 110 NEXT i
 112 REM === Round complete ===
 114 LET sc=sc+1
 116 BORDER 4
 118 BEEP 0.1,20
 120 PRINT AT 13,1; INK 4; BRIGHT 1;"Correct! Score: ";sc;"  "
 122 PAUSE 25
 124 BORDER 0
 126 GO TO 40
