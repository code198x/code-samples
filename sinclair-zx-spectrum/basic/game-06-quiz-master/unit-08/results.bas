 152 CLS
 154 FOR i=0 TO 31
 156 PRINT AT 0,i; PAPER 2;" "
 158 NEXT i
 160 PRINT AT 0,9; PAPER 2; INK 7; BRIGHT 1;" QUIZ MASTER "
 162 PRINT AT 3,11; INK 7; BRIGHT 1;"RESULTS"
 166 FOR i=0 TO sc
 168 PRINT AT 5,10; INK 5;"Score: ";i;" out of 8  "
 170 IF i<sc THEN BEEP 0.06,10+i*2
 172 NEXT i
 174 BEEP 0.2,24
 178 PRINT AT 8,6; INK 6;"Science:        ";s(1)
 180 PRINT AT 9,6; INK 3;"History:        ";s(2)
 182 PRINT AT 10,6; INK 4;"Geography:      ";s(3)
 184 PRINT AT 11,6; INK 5;"Entertainment:  ";s(4)
 188 IF sc=8 THEN LET m$="Genius!": INK 4: BRIGHT 1: GO TO 198
 190 IF sc>=6 THEN LET m$="Well done!": INK 6: BRIGHT 1: GO TO 198
 192 IF sc>=4 THEN LET m$="Not bad!": INK 5: GO TO 198
 194 LET m$="Keep studying!": INK 3
 198 PRINT AT 14,(32-LEN m$)/2;m$
 200 BRIGHT 0
 202 PRINT AT 18,5; INK 7;"Press any key to exit"
 204 PAUSE 0
