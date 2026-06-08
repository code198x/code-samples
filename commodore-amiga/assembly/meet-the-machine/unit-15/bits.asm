;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 15: Working With Bits
;
; AND, OR and EOR work on the bits inside a value, not its number. OR sets bits,
; AND clears the ones outside a mask, EOR flips them. Here OR builds a colour one
; channel at a time until every bit is on - white.
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
            move.w  #$0f00,d0           ; red bits on
            or.w    #$00f0,d0           ; OR in green -> $0ff0
            or.w    #$000f,d0           ; OR in blue  -> $0fff (white)
            move.w  d0,colourval        ; every colour bit set
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
