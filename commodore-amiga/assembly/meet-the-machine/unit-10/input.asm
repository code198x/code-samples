;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 10: Reading the Player
;
; The left mouse button lives in one bit of a chip register at $BFE001 - and it
; reads BACKWARDS: the bit is 0 while the button is held, 1 while it is up. We
; test that bit every frame and paint the screen to match.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
CIAAPRA     equ $bfe001         ; CIA-A port A: bit 6 = left mouse button
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

mainloop:
            ; --- test bit 6 of $BFE001 (the left mouse button) ---
            btst    #6,CIAAPRA
            bne.s   .up                 ; bit set (1) -> button is UP
            move.w  #$00f0,colourval    ; held: green
            bra.s   .next
.up:
            move.w  #$0f00,colourval    ; up: red
.next:
            bra.s   mainloop            ; read it again, every pass

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
