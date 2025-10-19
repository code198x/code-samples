10 rem collision detection
20 print chr$(147):poke 53280,0:poke 53281,0
30 px=10:py=10:tx=15:ty=10
40 poke 1024+py*40+px,81:poke 55296+py*40+px,1
50 poke 1024+ty*40+tx,42:poke 55296+ty*40+tx,7
60 get a$:if a$="" then 60
70 if a$="q" then end
80 poke 1024+py*40+px,32
90 if a$="w" and py>0 then py=py-1
100 if a$="s" and py<24 then py=py+1
110 if a$="a" and px>0 then px=px-1
120 if a$="d" and px<39 then px=px+1
130 if px=tx and py=ty then print "hit!":for i=1 to 500:next i:end
140 poke 1024+py*40+px,81:poke 55296+py*40+px,1
150 goto 60
