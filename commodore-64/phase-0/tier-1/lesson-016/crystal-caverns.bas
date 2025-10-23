10 rem crystal caverns - tier 1 synthesis
20 print chr$(147):poke 53280,6:poke 53281,0
30 print "crystal caverns":print
40 print "the cavern is collapsing!"
50 print "find the crystal and escape!"
60 print:print "you have 2 minutes."
70 print:print "press any key"
80 get a$:if a$="" then 80
90 dim i$(3)
100 ii=0:r=1:ti$="000000":tl=120:hc=0
110 print chr$(147)
120 gosub 1000
130 print:print "time:";tl-int(ti/60)
140 print:print "n/s/e/w/get/inv"
150 input c$
160 if c$="n" or c$="s" or c$="e" or c$="w" then gosub 2000
170 if c$="get" then gosub 3000
180 if c$="inv" then gosub 4000
190 e=int(ti/60):re=tl-e
200 if re<=0 then gosub 6000
210 if r=1 and hc=1 then gosub 7000
220 goto 110
1000 rem display room
1010 if r=1 then print "entrance hall":print "passages lead n and e."
1020 if r=2 then print "dark tunnel":print "water drips. exits s,n."
1030 if r=3 then print "crystal chamber":print "a blue crystal glows! e,s."
1040 if r=4 then print "storage room":print "old crates. exits w,n."
1050 if r=5 then print "collapsed passage":print "rubble blocks the way. s."
1060 return
2000 rem movement
2010 if c$="n" and r=1 then r=2:return
2020 if c$="s" and r=2 then r=1:return
2030 if c$="n" and r=2 then r=3:return
2040 if c$="s" and r=3 then r=2:return
2050 if c$="e" and r=3 then r=4:return
2060 if c$="w" and r=4 then r=3:return
2070 if c$="e" and r=1 then r=4:return
2080 if c$="w" and r=4 then r=1:return
2090 if c$="n" and r=4 then r=5:return
2100 if c$="s" and r=5 then r=4:return
2110 print "you can't go that way!":for d=1 to 50:next d
2120 return
3000 rem get item
3010 if r=3 and hc=0 then ii=ii+1:i$(ii)="crystal":hc=1:gosub 5000:return
3020 print "nothing here to take.":for d=1 to 50:next d
3030 return
4000 rem inventory
4010 if ii=0 then print "inventory empty.":for d=1 to 50:next d:return
4020 print "carrying:":for i=1 to ii:print i$(i):next i
4030 for d=1 to 100:next d
4040 return
5000 rem pickup sound
5010 poke 54296,15:poke 54277,0:poke 54278,240
5020 poke 54272,100:poke 54273,30:poke 54276,65
5030 for d=1 to 50:next d:poke 54276,64
5040 print "got the crystal!"
5050 return
6000 rem time up
6010 print chr$(147):poke 53280,2
6020 print "the cavern collapses!"
6030 print:print "you are trapped forever."
6040 gosub 8000:end
7000 rem win
7010 print chr$(147):poke 53280,5
7020 print "you escaped!"
7030 print:print "the crystal is yours."
7040 print:print "time:";re;"seconds left"
7050 gosub 9000:end
8000 rem collapse sound
8010 poke 54296,15:poke 54277,9:poke 54278,0
8020 poke 54272,10:poke 54273,200:poke 54276,129
8030 for d=1 to 100:next d:poke 54276,128
8040 return
9000 rem victory sound
9010 poke 54296,15:poke 54277,0:poke 54278,240
9020 poke 54272,150:poke 54273,50:poke 54276,17
9030 for d=1 to 30:next d
9040 poke 54272,200:poke 54273,60
9050 for d=1 to 50:next d:poke 54276,16
9060 return
