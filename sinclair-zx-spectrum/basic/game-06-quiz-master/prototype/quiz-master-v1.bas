   1 REM Quiz Master v1
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 REM === Title screen ===
  12 FOR i=0 TO 31
  14 PRINT AT 0,i; PAPER 2;" "
  16 NEXT i
  18 PRINT AT 0,9; PAPER 2; INK 7; BRIGHT 1;" QUIZ MASTER "
  20 PRINT AT 4,4; INK 5;"Answer questions from four"
  22 PRINT AT 5,4; INK 5;"categories. Press A, B, C or D."
  24 PRINT AT 8,4; INK 6;"Science"
  26 PRINT AT 8,16; INK 3;"History"
  28 PRINT AT 10,4; INK 4;"Geography"
  30 PRINT AT 10,16; INK 5;"Entertainment"
  32 PRINT AT 14,4; INK 7;"8 questions. How many can"
  34 PRINT AT 15,4; INK 7;"you get right?"
  36 PRINT AT 21,5; INK 7; FLASH 1;"Press any key to start"; FLASH 0
  38 PAUSE 0
  40 DIM s(4)
  42 LET sc=0
  44 FOR n=1 TO 8
  46 READ p,q$,a$,b$,c$,d$,r$
  48 GO SUB 300
  50 REM === Wait for A/B/C/D ===
  52 LET k$=INKEY$
  54 IF k$<>"a" AND k$<>"b" AND k$<>"c" AND k$<>"d" THEN GO TO 52
  56 IF k$=r$ THEN GO TO 100
  58 REM === Wrong ===
  60 BORDER 2
  62 REM === Highlight chosen option in red ===
  64 LET y=0
  66 IF k$="a" THEN LET y=10
  68 IF k$="b" THEN LET y=12
  70 IF k$="c" THEN LET y=14
  72 IF k$="d" THEN LET y=16
  74 PRINT AT y,6; INK 2; BRIGHT 1;">> "
  76 REM === Show correct in green ===
  78 LET y=0
  80 IF r$="a" THEN LET y=10
  82 IF r$="b" THEN LET y=12
  84 IF r$="c" THEN LET y=14
  86 IF r$="d" THEN LET y=16
  88 PRINT AT y,6; INK 4; BRIGHT 1;">> "
  90 BEEP 0.3,-5
  92 BORDER 0
  94 PAUSE 75
  96 GO TO 140
 100 REM === Correct ===
 102 LET sc=sc+1
 104 LET s(p)=s(p)+1
 106 BORDER 4
 108 LET y=0
 110 IF k$="a" THEN LET y=10
 112 IF k$="b" THEN LET y=12
 114 IF k$="c" THEN LET y=14
 116 IF k$="d" THEN LET y=16
 118 PRINT AT y,6; INK 4; BRIGHT 1;">> "
 120 BEEP 0.1,12: BEEP 0.1,16: BEEP 0.15,19
 122 BORDER 0
 124 PAUSE 50
 140 NEXT n
 150 REM === Results ===
 152 CLS
 154 FOR i=0 TO 31
 156 PRINT AT 0,i; PAPER 2;" "
 158 NEXT i
 160 PRINT AT 0,9; PAPER 2; INK 7; BRIGHT 1;" QUIZ MASTER "
 162 PRINT AT 3,11; INK 7; BRIGHT 1;"RESULTS"
 164 REM === Animated score ===
 166 FOR i=0 TO sc
 168 PRINT AT 5,10; INK 5;"Score: ";i;" out of 8  "
 170 IF i<sc THEN BEEP 0.06,10+i*2
 172 NEXT i
 174 BEEP 0.2,24
 176 REM === Category breakdown ===
 178 PRINT AT 8,4; INK 6;"Science:       ";s(1)
 180 PRINT AT 9,4; INK 3;"History:       ";s(2)
 182 PRINT AT 10,4; INK 4;"Geography:     ";s(3)
 184 PRINT AT 11,4; INK 5;"Entertainment: ";s(4)
 186 REM === Rating ===
 188 IF sc=8 THEN LET m$="Genius!": INK 4: BRIGHT 1: GO TO 198
 190 IF sc>=6 THEN LET m$="Well done!": INK 6: BRIGHT 1: GO TO 198
 192 IF sc>=4 THEN LET m$="Not bad!": INK 5: GO TO 198
 194 LET m$="Keep studying!": INK 3
 198 PRINT AT 14,(32-LEN m$)/2;m$
 200 BRIGHT 0
 202 PRINT AT 18,5; INK 7;"Press any key to exit"
 204 PAUSE 0
 206 BORDER 7: PAPER 7: INK 0: CLS
 208 STOP
 300 REM === Draw question card ===
 302 CLS
 304 FOR i=0 TO 31
 306 PRINT AT 0,i; PAPER 2;" "
 308 NEXT i
 310 PRINT AT 0,1; PAPER 2; INK 7;"Q";n;" of 8"
 312 PRINT AT 0,22; PAPER 2; INK 6;"Score: ";sc
 314 REM === Category label ===
 316 LET c$="Science"
 318 IF p=2 THEN LET c$="History"
 320 IF p=3 THEN LET c$="Geography"
 322 IF p=4 THEN LET c$="Entertainment"
 324 LET ci=6
 326 IF p=2 THEN LET ci=3
 328 IF p=3 THEN LET ci=4
 330 IF p=4 THEN LET ci=5
 332 PRINT AT 3,(32-LEN c$)/2; INK ci; BRIGHT 1;c$
 334 REM === Question ===
 336 PRINT AT 5,4; INK 7;q$
 338 REM === Options with coloured borders ===
 340 FOR i=0 TO 3
 342 PRINT AT 10+i*2,4; INK 7; PAPER 0;"                        "
 344 NEXT i
 346 PRINT AT 10,6; INK 7;"A: ";a$
 348 PRINT AT 12,6; INK 7;"B: ";b$
 350 PRINT AT 14,6; INK 7;"C: ";c$
 352 PRINT AT 16,6; INK 7;"D: ";d$
 354 PRINT AT 20,4; INK 5;"Press A, B, C or D"
 356 RETURN
 500 DATA 1,"What planet is closest to the Sun?","Mercury","Venus","Earth","Mars","a"
 510 DATA 3,"What is the longest river in the world?","Amazon","Thames","Nile","Danube","c"
 520 DATA 2,"Who built the pyramids?","Romans","Egyptians","Vikings","Greeks","b"
 530 DATA 4,"What instrument has 88 keys?","Guitar","Drums","Violin","Piano","d"
 540 DATA 1,"How many legs does a spider have?","Six","Eight","Ten","Four","b"
 550 DATA 3,"What is the capital of France?","London","Berlin","Madrid","Paris","d"
 560 DATA 2,"In which year did World War 2 end?","1918","1939","1945","1960","c"
 570 DATA 4,"Who painted the Mona Lisa?","Picasso","Da Vinci","Van Gogh","Monet","b"
