  10 REM Letter Soup
  20 RANDOMIZE
  30 BORDER 0: PAPER 0: INK 7: CLS
  40 REM === Title screen ===
  50 LET r=0: LET t$="LETTER SOUP": INK 2: BRIGHT 1: GO SUB 3000: BRIGHT 0
  60 LET r=4: LET t$="Unscramble the letters": INK 5: GO SUB 3000
  70 LET r=5: LET t$="to find the hidden word!": INK 5: GO SUB 3000
  80 LET r=8: LET t$="10 rounds. Words get longer.": INK 6: GO SUB 3000
  90 LET r=12: LET t$="Short words are easy...": INK 4: GO SUB 3000
 100 LET r=13: LET t$="Long words are not.": INK 2: GO SUB 3000
 110 LET r=21: LET t$="Press any key to start": INK 7: FLASH 1: GO SUB 3000: FLASH 0
 120 PAUSE 0
 130 LET sc=0
 140 FOR n=1 TO 10
 150 READ w$
 160 REM === Scramble ===
 170 LET v$=w$
 180 LET s$=""
 190 IF LEN v$=0 THEN GO TO 230
 200 LET p=INT (RND*LEN v$)+1
 210 LET s$=s$+v$(p TO p)
 220 LET v$=v$(1 TO p-1)+v$(p+1 TO LEN v$)
 225 GO TO 190
 230 IF s$=w$ THEN GO TO 170
 240 REM === Display round ===
 250 CLS
 260 PRINT AT 0,1; INK 5;"Round ";n
 270 PRINT AT 0,22; INK 6;"Score: ";sc
 280 LET r=4: LET t$="Unscramble:": INK 5: GO SUB 3000
 290 REM === Draw letter tiles ===
 300 LET c=(32-LEN s$*2)/2
 310 FOR i=1 TO LEN s$
 320 PRINT AT 8,c+i*2-2; PAPER 1;" "
 330 PRINT AT 9,c+i*2-2; PAPER 1;" "
 340 NEXT i
 350 REM === Animated letter reveal ===
 360 FOR i=1 TO LEN s$
 370 PRINT AT 8,c+i*2-2; PAPER 1; INK 6; BRIGHT 1;s$(i TO i)
 380 BEEP 0.05,5+i*2
 390 NEXT i
 400 INPUT "Your guess? ";g$
 410 IF g$=w$ THEN GO TO 530
 420 REM === Wrong ===
 430 BORDER 2
 440 LET r=12: LET t$="Wrong!": INK 2: BRIGHT 1: GO SUB 3000: BRIGHT 0
 450 BEEP 0.3,-5
 460 BORDER 0
 470 FOR i=1 TO LEN w$
 480 PRINT AT 8,c+i*2-2; PAPER 1; INK 2; BRIGHT 1;w$(i TO i)
 490 BEEP 0.08,i*2
 500 NEXT i
 510 PAUSE 60
 520 GO TO 630
 530 REM === Correct ===
 540 LET sc=sc+1
 550 BORDER 4
 560 LET r=12: LET t$="Correct!": INK 4: BRIGHT 1: GO SUB 3000: BRIGHT 0
 570 FOR i=1 TO LEN w$
 580 PRINT AT 8,c+i*2-2; PAPER 4; INK 7; BRIGHT 1;w$(i TO i)
 590 BEEP 0.06,10+i*2
 600 NEXT i
 610 BEEP 0.1,24
 620 PAUSE 40
 630 BORDER 0
 640 NEXT n
 650 REM === Results ===
 660 CLS
 670 LET r=0: LET t$="LETTER SOUP": INK 2: BRIGHT 1: GO SUB 3000: BRIGHT 0
 680 LET r=5: LET t$="GAME OVER": INK 7: BRIGHT 1: GO SUB 3000: BRIGHT 0
 690 FOR i=0 TO sc
 700 LET r=8: LET t$="Score: "+STR$ i+" out of 10": INK 5: GO SUB 3000
 710 IF i<sc THEN BEEP 0.06,10+i*2
 720 NEXT i
 730 BEEP 0.2,24
 740 IF sc=10 THEN LET r=11: LET t$="Perfect!": INK 4: BRIGHT 1: GO SUB 3000
 750 IF sc>=7 THEN IF sc<10 THEN LET r=11: LET t$="Word wizard!": INK 6: GO SUB 3000
 760 IF sc>=4 THEN IF sc<7 THEN LET r=11: LET t$="Not bad!": INK 5: GO SUB 3000
 770 IF sc<4 THEN LET r=11: LET t$="Keep practising!": INK 3: GO SUB 3000
 780 BRIGHT 0
 790 STOP
3000 REM === Centre text t$ on row r ===
3010 PRINT AT r,(32-LEN t$)/2;t$
3020 RETURN
9000 DATA "cat","sun","bird","fish","lemon"
9010 DATA "planet","castle","trumpet","dinosaur","adventure"
