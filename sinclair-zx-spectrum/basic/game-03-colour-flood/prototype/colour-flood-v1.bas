   1 REM Colour Flood v1
   5 BORDER 0: PAPER 0: INK 7: CLS
  10 PRINT AT 3,5; INK 7; BRIGHT 1;"COLOUR FLOOD"
  20 PRINT AT 6,3; INK 5;"1 - Horizontal stripes"
  30 PRINT AT 7,3; INK 5;"2 - Vertical stripes"
  40 PRINT AT 8,3; INK 5;"3 - Checkerboard"
  50 PRINT AT 9,3; INK 5;"4 - Random splash"
  60 PRINT AT 10,3; INK 5;"5 - Diagonal"
  70 PRINT AT 11,3; INK 5;"6 - BRIGHT stripes"
  80 PRINT AT 14,5; INK 7;"Pick a pattern (1-6)"
  90 IF INKEY$="" THEN GO TO 90
  95 LET k$=INKEY$
 100 REM === Horizontal stripes ===
 110 IF k$<>"1" THEN GO TO 200
 120 CLS
 130 FOR r=0 TO 21
 140 FOR c=0 TO 31
 150 PRINT AT r,c; PAPER (r-INT (r/8)*8);" "
 160 NEXT c
 170 NEXT r
 180 GO TO 500
 200 REM === Vertical stripes ===
 210 IF k$<>"2" THEN GO TO 300
 220 CLS
 230 FOR r=0 TO 21
 240 FOR c=0 TO 31
 250 PRINT AT r,c; PAPER (c-INT (c/8)*8);" "
 260 NEXT c
 270 NEXT r
 280 GO TO 500
 300 REM === Checkerboard ===
 310 IF k$<>"3" THEN GO TO 400
 320 CLS
 330 FOR r=0 TO 21
 340 FOR c=0 TO 31
 350 IF INT ((r+c)/2)*2=(r+c) THEN PRINT AT r,c; PAPER 2;" "
 360 IF INT ((r+c)/2)*2<>(r+c) THEN PRINT AT r,c; PAPER 6;" "
 370 NEXT c
 380 NEXT r
 390 GO TO 500
 400 REM === Random splash ===
 410 IF k$<>"4" THEN GO TO 450
 420 CLS
 430 FOR r=0 TO 21
 440 FOR c=0 TO 31
 442 PRINT AT r,c; PAPER INT (RND*8);" "
 444 NEXT c
 446 NEXT r
 448 GO TO 500
 450 REM === Diagonal ===
 460 IF k$<>"5" THEN GO TO 480
 462 CLS
 464 FOR r=0 TO 21
 466 FOR c=0 TO 31
 468 PRINT AT r,c; PAPER ((r+c)-INT ((r+c)/8)*8);" "
 470 NEXT c
 472 NEXT r
 474 GO TO 500
 480 REM === BRIGHT stripes ===
 482 IF k$<>"6" THEN GO TO 90
 484 CLS
 486 FOR r=0 TO 21
 488 FOR c=0 TO 31
 490 PRINT AT r,c; PAPER (r-INT (r/8)*8); BRIGHT (INT (r/8)-INT (INT (r/8)/2)*2);" "
 492 NEXT c
 494 NEXT r
 500 REM === Wait then menu ===
 510 PRINT AT 22,3; INK 7;"Press any key for menu"
 520 IF INKEY$<>"" THEN GO TO 520
 530 IF INKEY$="" THEN GO TO 530
 540 GO TO 5
