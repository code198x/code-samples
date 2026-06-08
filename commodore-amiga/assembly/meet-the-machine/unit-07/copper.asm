;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 7: Colour and the Copper
;
; The Copper is a tiny co-processor inside the Amiga that runs its own program
; in step with the video beam. It knows two instructions: WAIT (pause until the
; beam reaches a line) and MOVE (write a value to a chip register). With them it
; changes the background colour part-way down the screen - a gradient the CPU
; never lifts a finger to draw.
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
            move.w  #$8280,DMACON(a5)   ; DMA on: master + Copper

forever:
            bra.s   forever

;──────────────────────────────────────────────────────────────
; The Copper list. Two instructions only:
;   WAIT:  dc.w $VVHH,$fffe   - pause until the beam reaches line $VV
;   MOVE:  dc.w register,value - write 'value' to the register
;──────────────────────────────────────────────────────────────
copperlist:
            dc.w    BPLCON0,$0200       ; 0 bitplanes - just the background
            dc.w    COLOR00,$0008       ; from the top: deep blue

            ; ----------------------------------------------- YOUR CODE START
            dc.w    $3001,$fffe
            dc.w    COLOR00,$000f       ; line $30: blue
            dc.w    $5001,$fffe
            dc.w    COLOR00,$00af       ; line $50: cyan
            dc.w    $7001,$fffe
            dc.w    COLOR00,$00f8       ; line $70: green
            dc.w    $9001,$fffe
            dc.w    COLOR00,$0ff0       ; line $90: yellow
            dc.w    $b001,$fffe
            dc.w    COLOR00,$0f60       ; line $B0: orange
            dc.w    $d001,$fffe
            dc.w    COLOR00,$0f00       ; line $D0: red
            ; ------------------------------------------------- YOUR CODE END

            dc.w    $ffff,$fffe         ; end of the Copper list
