  10 BORDER 0: PAPER 0: INK 7: CLS
  12 DATA 24,24,60,60,126,126,90,24
  14 DATA 0,24,36,36,66,66,129,24
  16 DATA 66,36,0,24,0,36,66,0
  18 FOR u = 0 TO 2: FOR j = 0 TO 7: READ b: POKE USR CHR$ (144 + u) + j, b: NEXT j: NEXT u
  20 PRINT AT 5, 8; BRIGHT 1; "*** TOUCHDOWN ***"
  30 PRINT AT 8, 4; "Land the spacecraft safely."
  40 PRINT AT 10, 4; "Hold SPACE to fire thrusters."
  50 PRINT AT 11, 4; "Land slowly or you crash."
  60 PRINT AT 13, 4; "Fuel is limited. Use it wisely."
  65 PLOT 128, 118: DRAW -6, -12: DRAW 0, -16: DRAW -4, -6: DRAW 20, 0: DRAW -4, 6: DRAW 0, 16: DRAW -6, 12
  70 PRINT AT 18, 4; "Press any key to launch"
  80 PAUSE 0
  90 CLS
  92 FOR i = 1 TO 20: PLOT INT (RND * 256), INT (RND * 100) + 60: NEXT i
  94 INVERSE 1: PRINT AT 0, 0; " ALT:       SPD:       FUEL:   ": INVERSE 0
  96 INK 4: PRINT AT 21, 0;: FOR i = 1 TO 32: PRINT CHR$ 143;: NEXT i: INK 7
 100 LET alt = 100
 110 LET spd = 0
 120 LET fuel = 50
 150 LET spd = spd + 1
 160 IF INKEY$ = " " AND fuel > 0 THEN LET spd = spd - 2: LET fuel = fuel - 1: BEEP 0.02, 15
 170 IF spd < 0 THEN LET spd = 0
 180 LET prev = alt
 190 LET alt = alt - spd
 200 IF alt <= 0 THEN LET alt = 0
 210 PRINT AT 0, 6; alt; "  "
 220 PRINT AT 0, 19; spd; "  "
 230 PRINT AT 0, 27; fuel; "  "
 240 REM Fuel bar
 250 PRINT AT 2, 1;
 260 FOR j = 1 TO fuel: PRINT INK 4; CHR$ 143;: NEXT j
 270 FOR j = fuel + 1 TO 50: PRINT " ";: NEXT j
 290 IF alt > 70 THEN BORDER 1
 300 IF alt > 40 AND alt <= 70 THEN BORDER 5
 310 IF alt > 20 AND alt <= 40 THEN BORDER 6
 320 IF alt > 10 AND alt <= 20 THEN BORDER 2
 330 IF alt <= 10 THEN BORDER 7
 340 IF fuel < 10 AND fuel > 0 THEN BEEP 0.02, 30
 360 LET row = 20 - INT (alt / 5)
 370 IF row < 4 THEN LET row = 4
 380 IF row > 20 THEN LET row = 20
 390 LET prow = 20 - INT (prev / 5)
 400 IF prow < 4 THEN LET prow = 4
 410 IF prow > 20 THEN LET prow = 20
 420 PRINT AT prow, 15; " ": IF prow < 20 THEN PRINT AT prow + 1, 15; " "
 430 PRINT AT row, 15; CHR$ 144
 432 IF INKEY$ = " " AND fuel > 0 AND row < 20 THEN PRINT AT row + 1, 15; INK 6; CHR$ 145: INK 7
 440 PAUSE 3
  450 IF alt = 0 AND spd <= 2 THEN GO TO 600
  460 IF alt = 0 AND spd <= 5 THEN GO TO 700
  470 IF alt = 0 AND spd > 5 THEN GO TO 800
 480 GO TO 150
 600 BORDER 4
 610 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20: BEEP 0.2, 24
 620 PRINT AT 10, 8; INK 4; "PERFECT LANDING!"
 630 GO TO 900
 700 BORDER 6
 710 BEEP 0.1, 10: BEEP 0.1, 12
 720 PRINT AT 10, 8; INK 6; "Bumpy but safe"
 730 GO TO 900
 800 BORDER 2
 810 BEEP 0.5, -10
 820 PRINT AT 10, 8; INK 2; "CRASH!"
 900 PRINT AT 14, 8; "Speed at landing: "; spd
 910 PRINT AT 15, 8; "Fuel remaining:  "; fuel
 920 PRINT AT 18, 4; "Press any key to play again"
 930 PAUSE 0
 940 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
