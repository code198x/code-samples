10 rem character mover
20 print chr$(147)
30 print "wasd character mover"
40 print
50 print "w=up s=down a=left d=right"
60 print
70 x=20:y=12:c=81
80 poke 1024+(y*40)+x,c
90 rem main loop
100 poke 1024+(y*40)+x,32
110 get k$
120 if k$="w" and y>0 then y=y-1
130 if k$="s" and y<24 then y=y+1
140 if k$="a" and x>0 then x=x-1
150 if k$="d" and x<39 then x=x+1
160 poke 1024+(y*40)+x,c
170 goto 100
