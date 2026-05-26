  20 RANDOMIZE
 110 LET a = INT (RND * 13) + 1
 130 CLS
 150 PRINT "Number: "; a
 190 INPUT "Higher or lower (H/L)? "; g$
 200 LET b = INT (RND * 13) + 1
 210 PRINT "Next:   "; b
 230 IF g$ = "H" AND b > a THEN PRINT "Correct!"
 240 IF g$ = "L" AND b < a THEN PRINT "Correct!"
 260 IF g$ <> "H" AND g$ <> "L" THEN PRINT "Type H or L"
