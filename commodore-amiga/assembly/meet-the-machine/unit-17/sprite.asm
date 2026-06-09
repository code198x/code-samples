;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 17: A Sprite of Your Own
;
; A sprite is a small picture the hardware draws OVER the background, on its own,
; wherever you tell it. No bitplane, no drawing into memory - you hand the chips
; a shape and a position and they put it on the glass. Here: one diamond.
;──────────────────────────────────────────────────────────────

CUSTOM      equ $dff000
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
DIWSTRT     equ $08e
DIWSTOP     equ $090
DDFSTRT     equ $092
DDFSTOP     equ $094
BPLCON0     equ $100
SPR0PTH     equ $120
SPR0PTL     equ $122
COLOR00     equ $180
COLOR17     equ $1a2            ; sprite 0, colour 1

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; --- tell the Copper where the sprite data lives (patch pointer) ---
            lea     sprite_data,a0
            move.l  a0,d0
            swap    d0
            move.w  d0,sprhi
            swap    d0
            move.w  d0,sprlo

            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)
            move.w  #$82a0,DMACON(a5)   ; DMA on: master + Copper + sprites

forever:
            bra.s   forever

;──────────────────────────────────────────────────────────────
; Sprite 0 data: two control words (position), then 16 lines of
; image (plane A, plane B per line), then a zero terminator.
; VSTART=$7c, HSTART=$100, VSTOP=$8c  ->  on screen around (128,80).
;──────────────────────────────────────────────────────────────
            even
sprite_data:
            dc.w    $7c80,$8c00         ; VSTART/HSTART, VSTOP/control
            ;          plane A          plane B
            dc.w    %0000000110000000,0 ; every set bit -> sprite colour 1
            dc.w    %0000001111000000,0
            dc.w    %0000011111100000,0
            dc.w    %0000111111110000,0
            dc.w    %0001111111111000,0
            dc.w    %0011111111111100,0
            dc.w    %0111111111111110,0
            dc.w    %1111111111111111,0
            dc.w    %1111111111111111,0
            dc.w    %0111111111111110,0
            dc.w    %0011111111111100,0
            dc.w    %0001111111111000,0
            dc.w    %0000111111110000,0
            dc.w    %0000011111100000,0
            dc.w    %0000001111000000,0
            dc.w    %0000000110000000,0
            dc.w    $0000,$0000         ; end of sprite

;──────────────────────────────────────────────────────────────
; Copper list: a blank background plus sprite 0 switched on.
;──────────────────────────────────────────────────────────────
copperlist:
            dc.w    DIWSTRT,$2c81
            dc.w    DIWSTOP,$2cc1
            dc.w    DDFSTRT,$0038
            dc.w    DDFSTOP,$00d0
            dc.w    BPLCON0,$0200       ; no bitplanes - just colour and sprites
            dc.w    SPR0PTH
sprhi:      dc.w    $0000               ; sprite data address, high (patched)
            dc.w    SPR0PTL
sprlo:      dc.w    $0000               ; sprite data address, low (patched)
            dc.w    COLOR00,$0008       ; background: deep blue
            dc.w    COLOR17,$0f80       ; sprite colour 1: orange
            dc.w    $ffff,$fffe
