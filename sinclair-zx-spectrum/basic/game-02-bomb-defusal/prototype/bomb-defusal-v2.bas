   1 REM Bomb Defusal v2
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Title screen ===
  12 FOR i=0 TO 31
  14 PRINT AT 0,i; PAPER 2;" "
  16 NEXT i
  18 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" BOMB DEFUSAL "
  20 PRINT AT 4,4; INK 5;"A bomb is ticking."
  22 PRINT AT 5,4; INK 5;"Cut the right wire before"
  24 PRINT AT 6,4; INK 5;"time runs out."
  26 PRINT AT 9,4; INK 7;"Press 1, 2, 3 or 4"
  28 PRINT AT 10,4; INK 7;"to cut a wire."
  30 PRINT AT 13,4; INK 2; BRIGHT 1;"5 bombs. Each one faster."
  32 PRINT AT 21,5; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  34 PAUSE 0
  36 LET sc=0
  38 FOR b=1 TO 5
  40 REM === Set up bomb ===
  42 LET w=INT (RND*4)+1
  44 LET t=11-b*2
  46 IF t<3 THEN LET t=3
  48 CLS
  50 FOR i=0 TO 31
  52 PRINT AT 0,i; PAPER 2;" "
  54 NEXT i
  56 PRINT AT 0,1; PAPER 2; INK 7;"Bomb ";b;" of 5"
  58 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
  60 REM === Draw wires ===
  62 PRINT AT 14,3; INK 1; BRIGHT 1;"1 "; PAPER 1;"          "
  64 PRINT AT 16,3; INK 2; BRIGHT 1;"2 "; PAPER 2;"          "
  66 PRINT AT 18,3; INK 4; BRIGHT 1;"3 "; PAPER 4;"          "
  68 PRINT AT 20,3; INK 6; BRIGHT 1;"4 "; PAPER 6;"          "
  70 REM === Fuse ===
  72 PRINT AT 10,5; INK 6;"~~~~~~~~~~~~~~~~"
  74 REM === Countdown ===
  76 FOR c=t TO 0 STEP -1
  78 REM === Big digit ===
  80 IF c>5 THEN LET pc=7
  82 IF c<=5 AND c>2 THEN LET pc=6
  84 IF c<=2 THEN LET pc=2
  86 LET dr=3: LET v=c: GO SUB 8200
  88 REM === Fuse shortens ===
  90 LET fl=INT (16*c/t)
  92 PRINT AT 10,5; INK 6;"                "
  94 IF fl>0 THEN PRINT AT 10,5; INK 6;
  96 IF fl>0 THEN FOR j=1 TO fl: PRINT "~";: NEXT j
  98 REM === Border colour ===
 100 IF c>5 THEN BORDER 0
 102 IF c<=5 AND c>2 THEN BORDER 6
 104 IF c<=2 THEN BORDER 2
 106 REM === Tick ===
 108 BEEP 0.06,5+((t-c)*3)
 110 REM === Check for keypress ===
 112 FOR f=1 TO 6
 114 LET k$=INKEY$
 116 IF k$="1" OR k$="2" OR k$="3" OR k$="4" THEN GO TO 160
 118 PAUSE 1
 120 NEXT f
 122 NEXT c
 124 REM === Time ran out ===
 126 FOR x=1 TO 6
 128 BORDER 2: BEEP 0.02,0
 130 BORDER 6: BEEP 0.02,5
 132 NEXT x
 134 BORDER 0
 136 PRINT AT 12,10; INK 2; BRIGHT 1;"BOOM!"
 138 BEEP 0.5,-10
 140 PAUSE 50
 142 GO TO 230
 160 REM === Wire cut ===
 162 LET g=VAL k$
 164 IF g=w THEN GO TO 200
 166 REM === Wrong wire ===
 168 FOR x=1 TO 6
 170 BORDER 2: BEEP 0.02,0
 172 BORDER 6: BEEP 0.02,5
 174 NEXT x
 176 BORDER 0
 178 LET y=12+g*2
 180 PRINT AT y,2; INK 2; BRIGHT 1;">"
 182 REM === Flash correct wire ===
 184 LET y=12+w*2
 186 PRINT AT y,2; INK 4; BRIGHT 1; FLASH 1;">"
 188 PRINT AT 12,10; INK 2; BRIGHT 1;"BOOM!"
 190 BEEP 0.5,-10
 192 PAUSE 50
 194 GO TO 230
 200 REM === Defused! ===
 202 LET sc=sc+1
 204 BORDER 4
 206 LET y=12+g*2
 208 PRINT AT y,2; INK 4; BRIGHT 1;">"
 210 BEEP 0.1,12: BEEP 0.1,16: BEEP 0.2,19
 212 PRINT AT 12,10; INK 4; BRIGHT 1;"DEFUSED!"
 214 PAUSE 50
 216 BORDER 0
 230 REM === Next bomb ===
 232 NEXT b
 240 REM === Results ===
 242 CLS
 244 FOR i=0 TO 31
 246 PRINT AT 0,i; PAPER 2;" "
 248 NEXT i
 250 PRINT AT 0,8; PAPER 2; INK 7; BRIGHT 1;" BOMB DEFUSAL "
 252 PRINT AT 4,11; INK 7; BRIGHT 1;"RESULTS"
 254 REM === Animated score ===
 256 FOR i=0 TO sc
 258 PRINT AT 7,9; INK 5;"Defused: ";i;" of 5  "
 260 IF i<sc THEN BEEP 0.08,10+i*4
 262 NEXT i
 264 BEEP 0.2,24
 266 IF sc=5 THEN LET m$="Bomb expert!": INK 4: BRIGHT 1: GO TO 276
 268 IF sc>=3 THEN LET m$="Steady hands!": INK 6: BRIGHT 1: GO TO 276
 270 IF sc>=1 THEN LET m$="Needs practice!": INK 5: GO TO 276
 272 LET m$="Boom boom boom!": INK 2
 276 PRINT AT 10,(32-LEN m$)/2;m$
 278 BRIGHT 0
 280 PRINT AT 16,5; INK 7;"Press any key to exit"
 282 PAUSE 0
 284 BORDER 7: PAPER 7: INK 0: CLS
 286 STOP
5100 REM === Digit 0 ===
5101 DATA "1111"
5102 DATA "1..1"
5103 DATA "1..1"
5104 DATA "1..1"
5105 DATA "1111"
5110 REM === Digit 1 ===
5111 DATA ".11."
5112 DATA "..1."
5113 DATA "..1."
5114 DATA "..1."
5115 DATA ".11."
5120 REM === Digit 2 ===
5121 DATA "1111"
5122 DATA "...1"
5123 DATA "1111"
5124 DATA "1..."
5125 DATA "1111"
5130 REM === Digit 3 ===
5131 DATA "1111"
5132 DATA "...1"
5133 DATA ".111"
5134 DATA "...1"
5135 DATA "1111"
5140 REM === Digit 4 ===
5141 DATA "1..1"
5142 DATA "1..1"
5143 DATA "1111"
5144 DATA "...1"
5145 DATA "...1"
5150 REM === Digit 5 ===
5151 DATA "1111"
5152 DATA "1..."
5153 DATA "1111"
5154 DATA "...1"
5155 DATA "1111"
5160 REM === Digit 6 ===
5161 DATA "1111"
5162 DATA "1..."
5163 DATA "1111"
5164 DATA "1..1"
5165 DATA "1111"
5170 REM === Digit 7 ===
5171 DATA "1111"
5172 DATA "...1"
5173 DATA "..1."
5174 DATA ".1.."
5175 DATA ".1.."
5180 REM === Digit 8 ===
5181 DATA "1111"
5182 DATA "1..1"
5183 DATA "1111"
5184 DATA "1..1"
5185 DATA "1111"
5190 REM === Digit 9 ===
5191 DATA "1111"
5192 DATA "1..1"
5193 DATA "1111"
5194 DATA "...1"
5195 DATA "1111"
8000 REM === Draw digit f at dr,dc ===
8010 RESTORE 5100+f*10
8020 FOR r=0 TO 4
8030 READ a$
8040 FOR q=1 TO LEN a$
8050 IF a$(q TO q)="1" THEN PRINT AT dr+r,dc+q-1; PAPER pc;" "
8060 NEXT q
8070 NEXT r
8080 RETURN
8200 REM === Draw single digit centred ===
8210 FOR r=dr TO dr+4
8220 PRINT AT r,13;"      "
8230 NEXT r
8240 LET dc=14: LET f=v: GO SUB 8000
8250 RETURN
