10 rem countdown timer game
20 print chr$(147):poke 53280,0:poke 53281,0
30 sc=0:ti$="000000":li=600
40 print "collect stars! 10 seconds!"
50 px=20:py=12:ox=int(rnd(1)*40):oy=int(rnd(1)*25)
60 poke 1024+py*40+px,81:poke 55296+py*40+px,1
70 poke 1024+oy*40+ox,42:poke 55296+oy*40+ox,7
80 get a$
90 if a$="w" and py>0 then poke 1024+py*40+px,32:py=py-1
100 if a$="s" and py<24 then poke 1024+py*40+px,32:py=py+1
110 if a$="a" and px>0 then poke 1024+py*40+px,32:px=px-1
120 if a$="d" and px<39 then poke 1024+py*40+px,32:px=px+1
130 poke 1024+py*40+px,81:poke 55296+py*40+px,1
140 if px=ox and py=oy then sc=sc+1:ox=int(rnd(1)*40):oy=int(rnd(1)*25)
150 poke 1024+oy*40+ox,42:poke 55296+oy*40+ox,7
160 re=li-ti
170 poke 1024,int(re/60)+48:poke 1024+1,sc+48
180 if re<=0 then print chr$(147):print "time up! score:";sc:end
190 goto 80
