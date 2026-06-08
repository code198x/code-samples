;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 14: Adding and Taking Away
;
; ADD and SUB are the whole of arithmetic. They work on a chosen size (.b/.w/.l)
; and leave the flags set for a branch to read. Here a colour is built by adding
; one channel and taking away another.
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
            move.w  #$0f00,d0           ; start with red
            add.w   #$000f,d0           ; add blue  -> $0f0f (magenta)
            sub.w   #$0f00,d0           ; take the red back -> $000f (blue)
            move.w  d0,colourval        ; show the result
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
