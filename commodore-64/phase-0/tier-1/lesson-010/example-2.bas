10 rem c major scale
20 poke 54296,15
30 poke 54277,0:poke 54278,240
40 for i=1 to 8
50 read fl,fh
60 poke 54272,fl:poke 54273,fh
70 poke 54276,17
80 for d=1 to 300:next d
90 poke 54276,16
100 for d=1 to 50:next d
110 next i
120 data 84,32,182,36,52,41,168,43
130 data 0,49,0,55,188,61,168,65
