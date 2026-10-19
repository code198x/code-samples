5000 REM PARSE a$: s status, v verb, n noun
5010 LET s=0: LET v=0: LET n=0: LET w$="": LET o$=""
5020 IF pr<>1 THEN LET s=9: RETURN
5030 LET ll=LEN a$: IF ll>63 THEN LET s=2: RETURN
5040 REM Check the entire input before looking up words
5050 FOR p=1 TO ll
5060 LET tc=CODE a$(p): IF tc>=97 AND tc<=122 THEN LET tc=tc-32
5070 IF tc<>32 AND (tc<48 OR tc>90 OR (tc>57 AND tc<65)) THEN LET s=3: RETURN
5080 NEXT p
5090 LET wc=0: LET p=1
5100 IF p>ll THEN GO TO 5230
5110 IF a$(p)=" " THEN LET p=p+1: GO TO 5100
5120 LET wc=wc+1: IF wc>2 THEN LET s=4: RETURN
5130 LET t$=""
5140 IF p>ll THEN GO TO 5190
5150 IF a$(p)=" " THEN GO TO 5190
5160 LET tc=CODE a$(p): IF tc>=97 AND tc<=122 THEN LET tc=tc-32
5170 LET t$=t$+CHR$ tc: LET p=p+1
5180 GO TO 5140
5190 IF wc=1 THEN LET w$=t$
5200 IF wc=2 THEN LET o$=t$
5210 GO TO 5100
5230 IF wc=0 THEN LET s=1: RETURN
5240 LET iv=0: LET f=0: IF LEN w$>12 THEN LET s=5: RETURN
5250 FOR i=1 TO nv
5260 IF w$=d$(i,1 TO LEN w$) AND LEN w$=m(i) THEN LET iv=u(i): LET f=r(i)
5270 NEXT i
5280 IF iv=0 THEN LET s=5: RETURN
5290 IF wc=1 AND f=1 THEN LET s=7: RETURN
5300 IF wc=2 AND f=0 THEN LET s=8: RETURN
5310 LET ni=0: IF wc=1 THEN GO TO 5360
5315 IF LEN o$>12 THEN LET s=6: RETURN
5320 FOR i=1 TO nn
5330 IF o$=e$(i,1 TO LEN o$) AND LEN o$=h(i) THEN LET ni=z(i)
5340 NEXT i
5350 IF ni=0 THEN LET s=6: RETURN
5360 LET v=iv: LET n=ni: RETURN
6000 REM Initialise dictionary from DATA7000
6010 LET pr=0: LET s=10: RESTORE 7000: READ nv,nn
6020 IF nv<1 OR nv>32 OR nv<>INT nv OR nn<0 OR nn>32 OR nn<>INT nn THEN RETURN
6030 DIM d$(nv,12): DIM u(nv): DIM r(nv): DIM m(nv)
6040 DIM e$(nn+1,12): DIM z(nn+1): DIM h(nn+1)
6050 FOR i=1 TO nv
6060 READ t$,kk,jj: GO SUB 6500: IF ok=0 THEN RETURN
6070 IF kk<1 OR kk>255 OR kk<>INT kk OR jj<0 OR jj>2 OR jj<>INT jj THEN RETURN
6080 FOR b=1 TO i-1
6090 IF t$=d$(b,1 TO LEN t$) AND LEN t$=m(b) THEN RETURN
6100 IF kk=u(b) AND jj<>r(b) THEN RETURN
6110 NEXT b
6120 LET d$(i)=t$: LET u(i)=kk: LET r(i)=jj: LET m(i)=LEN t$
6130 NEXT i
6140 FOR i=1 TO nn
6150 READ t$,kk: GO SUB 6500: IF ok=0 THEN RETURN
6160 IF kk<1 OR kk>255 OR kk<>INT kk THEN RETURN
6170 FOR b=1 TO i-1
6180 IF t$=e$(b,1 TO LEN t$) AND LEN t$=h(b) THEN RETURN
6190 NEXT b
6200 LET e$(i)=t$: LET z(i)=kk: LET h(i)=LEN t$
6210 NEXT i
6220 LET pr=1: LET s=0: RETURN
6500 REM A dictionary word is1..12 uppercase letters/digits
6510 LET ok=0: IF LEN t$<1 OR LEN t$>12 THEN RETURN
6520 FOR q=1 TO LEN t$
6530 LET tc=CODE t$(q)
6540 IF tc<48 OR tc>90 OR (tc>57 AND tc<65) THEN RETURN
6550 NEXT q
6560 LET ok=1: RETURN
