10 print chr$(147)
20 poke 54277,9:poke 54278,0
30 poke 54296,15
40 for n=1 to 3
50 read hf,lf
60 poke 54273,hf:poke 54272,lf
70 poke 54276,17
80 for i=1 to 500:next i
90 poke 54276,16
100 for i=1 to 100:next i
110 next n
120 data 25,177,28,214,32,94
130 end
