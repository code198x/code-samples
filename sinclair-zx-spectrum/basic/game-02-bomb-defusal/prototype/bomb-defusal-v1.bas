   1 REM Bomb Defusal v1
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Title screen ===
  12 FOR i=0 TO 31
  14 PRINT AT 0,i; PAPER 2;" "
  16 NEXT i
  18 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" BOMB DEFUSAL "
  20 PRINT AT 4,4; INK 5;"A bomb is ticking!"
  22 PRINT AT 6,4; INK 7;"Cut the right wire before"
  24 PRINT AT 7,4; INK 7;"time runs out."
  26 PRINT AT 10,4; INK 6;"Press 1, 2, 3 or 4"
  28 PRINT AT 11,4; INK 6;"to cut a wire."
  30 PRINT AT 14,4; INK 2;"5 bombs. Each one faster."
  32 PRINT AT 21,5; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  34 PAUSE 0
  36 LET sc=0
  38 FOR b=1 TO 5
  40 REM === Set up bomb ===
  42 LET w=INT (RND*4)+1
  44 LET t=12-b*2
  46 IF t<4 THEN LET t=4
  48 CLS
  50 FOR i=0 TO 31
  52 PRINT AT 0,i; PAPER 2;" "
  54 NEXT i
  56 PRINT AT 0,1; PAPER 2; INK 7;"Bomb ";b;" of 5"
  58 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
  60 REM === Draw bomb ===
  62 PRINT AT 4,12; INK 2; BRIGHT 1;"[BOMB]"
  64 REM === Draw wires ===
  66 PRINT AT 8,4; INK 1; BRIGHT 1;"1: "; PAPER 1;"        "
  68 PRINT AT 10,4; INK 2; BRIGHT 1;"2: "; PAPER 2;"        "
  70 PRINT AT 12,4; INK 4; BRIGHT 1;"3: "; PAPER 4;"        "
  72 PRINT AT 14,4; INK 6; BRIGHT 1;"4: "; PAPER 6;"        "
  74 PRINT AT 18,4; INK 5;"Cut a wire: press 1-4"
  76 REM === Countdown ===
  78 FOR c=t TO 1 STEP -1
  80 PRINT AT 4,22; INK 7; BRIGHT 1;c;" "
  82 IF c>6 THEN BORDER 0
  84 IF c<=6 AND c>3 THEN BORDER 6
  86 IF c<=3 THEN BORDER 2
  88 BEEP 0.08,20-c
  90 REM === Check for keypress ===
  92 FOR f=1 TO 8
  94 LET k$=INKEY$
  96 IF k$="1" OR k$="2" OR k$="3" OR k$="4" THEN GO TO 130
  98 PAUSE 1
 100 NEXT f
 102 NEXT c
 104 REM === Time ran out ===
 106 BORDER 2
 108 BEEP 0.5,-10
 110 PRINT AT 18,4; INK 2; BRIGHT 1;"BOOM! Too slow!          "
 112 PAUSE 75
 114 BORDER 0
 116 GO TO 200
 130 REM === Wire cut ===
 132 LET g=VAL k$
 134 IF g=w THEN GO TO 160
 136 REM === Wrong wire ===
 138 BORDER 2
 140 BEEP 0.1,-5: BEEP 0.1,-8: BEEP 0.3,-12
 142 PRINT AT 18,4; INK 2; BRIGHT 1;"BOOM! Wrong wire!        "
 144 REM === Flash the correct wire ===
 146 LET y=6+w*2
 148 PRINT AT y,3; INK 4; BRIGHT 1; FLASH 1;">"
 150 PAUSE 75
 152 BORDER 0
 154 GO TO 200
 160 REM === Defused! ===
 162 LET sc=sc+1
 164 BORDER 4
 166 LET y=6+g*2
 168 PRINT AT y,3; INK 4; BRIGHT 1;">"
 170 BEEP 0.1,12: BEEP 0.1,16: BEEP 0.2,19
 172 PRINT AT 18,4; INK 4; BRIGHT 1;"DEFUSED!                 "
 174 PAUSE 50
 176 BORDER 0
 200 REM === Next bomb ===
 202 NEXT b
 210 REM === Results ===
 212 CLS
 214 FOR i=0 TO 31
 216 PRINT AT 0,i; PAPER 2;" "
 218 NEXT i
 220 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" BOMB DEFUSAL "
 222 PRINT AT 4,11; INK 7; BRIGHT 1;"RESULTS"
 224 REM === Animated score ===
 226 FOR i=0 TO sc
 228 PRINT AT 7,10; INK 5;"Defused: ";i;" of 5  "
 230 IF i<sc THEN BEEP 0.08,10+i*4
 232 NEXT i
 234 BEEP 0.2,24
 236 IF sc=5 THEN LET m$="Bomb expert!": INK 4: BRIGHT 1: GO TO 246
 238 IF sc>=3 THEN LET m$="Steady hands!": INK 6: BRIGHT 1: GO TO 246
 240 IF sc>=1 THEN LET m$="Needs practice!": INK 5: GO TO 246
 242 LET m$="Boom boom boom!": INK 2
 246 PRINT AT 10,(32-LEN m$)/2;m$
 248 BRIGHT 0
 250 PRINT AT 16,5; INK 7;"Press any key to exit"
 252 PAUSE 0
 254 BORDER 7: PAPER 7: INK 0: CLS
 256 STOP
