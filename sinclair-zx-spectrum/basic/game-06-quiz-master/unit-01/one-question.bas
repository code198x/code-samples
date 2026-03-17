   5 BORDER 0: PAPER 0: INK 7: CLS
  10 FOR i=0 TO 31
  12 PRINT AT 0,i; PAPER 2;" "
  14 NEXT i
  16 PRINT AT 0,9; PAPER 2; INK 7; BRIGHT 1;" QUIZ MASTER "
  20 PRINT AT 4,4; INK 7;"Closest planet to the Sun?"
  30 PRINT AT 8,6; INK 7;"A: Mercury"
  32 PRINT AT 10,6; INK 7;"B: Venus"
  34 PRINT AT 12,6; INK 7;"C: Earth"
  36 PRINT AT 14,6; INK 7;"D: Mars"
  40 PRINT AT 18,4;
  42 INPUT "Your answer (a/b/c/d)? ";k$
  44 IF k$="a" THEN PRINT AT 18,4; INK 4; BRIGHT 1;"Correct!": STOP
  46 PRINT AT 18,4; INK 2; BRIGHT 1;"Wrong! It was A"
