10 x=0 : d=1
20 print chr$(147)
30 print chr$(19); : print spc(x); "*"
40 for t=1 to 120: next t
50 x = x + d
60 if x=0 or x=38 then d = -d
70 goto 20
