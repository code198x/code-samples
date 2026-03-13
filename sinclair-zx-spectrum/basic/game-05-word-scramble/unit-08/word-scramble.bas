10 REM Word Scramble
20 BORDER 1
30 INK 7
40 PAPER 1
50 CLS
60 PRINT AT 0, 8; "Word Scramble"
70 PRINT AT 4, 2; "Unscramble the letters to find"
80 PRINT AT 5, 2; "the hidden word!"
90 PRINT AT 8, 2; "You get 10 rounds."
100 PRINT AT 10, 2; "Type your answer, press ENTER"
110 PRINT AT 14, 2; "Short words are easy."
120 PRINT AT 15, 2; "Longer words are harder!"
130 PRINT AT 20, 5; "Press any key to start"
140 IF INKEY$ = "" THEN GO TO 140
150 BORDER 7
160 PAPER 7
170 INK 0
180 LET n = 0
190 FOR i = 1 TO 10
200 READ w$
210 LET t$ = w$
220 LET s$ = ""
230 IF LEN t$ = 0 THEN GO TO 280
240 LET p = INT (RND * LEN t$) + 1
250 LET s$ = s$ + t$(p)
260 LET t$ = t$(1 TO p - 1) + t$(p + 1 TO LEN t$)
270 GO TO 230
280 CLS
290 PRINT AT 0, 0; "Round "; i; " of 10"
300 PRINT AT 0, 22; "Score: "; n
310 PRINT AT 4, 2; "Unscramble this word:"
320 PRINT
330 INK 1
340 BRIGHT 1
350 PRINT AT 8, (32 - LEN s$) / 2; s$
360 BRIGHT 0
370 INK 0
380 PRINT AT 14, 2;
390 INPUT "Your guess? "; g$
400 IF g$ = w$ THEN GO TO 430
410 INK 2: PRINT AT 16, 2; "Wrong! It was "; w$: INK 0
420 BEEP 0.3, -5: GO TO 490
430 INK 4: PRINT AT 16, 2; "Correct!": INK 0
440 BEEP 0.15, 12
450 BEEP 0.15, 16
460 LET n = n + 1
490 PAUSE 75
500 NEXT i
510 BORDER 1
520 PAPER 1
530 INK 7
540 CLS
550 PRINT AT 4, 8; "Word Scramble"
560 PRINT AT 8, 10; "Game Over!"
570 PRINT AT 11, 8; "Score: "; n; " out of 10"
580 IF n = 10 THEN PRINT AT 14, 6; "Perfect! Incredible!": GO TO 640
590 IF n >= 7 THEN PRINT AT 14, 8; "Well done!": GO TO 640
600 IF n >= 4 THEN PRINT AT 14, 6; "Not bad, keep trying!": GO TO 640
610 PRINT AT 14, 4; "Keep practising your words!"
640 BEEP 0.5, 7
650 PRINT AT 20, 5; "Press any key to exit"
660 IF INKEY$ = "" THEN GO TO 660
670 BORDER 7
680 PAPER 7
690 INK 0
700 CLS
800 DATA "CAT","SUN","RED","FISH","STAR"
810 DATA "TREE","BLUE","LIGHT","DREAM","CASTLE"
