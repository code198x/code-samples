  10 BORDER 0: PAPER 0: INK 7: CLS
 130 CLS
 190 READ q$,a$,b$,c$,d$
 210 PRINT q$
 220 PRINT "1. ";a$
 230 PRINT "2. ";b$
 240 PRINT "3. ";c$
 250 PRINT "4. ";d$
 260 INPUT "Answer (1-4): ";g
 280 IF g <> 1 THEN PRINT "The answer was 1"
 290 IF g = 1 THEN PRINT "Correct!"
 610 DATA "How many legs does a spider have?","Eight","Six","Ten","Twelve"
