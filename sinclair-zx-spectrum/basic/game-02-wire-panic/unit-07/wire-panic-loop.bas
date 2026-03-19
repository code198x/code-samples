 500 REM === Countdown loop ===
 510 INK 6: LET g=t: GO SUB 2400
 520 REM === Timer bar, border, LEDs ===
 620 REM === Tick ===
 630 INK 7: BEEP 0.05,t
 640 PAUSE 40
 650 LET k$=INKEY$
 660 IF k$="1" THEN GO TO 800
 670 IF k$="2" THEN GO TO 800
 680 IF k$="3" THEN GO TO 800
 690 IF k$="4" THEN GO TO 800
 700 LET t=t-1
 710 IF t<0 THEN GO TO 900
 720 GO TO 500
