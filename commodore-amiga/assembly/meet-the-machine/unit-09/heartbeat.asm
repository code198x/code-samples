;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 9: The Vertical Blank
;
; A game runs in step with the screen: 50 times a second the beam finishes a
; frame and returns to the top - the vertical blank. We wait for it each frame
; and do one small job: nudge the colour. The screen cycles all by itself.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
VPOSR       equ $004            ; beam position (line number in bits 8-16)
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
            ; --- wait for the top of the frame (the vertical blank) ---
.wait:      move.l  VPOSR(a5),d0
            and.l   #$1ff00,d0          ; isolate the beam's line number
            bne.s   .wait               ; loop until it's line 0

            ; --- one frame's work: nudge the colour ---
            add.w   #$0011,colourval

            ; --- wait for the beam to leave the top, so we bump once per frame ---
.leave:     move.l  VPOSR(a5),d0
            and.l   #$1ff00,d0
            beq.s   .leave

            bra.s   mainloop

copperlist:
            dc.w    BPLCON0,$0200
            dc.w    COLOR00
colourval:
            dc.w    $0000
            dc.w    $ffff,$fffe
