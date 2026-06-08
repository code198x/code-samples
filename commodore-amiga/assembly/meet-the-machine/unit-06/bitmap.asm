;──────────────────────────────────────────────────────────────
; Meet the Machine (Amiga) - Unit 6: The Screen Is a Bitmap
;
; The picture is a map of bits in memory - a bitplane. Each bit is one pixel:
; 1 lights it, 0 leaves it dark. We point the display hardware at a stretch of
; Chip RAM, clear it, and set some bits - and those bits become a block on the
; glass. (The display set-up is harness; the YOUR CODE block lights the pixels.)
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

ROWBYTES    equ 40                  ; 320 pixels / 8 = 40 bytes per row
BPHEIGHT    equ 256
BPSIZE      equ ROWBYTES*BPHEIGHT   ; the whole bitplane: 10240 bytes

            section code,code_c

start:
            lea     CUSTOM,a5
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; --- clear the bitplane to all 0 (a blank screen) ---
            lea     bitplane,a0
            move.w  #(BPSIZE/4)-1,d0
.clr:       clr.l   (a0)+
            dbra    d0,.clr

            ; ----------------------------------------------- YOUR CODE START
            ; light a block of pixels: 32 wide (4 bytes), 24 rows tall
            lea     bitplane,a0
            move.w  #24-1,d1
.row:       move.l  #$ffffffff,(a0)     ; 32 bits = 32 lit pixels in this row
            lea     ROWBYTES(a0),a0     ; step to the next row down
            dbra    d1,.row
            ; ------------------------------------------------- YOUR CODE END

            ; --- tell the display where the bitplane lives (patch the Copper) ---
            lea     bitplane,a0
            move.l  a0,d0
            swap    d0
            move.w  d0,bplhi            ; high word of the address
            swap    d0
            move.w  d0,bpllo            ; low word of the address

            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)
            move.w  #$8380,DMACON(a5)   ; DMA on: master + bitplane + Copper

forever:
            bra.s   forever

;──────────────────────────────────────────────────────────────
; Copper list: set up a 320x256, one-bitplane display.
;──────────────────────────────────────────────────────────────
copperlist:
            dc.w    DIWSTRT,$2c81       ; display window start
            dc.w    DIWSTOP,$2cc1       ; display window stop
            dc.w    DDFSTRT,$0038       ; data fetch start
            dc.w    DDFSTOP,$00d0       ; data fetch stop
            dc.w    BPLCON0,$1200       ; one bitplane, colour on
            dc.w    BPL1MOD,$0000       ; no gap between rows
            dc.w    BPL1PTH
bplhi:      dc.w    $0000               ; bitplane address, high word (patched)
            dc.w    BPL1PTL
bpllo:      dc.w    $0000               ; bitplane address, low word (patched)
            dc.w    COLOR00,$0000       ; colour 0 (a 0 bit) = black
            dc.w    COLOR01,$0ff0       ; colour 1 (a 1 bit) = yellow
            dc.w    $ffff,$fffe

            section bss,bss_c           ; Chip RAM, zero-filled
bitplane:   ds.b    BPSIZE
