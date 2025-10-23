10 rem sound fx demo
20 print chr$(147)
30 print "sound fx tester"
40 print
50 print "1=laser 2=explosion"
60 print "3=jump  4=coin"
70 print
80 get k$:if k$="" then 80
90 if k$="1" then gosub 1000
100 if k$="2" then gosub 2000
110 if k$="3" then gosub 3000
120 if k$="4" then gosub 4000
130 goto 80
1000 rem laser
1010 poke 54296,15
1015 poke 54277,0:poke 54278,240
1020 for f=255 to 50 step -5
1030 poke 54272,f:poke 54273,20
1040 poke 54276,33
1050 for d=1 to 10:next d
1060 next f
1070 poke 54276,32:return
2000 rem explosion
2010 poke 54296,15
2015 poke 54277,0:poke 54278,240
2017 poke 54272,255:poke 54273,255
2020 poke 54276,129
2025 for d=1 to 200:next d
2030 poke 54276,128:return
3000 rem jump
3010 poke 54296,15
3015 poke 54277,0:poke 54278,240
3020 for f=100 to 200 step 5
3030 poke 54272,f:poke 54273,10
3040 poke 54276,17
3050 for d=1 to 5:next d:next f
3060 poke 54276,16:return
4000 rem coin
4010 poke 54296,15
4015 poke 54277,0:poke 54278,240
4016 poke 54274,0:poke 54275,8
4020 poke 54272,100:poke 54273,30
4030 poke 54276,65
4040 for d=1 to 100:next d
4050 poke 54276,64:return
