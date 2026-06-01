;──────────────────────────────────────────────────────────────
; EXODUS - A terrain puzzle for the Commodore Amiga
; Unit 2: Bitplane Display
;
; One bitplane turns colour bands into a real landscape.
; Where bits are 0: sky shows through (COLOR00).
; Where bits are 1: terrain appears (COLOR01).
;──────────────────────────────────────────────────────────────

;══════════════════════════════════════════════════════════════
; TWEAKABLE VALUES
;══════════════════════════════════════════════════════════════

; Colours ($0RGB)
COLOUR_SKY_DEEP     equ $0016       ; Deep navy
COLOUR_SKY_UPPER    equ $0038       ; Dark blue
COLOUR_SKY_MID      equ $005B       ; Medium blue
COLOUR_SKY_LOWER    equ $007D       ; Light blue
COLOUR_SKY_HORIZON  equ $009E       ; Pale horizon

COLOUR_TERRAIN      equ $0741       ; Earth brown (where bits = 1)

; Terrain starts at this bitplane row (try 40-120)
TERRAIN_START       equ 60

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

            ; --- Fill terrain into bitplane ---
            ; Sky area is already 0 (transparent — shows COLOR00)
            ; Fill from TERRAIN_START to bottom with $FF (solid — shows COLOR01)
            lea     bitplane,a0
            add.l   #TERRAIN_START*BYTES_PER_ROW,a0
            move.w  #(SCREEN_HEIGHT-TERRAIN_START)*BYTES_PER_ROW/4-1,d0
.fill:
            move.l  #$ffffffff,(a0)+
            dbra    d0,.fill

            ; --- Patch bitplane pointer into Copper list ---
            lea     bitplane,a0
            move.l  a0,d0
            swap    d0                  ; High word first
            lea     bpl1pth_val,a1
            move.w  d0,(a1)
            swap    d0                  ; Low word
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

;══════════════════════════════════════════════════════════════
; COPPER LIST
;══════════════════════════════════════════════════════════════

copperlist:
            ; --- Display window (standard PAL low-res) ---
            dc.w    DIWSTRT,$2c81       ; Window start: line $2C, column $81
            dc.w    DIWSTOP,$2cc1       ; Window stop: line $12C, column $C1
            dc.w    DDFSTRT,$0038       ; Data fetch start
            dc.w    DDFSTOP,$00d0       ; Data fetch stop

            ; --- Bitplane configuration ---
            dc.w    BPLCON0,$1200       ; 1 bitplane + colour burst
            dc.w    BPLCON1,$0000       ; No scroll
            dc.w    BPLCON2,$0000       ; Default priority
            dc.w    BPL1MOD,$0000       ; No modulo

            ; --- Bitplane pointer (patched by CPU at startup) ---
            dc.w    BPL1PTH
bpl1pth_val:
            dc.w    $0000               ; High word of bitplane address
            dc.w    BPL1PTL
bpl1ptl_val:
            dc.w    $0000               ; Low word of bitplane address

            ; --- Colours ---
            dc.w    COLOR00,COLOUR_SKY_DEEP     ; Background: sky
            dc.w    COLOR01,COLOUR_TERRAIN      ; Foreground: terrain

            ; --- SKY GRADIENT ---
            dc.w    $3401,$fffe
            dc.w    COLOR00,COLOUR_SKY_UPPER

            dc.w    $4401,$fffe
            dc.w    COLOR00,COLOUR_SKY_MID

            dc.w    $5401,$fffe
            dc.w    COLOR00,COLOUR_SKY_LOWER

            dc.w    $6001,$fffe
            dc.w    COLOR00,COLOUR_SKY_HORIZON

            ; Below the sky, set background to black
            ; (visible in overscan border where bitplane doesn't reach)
            dc.w    $6801,$fffe
            dc.w    COLOR00,$0000

            ; --- END ---
            dc.w    $ffff,$fffe

;══════════════════════════════════════════════════════════════
; BITPLANE DATA (10,240 bytes — Chip RAM)
;══════════════════════════════════════════════════════════════

            even
bitplane:
            dcb.b   BITPLANE_SIZE,0
