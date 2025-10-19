10 rem move @ around screen
20 print chr$(147)
30 x=20:y=12
40 poke 1024+y*40+x,0
50 poke 55296+y*40+x,1
60 get a$
70 if a$="" then 60
80 if a$="q" then end
90 poke 1024+y*40+x,32
100 if a$="w" and y>0 then y=y-1
110 if a$="s" and y<24 then y=y+1
120 if a$="a" and x>0 then x=x-1
130 if a$="d" and x<39 then x=x+1
140 poke 1024+y*40+x,0
150 poke 55296+y*40+x,1
160 goto 60
