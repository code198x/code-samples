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
