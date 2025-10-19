10 rem dungeon quest - tier 1 synthesis
20 print chr$(147):poke 53280,0:poke 53281,0
30 print "dungeon quest":print
40 print "find 3 treasures to escape!":print
50 print "press any key to start"
60 get a$:if a$="" then 60
70 print chr$(147)
80 x=1:y=1:hp=10:tr=0
90 gosub 1000
100 get a$:if a$="" then 100
110 if a$="w" and y>0 then y=y-1:gosub 1000
120 if a$="s" and y<2 then y=y+1:gosub 1000
130 if a$="a" and x>0 then x=x-1:gosub 1000
140 if a$="d" and x<2 then x=x+1:gosub 1000
150 if rnd(1)<.3 then gosub 2000
160 if hp<=0 then print chr$(147):print "you died!":end
170 if tr>=3 then print chr$(147):print "you escaped!":end
180 goto 100
1000 rem display room
1010 print chr$(147)
1020 print "room (";x;",";y;")"
1030 print "hp:";hp;" treasure:";tr;"/3"
1040 print
1050 rm=y*3+x
1060 if rm=0 then print "entrance. a draft blows."
1070 if rm=1 then print "dark passage. water drips."
1080 if rm=2 then print "altar room. candles flicker."
1090 if rm=3 then print "armoury. rusty weapons."
1100 if rm=4 then print "throne room. dusty seat."
1110 if rm=5 then print "treasury. gold glints!"
1120 if rm=6 then print "dungeon. chains rattle."
1130 if rm=7 then print "library. old books."
1140 if rm=8 then print "exit. freedom awaits!"
1150 print:print "wasd to move"
1160 return
2000 rem random encounter
2010 ev=int(rnd(1)*3)
2020 if ev=0 then gosub 3000
2030 if ev=1 then gosub 4000
2040 if ev=2 then gosub 5000
2050 return
3000 rem monster attack
3010 print chr$(147):print "monster attacks!"
3020 poke 54296,15:poke 54277,9:poke 54278,0
3030 poke 54273,50:poke 54276,17
3040 for i=1 to 10:next i:poke 54276,16
3050 dm=int(rnd(1)*3)+1
3060 hp=hp-dm
3070 print "you lose";dm;"hp!"
3080 for i=1 to 100:next i
3090 return
4000 rem find treasure
4010 print chr$(147):print "treasure found!"
4020 poke 54296,15:poke 54277,0:poke 54278,240
4030 poke 54273,100:poke 54276,129
4040 for i=1 to 20:next i:poke 54276,128
4050 tr=tr+1
4060 print "you have";tr;"treasures!"
4070 for i=1 to 100:next i
4080 return
5000 rem find potion
5010 print chr$(147):print "health potion!"
5020 poke 54296,15:poke 54277,8:poke 54278,8
5030 poke 54273,80:poke 54276,129
5040 for i=1 to 15:next i:poke 54276,128
5050 hp=hp+2
5060 print "you gain 2 hp!"
5070 for i=1 to 100:next i
5080 return
