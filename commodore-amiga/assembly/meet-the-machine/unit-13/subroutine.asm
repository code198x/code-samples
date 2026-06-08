;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 13: Call, Return, and the Stack
;
; A subroutine is a job you write once and call from anywhere. BSR jumps to it
; and remembers the way back (on the stack); RTS returns. Here a small routine
; sets the colour, and the main code calls it.
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
            move.w  #$0ff0,d0           ; the colour to pass in (yellow)
            bsr     set_colour          ; call the subroutine, remember the way back
            ; ------------------------------------------------- YOUR CODE END

forever:
            bra.s   forever

; set_colour: write the colour in d0 to the Copper's slot, then return
set_colour:
            move.w  d0,colourval
            rts

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
