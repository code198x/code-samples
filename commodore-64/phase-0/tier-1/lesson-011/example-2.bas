10 rem laser sweep
20 print chr$(147)
30 print "laser sound effect"
40 print
50 print "frequency sweep demo"
60 print
70 print "press any key"
80 get k$:if k$="" then 80
90 gosub 1000
100 goto 70
1000 rem laser
1010 poke 54296,15
1015 poke 54277,0:poke 54278,240
1020 for f=255 to 50 step -5
1030 poke 54272,f:poke 54273,20
1040 poke 54276,33
1050 for d=1 to 10:next d
1060 next f
1070 poke 54276,32
1080 return
