10 REM Hot and Cold
20 BORDER 7
30 PAPER 7
40 INK 0
50 CLS
60 PRINT AT 0, 10; "Hot and Cold"
70 PRINT AT 4, 2; "Find the hidden treasure!"
80 PRINT AT 6, 2; "Move with Q A O P"
90 PRINT AT 8, 2; "Watch the border colour:"
100 PRINT AT 10, 4; INK 0; "Black   = freezing"
110 PRINT AT 11, 4; INK 1; "Blue    = cold"
120 PRINT AT 12, 4; INK 3; "Magenta = cool"
130 PRINT AT 13, 4; INK 2; "Red     = warm"
140 PRINT AT 14, 4; INK 6; "Yellow  = hot"
150 PRINT AT 15, 4; INK 7; PAPER 0; " White   = on fire! "; PAPER 7
160 PRINT AT 18, 4; INK 0; "5 rounds, fewest moves wins"
170 PRINT AT 21, 6; "Press any key to start"
180 IF INKEY$ = "" THEN GO TO 180
190 LET s = 0
200 FOR g = 1 TO 5
210 CLS
220 PRINT AT 0, 0; "Round "; g; " of 5"
230 LET tr = INT (RND * 20) + 1
240 LET tc = INT (RND * 32)
250 LET r = 10
260 LET c = 15
270 LET m = 0
280 REM === game loop ===
290 BRIGHT 1
300 PRINT AT r, c; "+"
310 BRIGHT 0
320 LET d = ABS (r - tr) + ABS (c - tc)
330 IF d = 0 THEN GO TO 470
340 IF d <= 3 THEN BORDER 6
350 IF d > 3 AND d <= 7 THEN BORDER 2
360 IF d > 7 AND d <= 14 THEN BORDER 3
370 IF d > 14 AND d <= 24 THEN BORDER 1
380 IF d > 24 THEN BORDER 0
390 LET k$ = INKEY$
400 IF k$ = "" THEN GO TO 390
410 PRINT AT r, c; " "
420 IF k$ = "q" AND r > 1 THEN LET r = r - 1
430 IF k$ = "a" AND r < 21 THEN LET r = r + 1
440 IF k$ = "o" AND c > 0 THEN LET c = c - 1
450 IF k$ = "p" AND c < 31 THEN LET c = c + 1
460 LET m = m + 1
465 GO TO 290
470 REM === found it ===
480 BEEP 0.2, 12
490 BEEP 0.2, 16
500 BEEP 0.4, 19
510 PRINT AT r, c; "*"
520 BORDER 7
530 LET s = s + m
540 PRINT AT 23, 0; "Found in "; m; " moves!"
550 PAUSE 100
560 NEXT g
570 BORDER 7
580 PAPER 7
590 INK 0
600 CLS
610 PRINT AT 0, 10; "Hot and Cold"
620 PRINT
630 PRINT "Game over!"
640 PRINT
650 PRINT "Total moves: "; s
660 PRINT
670 IF s < 50 THEN PRINT "Amazing! You have a gift!"
680 IF s >= 50 AND s < 100 THEN PRINT "Well done!"
690 IF s >= 100 AND s < 200 THEN PRINT "Not bad, keep practising!"
700 IF s >= 200 THEN PRINT "The treasure was well hidden!"
