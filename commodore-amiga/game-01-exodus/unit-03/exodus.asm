;──────────────────────────────────────────────────────────────
; EXODUS - A terrain puzzle for the Commodore Amiga
; Unit 3: Draw Terrain
;
; Filled rectangles build a landscape in the bitplane.
; A subroutine (BSR/RTS) draws byte-aligned rectangles.
; Three calls create ground, a cliff, and a platform.
;──────────────────────────────────────────────────────────────

;══════════════════════════════════════════════════════════════
; TWEAKABLE VALUES
;══════════════════════════════════════════════════════════════

; Colours ($0RGB)
COLOUR_SKY_DEEP     equ $0016
COLOUR_SKY_UPPER    equ $0038
COLOUR_SKY_MID      equ $005B
COLOUR_SKY_LOWER    equ $007D
COLOUR_SKY_HORIZON  equ $009E

COLOUR_TERRAIN      equ $0741       ; Earth brown

; Terrain rectangles (x and width must be multiples of 8)
; Low ground (left side)
GROUND_L_X          equ 0
GROUND_L_Y          equ 152
GROUND_L_W          equ 128
GROUND_L_H          equ 104         ; Extends to bottom (152+104=256)

; High ground (right side — forms a cliff face)
GROUND_R_X          equ 128
GROUND_R_Y          equ 120
GROUND_R_W          equ 192
GROUND_R_H          equ 136         ; Extends to bottom (120+136=256)

; Floating platform (above the step)
PLATFORM_X          equ 24
PLATFORM_Y          equ 104
PLATFORM_W          equ 72
PLATFORM_H          equ 8

;══════════════════════════════════════════════════════════════
; DISPLAY CONSTANTS
;══════════════════════════════════════════════════════════════

SCREEN_WIDTH    equ 320
SCREEN_HEIGHT   equ 256
BYTES_PER_ROW   equ SCREEN_WIDTH/8      ; 40
BITPLANE_SIZE   equ BYTES_PER_ROW*SCREEN_HEIGHT  ; 10240

;══════════════════════════════════════════════════════════════
; HARDWARE REGISTERS
;══════════════════════════════════════════════════════════════

CUSTOM      equ $dff000
DMACON      equ $096
INTENA      equ $09a
INTREQ      equ $09c
COP1LC      equ $080
COPJMP1     equ $088
BPLCON0     equ $100
BPLCON1     equ $102
BPLCON2     equ $104
BPL1MOD     equ $108
DIWSTRT     equ $08e
DIWSTOP     equ $090
DDFSTRT     equ $092
DDFSTOP     equ $094
BPL1PTH     equ $0e0
BPL1PTL     equ $0e2
COLOR00     equ $180
COLOR01     equ $182
VPOSR       equ $004

;══════════════════════════════════════════════════════════════
; CODE (Chip RAM)
;══════════════════════════════════════════════════════════════

            section code,code_c

start:
            lea     CUSTOM,a5

            ; --- Take over the machine ---
            move.w  #$7fff,INTENA(a5)
            move.w  #$7fff,INTREQ(a5)
            move.w  #$7fff,DMACON(a5)

            ; --- Draw terrain into bitplane ---
            ; Bitplane starts as zeros (sky everywhere).
            ; Each draw_rect call fills a rectangle with 1s (terrain).

            ; Low ground (left side)
            move.w  #GROUND_L_X,d0
            move.w  #GROUND_L_Y,d1
            move.w  #GROUND_L_W,d2
            move.w  #GROUND_L_H,d3
            bsr     draw_rect

            ; High ground (right side — cliff face)
            move.w  #GROUND_R_X,d0
            move.w  #GROUND_R_Y,d1
            move.w  #GROUND_R_W,d2
            move.w  #GROUND_R_H,d3
            bsr     draw_rect

            ; Floating platform
            move.w  #PLATFORM_X,d0
            move.w  #PLATFORM_Y,d1
            move.w  #PLATFORM_W,d2
            move.w  #PLATFORM_H,d3
            bsr     draw_rect

            ; --- Patch bitplane pointer into Copper list ---
            lea     bitplane,a0
            move.l  a0,d0
            swap    d0
            lea     bpl1pth_val,a1
            move.w  d0,(a1)
            swap    d0
            lea     bpl1ptl_val,a1
            move.w  d0,(a1)

            ; --- Install Copper list ---
            lea     copperlist,a0
            move.l  a0,COP1LC(a5)
            move.w  d0,COPJMP1(a5)

            ; --- Enable DMA ---
            move.w  #$8380,DMACON(a5)   ; SET + DMAEN + COPEN + BPLEN

            ; === Main Loop ===
mainloop:
            move.l  #$1ff00,d1
.vbwait:
            move.l  VPOSR(a5),d0
            and.l   d1,d0
            bne.s   .vbwait

            btst    #6,$bfe001
            bne.s   mainloop

.halt:
            bra.s   .halt

;──────────────────────────────────────────────────────────────
; draw_rect — Fill a byte-aligned rectangle in the bitplane
;
; Input:  D0.W = x position (must be multiple of 8)
;         D1.W = y position
;         D2.W = width in pixels (must be multiple of 8)
;         D3.W = height in pixels
; Destroys: D0-D5, A0-A1
;──────────────────────────────────────────────────────────────
draw_rect:
            ; Calculate starting address: bitplane + y*40 + x/8
            lea     bitplane,a0
            mulu    #BYTES_PER_ROW,d1   ; D1 = y * 40 (32-bit result)
            add.l   d1,a0               ; A0 += y offset
            lsr.w   #3,d0               ; D0 = x / 8
            add.w   d0,a0               ; A0 += x offset

            ; Convert width from pixels to bytes
            lsr.w   #3,d2               ; D2 = width / 8

            ; Outer loop: rows
            subq.w  #1,d3               ; Height - 1 for DBRA
.row:
            move.w  d2,d5
            subq.w  #1,d5               ; Width_bytes - 1 for DBRA
            move.l  a0,a1               ; A1 = row write pointer
.col:
            move.b  #$ff,(a1)+          ; Fill 8 pixels (one byte)
            dbra    d5,.col

            add.w   #BYTES_PER_ROW,a0   ; Advance to next row
            dbra    d3,.row
            rts

;══════════════════════════════════════════════════════════════
; COPPER LIST
;══════════════════════════════════════════════════════════════

copperlist:
            ; --- Display window (standard PAL low-res) ---
            dc.w    DIWSTRT,$2c81
            dc.w    DIWSTOP,$2cc1
            dc.w    DDFSTRT,$0038
            dc.w    DDFSTOP,$00d0

            ; --- Bitplane configuration ---
            dc.w    BPLCON0,$1200       ; 1 bitplane + colour burst
            dc.w    BPLCON1,$0000
            dc.w    BPLCON2,$0000
            dc.w    BPL1MOD,$0000

            ; --- Bitplane pointer (patched by CPU) ---
            dc.w    BPL1PTH
bpl1pth_val:
            dc.w    $0000
            dc.w    BPL1PTL
bpl1ptl_val:
            dc.w    $0000

            ; --- Colours ---
            dc.w    COLOR00,COLOUR_SKY_DEEP
            dc.w    COLOR01,COLOUR_TERRAIN

            ; --- SKY GRADIENT ---
            dc.w    $3401,$fffe
            dc.w    COLOR00,COLOUR_SKY_UPPER

            dc.w    $4401,$fffe
            dc.w    COLOR00,COLOUR_SKY_MID

            dc.w    $5401,$fffe
            dc.w    COLOR00,COLOUR_SKY_LOWER

            dc.w    $6001,$fffe
            dc.w    COLOR00,COLOUR_SKY_HORIZON

            ; Black background below sky
            dc.w    $6801,$fffe
            dc.w    COLOR00,$0000

            ; --- END ---
            dc.w    $ffff,$fffe

;══════════════════════════════════════════════════════════════
; BITPLANE DATA (10,240 bytes — all zeros = sky)
;══════════════════════════════════════════════════════════════

            even
bitplane:
            dcb.b   BITPLANE_SIZE,0
