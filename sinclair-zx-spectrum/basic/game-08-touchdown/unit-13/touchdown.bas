  10 BORDER 0: PAPER 0: INK 7: CLS
  20 DATA 24,24,60,60,126,126,90,24
  30 DATA 0,24,36,36,66,66,129,24
  40 DATA 66,36,0,24,0,36,66,0
  50 FOR u = 0 TO 2: FOR j = 0 TO 7: READ b: POKE USR CHR$ (144 + u) + j, b: NEXT j: NEXT u
  60 PRINT AT 5, 8; BRIGHT 1; "*** TOUCHDOWN ***"
  70 PRINT AT 8, 4; "Land the spacecraft safely."
  80 PRINT AT 10, 4; "Hold SPACE to fire thrusters."
  90 PRINT AT 11, 4; "Land slowly or you crash."
 100 PRINT AT 13, 4; "Fuel is limited. Use it wisely."
 110 PLOT 128, 118: DRAW -6, -12: DRAW 0, -16: DRAW -4, -6: DRAW 20, 0: DRAW -4, 6: DRAW 0, 16: DRAW -6, 12
 120 PRINT AT 18, 4; "Press any key to launch"
 130 PAUSE 0
 140 CLS
 150 FOR i = 1 TO 20: PLOT INT (RND * 256), INT (RND * 100) + 60: NEXT i
 160 INVERSE 1: PRINT AT 0, 0; " ALT:       SPD:       FUEL:   ": INVERSE 0
 170 INK 4: PRINT AT 21, 0;: FOR i = 1 TO 32: PRINT CHR$ 143;: NEXT i: INK 7
 180 LET alt = 100
 190 LET spd = 0
 200 LET fuel = 50
 210 LET spd = spd + 1
 220 IF INKEY$ = " " AND fuel > 0 THEN LET spd = spd - 2: LET fuel = fuel - 1: BEEP 0.02, 15
 230 IF spd < 0 THEN LET spd = 0
 240 LET prev = alt
 250 LET alt = alt - spd
 260 IF alt <= 0 THEN LET alt = 0
 270 PRINT AT 0, 6; alt; "  "
 280 PRINT AT 0, 19; spd; "  "
 290 PRINT AT 0, 27; fuel; "  "
 300 REM Fuel bar
 310 PRINT AT 2, 1;
 320 FOR j = 1 TO fuel: PRINT INK 4; CHR$ 143;: NEXT j
 330 FOR j = fuel + 1 TO 50: PRINT " ";: NEXT j
 340 IF alt > 70 THEN BORDER 1
 350 IF alt > 40 AND alt <= 70 THEN BORDER 5
 360 IF alt > 20 AND alt <= 40 THEN BORDER 6
 370 IF alt > 10 AND alt <= 20 THEN BORDER 2
 380 IF alt <= 10 THEN BORDER 7
 390 IF fuel < 10 AND fuel > 0 THEN BEEP 0.02, 30
 400 LET row = 20 - INT (alt / 5)
 410 IF row < 4 THEN LET row = 4
 420 IF row > 20 THEN LET row = 20
 430 LET prow = 20 - INT (prev / 5)
 440 IF prow < 4 THEN LET prow = 4
 450 IF prow > 20 THEN LET prow = 20
 460 PRINT AT prow, 15; " ": IF prow < 20 THEN PRINT AT prow + 1, 15; " "
 470 PRINT AT row, 15; CHR$ 144
 480 IF INKEY$ = " " AND fuel > 0 AND row < 20 THEN PRINT AT row + 1, 15; INK 6; CHR$ 145: INK 7
 490 PAUSE 3
 500 IF alt = 0 AND spd <= 2 THEN GO TO 600
 510 IF alt = 0 AND spd <= 5 THEN GO TO 640
 520 IF alt = 0 AND spd > 5 THEN GO TO 680
 530 GO TO 210
 600 BORDER 4
 610 BEEP 0.1, 10: BEEP 0.1, 15: BEEP 0.1, 20: BEEP 0.2, 24
 620 PRINT AT 10, 8; INK 4; "PERFECT LANDING!"
 630 GO TO 710
 640 BORDER 6
 650 BEEP 0.1, 10: BEEP 0.1, 12
 660 PRINT AT 10, 8; INK 6; "Bumpy but safe"
 670 GO TO 710
 680 BORDER 2
 690 BEEP 0.5, -10
 700 PRINT AT 10, 8; INK 2; "CRASH!"
 710 PRINT AT 14, 8; "Speed at landing: "; spd
 720 PRINT AT 15, 8; "Fuel remaining:  "; fuel
 730 PRINT AT 18, 4; "Press any key to play again"
 740 PAUSE 0
 750 GO TO 10

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
