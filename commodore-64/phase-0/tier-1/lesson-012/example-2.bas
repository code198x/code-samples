10 rem smooth mover
20 print chr$(147)
30 print "smooth character mover"
40 print
50 print "w=up s=down a=left d=right"
60 print
70 x=20:y=12:c=81
80 poke 1024+(y*40)+x,c
90 poke 55296+(y*40)+x,7
100 rem main loop
110 poke 1024+(y*40)+x,32
120 get k$
130 if k$="w" and y>0 then y=y-1
140 if k$="s" and y<24 then y=y+1
150 if k$="a" and x>0 then x=x-1
160 if k$="d" and x<39 then x=x+1
170 poke 1024+(y*40)+x,c
180 poke 55296+(y*40)+x,7
190 for t=1 to 15:next t
200 goto 110
