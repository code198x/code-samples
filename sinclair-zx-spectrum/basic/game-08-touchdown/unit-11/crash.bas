  10 BORDER 0: PAPER 0: INK 7: CLS
  20 PRINT AT 5, 8; "*** TOUCHDOWN ***"
  30 PRINT AT 8, 4; "Land the spacecraft safely."
  40 PRINT AT 10, 4; "Hold SPACE to fire thrusters."
  50 PRINT AT 11, 4; "Land slowly or you crash."
  60 PRINT AT 13, 4; "Fuel is limited. Use it wisely."
  70 PRINT AT 18, 4; "Press any key to launch"
  80 PAUSE 0
  90 CLS
 100 LET alt = 100
 110 LET spd = 0
 120 LET fuel = 50
 130 PRINT AT 1, 1; "ALT:         SPD:         FUEL:"
 140 PRINT AT 21, 0; "================================"
 150 LET spd = spd + 1
 160 IF INKEY$ = " " AND fuel > 0 THEN LET spd = spd - 2: LET fuel = fuel - 1: BEEP 0.02, 15
 170 IF spd < 0 THEN LET spd = 0
 180 LET prev = alt
 190 LET alt = alt - spd
 200 IF alt <= 0 THEN LET alt = 0
 210 PRINT AT 1, 6; alt; "  "
 220 PRINT AT 1, 18; spd; "  "
 230 PRINT AT 1, 31; fuel; "  "
 240 REM Fuel bar
 250 PRINT AT 2, 1;
 260 FOR j = 1 TO fuel: PRINT INK 4; "*";: NEXT j
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
 420 PRINT AT prow, 15; " "
 430 PRINT AT row, 15; "V"
 440 PAUSE 3
 450 IF alt = 0 AND spd <= 2 THEN PRINT AT 10, 8; "PERFECT LANDING!": STOP
 460 IF alt = 0 AND spd <= 5 THEN PRINT AT 10, 8; "Bumpy but safe": STOP
  470 IF alt = 0 AND spd > 5 THEN GO TO 800
 480 GO TO 150
 800 BORDER 2
 810 BEEP 0.5, -10
 820 PRINT AT 10, 8; INK 2; "CRASH!"

9000 PRINT AT y, (32 - LEN a$) / 2; a$
9010 RETURN
