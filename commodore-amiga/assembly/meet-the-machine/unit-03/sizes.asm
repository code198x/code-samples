;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 3: Bytes, Words and Longs
;
; A 68000 value can be a byte (8 bits), a word (16), or a long (32). You choose
; the size on every MOVE. Here a 32-bit long holds a colour in its low word and
; junk in its high word; a word-sized move takes only the colour.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
BPLCON0     equ $100
COLOR00     equ $180

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)
            move.w  #$8280,DMACON(a5)

            ; ----------------------------------------------- YOUR CODE START
            move.l  #$12340fc0,d0       ; a LONG: $1234 (junk) in the high word,
            ;                             $0fc0 (an orange) in the low word
            move.w  d0,colourval        ; a WORD move: takes only the low 16 bits
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
