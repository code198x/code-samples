10 CLS
20 DIM s(2)
30 FOR r = 1 TO 3
40 READ q$, a$, b$, c$, v
50 FOR p = 1 TO 2
60 CLS
70 PRINT "Round "; r; " of 3"
80 PRINT "Player "; p; " - Score: "; s(p)
90 PRINT
100 PRINT q$
110 PRINT
120 PRINT "  1. "; a$
130 PRINT "  2. "; b$
140 PRINT "  3. "; c$
150 PRINT
160 INPUT "Your answer (1-3)? "; g
170 IF g = v THEN INK 4: PRINT "Correct!": INK 0: LET s(p) = s(p) + 1: BEEP 0.2, 12
180 IF g <> v THEN INK 2: PRINT "Wrong!": INK 0: BEEP 0.3, -5
190 PAUSE 50
200 NEXT p
210 NEXT r
220 CLS
230 PRINT "Final Scores:"
240 PRINT
250 FOR p = 1 TO 2
260 PRINT "Player "; p; ": "; s(p)
270 NEXT p
280 PRINT
290 IF s(1) > s(2) THEN PRINT "Player 1 wins!"
300 IF s(2) > s(1) THEN PRINT "Player 2 wins!"
310 IF s(1) = s(2) THEN PRINT "It's a draw!"
400 DATA "What colour is the sky?","Green","Blue","Red",2
410 DATA "How many legs has a spider?","6","8","10",2
420 DATA "What is the capital of France?","Berlin","Madrid","Paris",3
