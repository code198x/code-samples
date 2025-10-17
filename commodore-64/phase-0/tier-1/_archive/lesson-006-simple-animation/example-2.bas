10 x=0 : d=1
20 print chr$(147)
30 print chr$(19); : print spc(x); "*"
40 t0=ti : t1=t0+2
50 if ti<t1 then 50
60 x = x + d
70 if x=0 or x=38 then d = -d
80 goto 20
