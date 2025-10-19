10 rem catch falling objects
20 print chr$(147):poke 53280,0:poke 53281,0
30 px=20:py=23:sc=0:oy=0:ox=int(rnd(1)*40)
40 poke 1024+py*40+px,81:poke 55296+py*40+px,1
50 poke 1024+oy*40+ox,42:poke 55296+oy*40+ox,7
60 poke 1024+24*40,sc+48
70 get a$
80 if a$="a" and px>0 then poke 1024+py*40+px,32:px=px-1
90 if a$="d" and px<39 then poke 1024+py*40+px,32:px=px+1
100 poke 1024+py*40+px,81:poke 55296+py*40+px,1
110 for i=1 to 5:next i
120 poke 1024+oy*40+ox,32
130 oy=oy+1
140 if oy>24 then oy=0:ox=int(rnd(1)*40)
150 if oy=py and ox=px then sc=sc+1:oy=0:ox=int(rnd(1)*40)
160 poke 1024+oy*40+ox,42:poke 55296+oy*40+ox,7
170 poke 1024+24*40,sc+48
180 goto 70
