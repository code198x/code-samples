10 rem state machine with sprite and lives
20 gs=0:li=0:sc=0:hi=0:x=160:y=120
25 rem load sprite data
30 for i=0 to 62:read b:poke 832+i,b:next
35 poke 2040,13:poke 53287,14
40 rem main loop
45 on gs+1 gosub 100,200,400
50 goto 45
100 rem title state
105 poke 53269,0
110 print chr$(147)
115 poke 53280,6:poke 53281,6
120 for i=0 to 9:read d:poke 1104+i,d:poke 55376+i,14:next
125 for i=1 to 100:next i
130 get k$:if k$<>"" then gs=1:li=3:sc=0:x=160:y=120:restore
135 return
200 rem play state
205 if sc=0 then print chr$(147):poke 53280,0:poke 53281,0:gosub 700:gosub 500:poke 53269,1
210 j=peek(56320) and 31:dx=0:dy=0
215 if (j and 1)=0 then dy=-2
220 if (j and 2)=0 then dy=2
225 if (j and 4)=0 then dx=-2
230 if (j and 8)=0 then dx=2
235 if (j and 16)=0 and li>0 then li=li-1:gosub 500
240 x=x+dx:y=y+dy
245 if x<24 then x=24
250 if x>320 then x=320
255 if y<50 then y=50
260 if y>229 then y=229
265 poke 53248,x:poke 53249,y
270 if x>255 then poke 53264,1 else poke 53264,0
275 sc=sc+1:if sc>9999 then sc=0
280 gosub 600
285 if li=0 then gs=2:restore
290 for d=1 to 2:next d
295 return
400 rem game over state
405 poke 53269,0
410 poke 53280,2:poke 53281,2
415 for i=0 to 8:read d:poke 1144+i,d:poke 55416+i,7:next
420 if sc>hi then hi=sc
425 for i=1 to 200:next i
430 gs=0:restore
435 return
500 rem draw lives and label
505 for h=0 to 2
510 if h<li then poke 1024+6+h,83:poke 55296+6+h,2
515 if h>=li then poke 1024+6+h,32:poke 55296+6+h,0
520 next
525 return
600 rem display score
605 s=sc
610 for i=3 to 0 step -1
615 poke 1024+40+i,48+(s-int(s/10)*10)
620 s=int(s/10)
625 next
630 return
700 rem draw labels
702 for i=0 to 62:read d:next
705 for i=0 to 4:read d:poke 1024+i,d:poke 55296+i,10:next
710 for i=0 to 4:read d:poke 1024+32+i,d:poke 55328+i,10:next
715 return
900 rem sprite data
905 data 0,24,0,0,60,0,0,126,0
910 data 0,255,0,1,255,128,3,255,192
915 data 7,255,224,15,255,240,31,255,248
920 data 3,255,192,3,255,192,3,255,192
925 data 3,255,192,3,255,192,3,255,192
930 data 1,255,128,0,255,0,0,126,0
935 data 0,60,0,0,24,0,0,0,0
940 rem label data (lives, score)
945 data 12,9,22,5,19
950 data 19,3,15,18,5
960 rem text data for title
965 data 16,18,5,19,19,32,6,9,18,5
970 rem text data for game over
975 data 7,1,13,5,32,15,22,5,18
