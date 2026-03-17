   1 REM Word Scramble v1
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Title screen ===
  12 FOR i=0 TO 31
  14 PRINT AT 0,i; PAPER 2;" "
  16 NEXT i
  18 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" WORD SCRAMBLE "
  20 PRINT AT 4,4; INK 5;"Unscramble the letters to"
  22 PRINT AT 5,4; INK 5;"find the hidden word!"
  24 PRINT AT 8,4; INK 6;"10 rounds. Words get longer."
  26 PRINT AT 10,4; INK 7;"Type your answer and press"
  28 PRINT AT 11,4; INK 7;"ENTER to guess."
  30 PRINT AT 15,4; INK 3;"Short words are easy..."
  32 PRINT AT 16,4; INK 2;"Long words are not."
  34 PRINT AT 21,6; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  36 IF INKEY$="" THEN GO TO 36
  38 IF INKEY$<>"" THEN GO TO 38
  40 LET sc=0
  50 FOR n=1 TO 10
  52 READ w$
  54 REM === Scramble ===
  56 LET t$=w$
  58 LET s$=""
  60 IF LEN t$=0 THEN GO TO 72
  62 LET p=INT (RND*LEN t$)+1
  64 LET s$=s$+t$(p TO p)
  66 LET t$=t$(1 TO p-1)+t$(p+1 TO LEN t$)
  68 GO TO 60
  70 REM === Display round ===
  72 CLS
  74 FOR i=0 TO 31
  76 PRINT AT 0,i; PAPER 2;" "
  78 NEXT i
  80 PRINT AT 0,1; PAPER 2; INK 7;"Round ";n
  82 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
  84 PRINT AT 4,4; INK 5;"Unscramble this word:"
  86 REM === Animated scramble reveal ===
  88 LET cx=(32-LEN s$)/2
  90 FOR i=1 TO LEN s$
  92 PRINT AT 8,cx+i-1; INK 6; BRIGHT 1;s$(i TO i)
  94 BEEP 0.05,5+i
  96 NEXT i
  98 REM === Underline ===
 100 FOR i=1 TO LEN w$
 102 PRINT AT 10,cx+i-1; INK 3;"_"
 104 NEXT i
 108 PRINT AT 14,2;
 110 INPUT "Your guess? ";g$
 112 IF g$=w$ THEN GO TO 150
 114 REM === Wrong ===
 116 PRINT AT 12,4; INK 2; BRIGHT 1;"Wrong!"
 118 BEEP 0.3,-5
 120 PAUSE 25
 122 REM === Reveal answer letter by letter ===
 124 FOR i=1 TO LEN w$
 126 PRINT AT 10,cx+i-1; INK 2; BRIGHT 1;w$(i TO i)
 128 BEEP 0.08,i*2
 130 NEXT i
 132 PAUSE 50
 134 GO TO 180
 150 REM === Correct ===
 152 LET sc=sc+1
 154 PRINT AT 12,4; INK 4; BRIGHT 1;"Correct!"
 156 REM === Victory reveal ===
 158 FOR i=1 TO LEN w$
 160 PRINT AT 10,cx+i-1; INK 4; BRIGHT 1;w$(i TO i)
 162 BEEP 0.06,10+i*2
 164 NEXT i
 166 PAUSE 50
 180 REM === Next round ===
 182 NEXT n
 190 REM === Results ===
 192 CLS
 194 FOR i=0 TO 31
 196 PRINT AT 0,i; PAPER 2;" "
 198 NEXT i
 200 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" WORD SCRAMBLE "
 202 PRINT AT 4,10; INK 7; BRIGHT 1;"GAME OVER"
 204 PRINT AT 7,8; INK 5;"Score: ";sc;" out of 10"
 206 IF sc=10 THEN PRINT AT 10,10; INK 4; BRIGHT 1;"Perfect!": GO TO 220
 208 IF sc>=7 THEN PRINT AT 10,8; INK 6; BRIGHT 1;"Word wizard!": GO TO 220
 210 IF sc>=4 THEN PRINT AT 10,8; INK 5;"Not bad!": GO TO 220
 212 PRINT AT 10,6; INK 3;"Keep practising!"
 220 PRINT AT 14,6; INK 7;"Press any key to exit"
 222 IF INKEY$="" THEN GO TO 222
 224 BORDER 7: PAPER 7: INK 0: CLS
 226 PRINT "Thanks for playing!"
 228 STOP
 900 DATA "CAT","SUN","BIRD","FISH","LEMON"
 910 DATA "PLANET","CASTLE","TRUMPET","DINOSAUR","ADVENTURE"
