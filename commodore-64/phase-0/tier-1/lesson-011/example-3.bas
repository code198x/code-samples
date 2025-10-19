10 rem adsr envelope demo
20 poke 54296,15
30 print "1=fast attack  2=slow attack"
40 get a$:if a$="" then 40
50 if a$="1" then poke 54277,240:poke 54278,0
60 if a$="2" then poke 54277,0:poke 54278,240
70 poke 54273,25:poke 54272,177
80 poke 54276,33
90 for i=1 to 2000:next i
100 poke 54276,32
110 goto 30
