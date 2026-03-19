  10 REM Simple Quiz — text version
  20 CLS
  30 LET sc=0
  40 FOR n=1 TO 4
  50 READ q$,a$,b$,c$,r$
  60 PRINT "Q";n;": ";q$
  70 PRINT "  A: ";a$
  80 PRINT "  B: ";b$
  90 PRINT "  C: ";c$
 100 GO SUB 200
 110 IF k$=r$ THEN LET sc=sc+1: PRINT "Correct!": GO TO 130
 120 PRINT "Wrong — answer was ";r$
 130 PRINT
 140 NEXT n
 150 PRINT "Score: ";sc;" out of 4"
 160 STOP
 200 REM === Get A/B/C ===
 210 LET k$=INKEY$
 220 IF k$<>"a" THEN IF k$<>"b" THEN IF k$<>"c" THEN GO TO 210
 230 PRINT "You pressed: ";k$
 240 RETURN
 250 DATA "Capital of France?","London","Paris","Berlin","b"
 260 DATA "Legs on a spider?","Six","Four","Eight","c"
 270 DATA "Biggest planet?","Mars","Jupiter","Saturn","b"
 280 DATA "H2O is?","Air","Oil","Water","c"
