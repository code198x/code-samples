   1 REM Word Scramble v2
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
  36 PAUSE 0
  38 LET sc=0
  40 FOR n=1 TO 10
  42 READ w$
  44 REM === Scramble ===
  46 LET t$=w$
  48 LET s$=""
  50 IF LEN t$=0 THEN GO TO 58
  52 LET p=INT (RND*LEN t$)+1
  54 LET s$=s$+t$(p TO p)
  56 LET t$=t$(1 TO p-1)+t$(p+1 TO LEN t$)
  57 GO TO 50
  58 IF s$=w$ THEN GO TO 46
  60 REM === Display round ===
  62 CLS
  64 FOR i=0 TO 31
  66 PRINT AT 0,i; PAPER 2;" "
  68 NEXT i
  70 PRINT AT 0,1; PAPER 2; INK 7;"Round ";n
  72 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
  74 PRINT AT 4,4; INK 5;"Unscramble this word:"
  76 REM === Draw letter boxes ===
  78 LET c=(32-LEN s$*2)/2
  80 FOR i=1 TO LEN s$
  82 PRINT AT 9,c+i*2-2; INK 3;"_"
  84 NEXT i
  86 REM === Animated scramble reveal ===
  88 FOR i=1 TO LEN s$
  90 PRINT AT 8,c+i*2-2; INK 6; BRIGHT 1;s$(i TO i)
  92 BEEP 0.05,5+i
  94 NEXT i
  98 PRINT AT 14,2;
 100 INPUT "Your guess? ";g$
 102 IF g$=w$ THEN GO TO 140
 104 REM === Wrong ===
 106 PRINT AT 12,4; INK 2; BRIGHT 1;"Wrong!"
 108 BEEP 0.3,-5
 110 PAUSE 25
 112 REM === Reveal correct answer ===
 114 FOR i=1 TO LEN w$
 116 PRINT AT 9,c+i*2-2; INK 2; BRIGHT 1;w$(i TO i)
 118 BEEP 0.08,i*2
 120 NEXT i
 122 PAUSE 50
 124 GO TO 170
 140 REM === Correct ===
 142 LET sc=sc+1
 144 PRINT AT 12,4; INK 4; BRIGHT 1;"Correct!"
 146 REM === Victory reveal ===
 148 FOR i=1 TO LEN w$
 150 PRINT AT 9,c+i*2-2; INK 4; BRIGHT 1;w$(i TO i)
 152 BEEP 0.06,10+i*2
 154 NEXT i
 156 PAUSE 50
 170 REM === Next round ===
 172 NEXT n
 180 REM === Results ===
 182 CLS
 184 FOR i=0 TO 31
 186 PRINT AT 0,i; PAPER 2;" "
 188 NEXT i
 190 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" WORD SCRAMBLE "
 192 PRINT AT 4,10; INK 7; BRIGHT 1;"GAME OVER"
 194 PRINT AT 7,8; INK 5;"Score: ";sc;" out of 10"
 196 IF sc=10 THEN PRINT AT 10,10; INK 4; BRIGHT 1;"Perfect!": GO TO 210
 198 IF sc>=7 THEN PRINT AT 10,8; INK 6; BRIGHT 1;"Word wizard!": GO TO 210
 200 IF sc>=4 THEN PRINT AT 10,8; INK 5;"Not bad!": GO TO 210
 202 PRINT AT 10,6; INK 3;"Keep practising!"
 210 PRINT AT 14,6; INK 7;"Press any key to exit"
 212 PAUSE 0
 214 BORDER 7: PAPER 7: INK 0: CLS
 216 PRINT "Thanks for playing!"
 218 STOP
 900 DATA "cat","sun","bird","fish","lemon"
 910 DATA "planet","castle","trumpet","dinosaur","adventure"
