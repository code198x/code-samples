;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 19: The Machine Trusts You
;
; This program has a bug, on purpose. We MEANT to draw a small 24-row block,
; the way Unit 6 did. We wrote 256 instead - the height of the whole screen -
; and the machine drew exactly that. No warning, no error. It trusts the number.
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
BPL1MOD     equ $108
BPL1PTH     equ $0e0
BPL1PTL     equ $0e2
COLOR00     equ $180
COLOR01     equ $182

ROWBYTES    equ 40
BPHEIGHT    equ 256
BPSIZE      equ ROWBYTES*BPHEIGHT

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; --- clear the bitplane to all 0 ---
            lea     bitplane,a0
            move.w  #(BPSIZE/4)-1,d0
.clr:       clr.l   (a0)+
            dbra    d0,.clr

            ; ----------------------------------------------- YOUR CODE START
            ; We meant a 24-row block. We wrote 256. The machine obeys.
            lea     bitplane,a0
            move.w  #256-1,d1           ; <-- the bug: should have been 24-1
.row:       move.l  #$ffffffff,(a0)
            lea     ROWBYTES(a0),a0
            dbra    d1,.row
            ; ------------------------------------------------- YOUR CODE END

            ; --- point the display at the bitplane (patch the Copper) ---
            lea     bitplane,a0
            move.l  a0,d0
            swap    d0
            move.w  d0,bplhi
            swap    d0
            move.w  d0,bpllo

            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)
            move.w  #$8380,DMACON(a5)   ; DMA on: master + bitplane + Copper

forever:
            bra.s   forever

copperlist:
            dc.w    DIWSTRT,$2c81
            dc.w    DIWSTOP,$2cc1
            dc.w    DDFSTRT,$0038
            dc.w    DDFSTOP,$00d0
            dc.w    BPLCON0,$1200
            dc.w    BPL1MOD,$0000
            dc.w    BPL1PTH
bplhi:      dc.w    $0000
            dc.w    BPL1PTL
bpllo:      dc.w    $0000
            dc.w    COLOR00,$0000
            dc.w    COLOR01,$0ff0
            dc.w    $ffff,$fffe

            section bss,bss_c
bitplane:   ds.b    BPSIZE
