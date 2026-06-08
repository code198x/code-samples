; ============================================================================
; Meet the Machine (NES) - Unit 6: Colour Lives in a Palette
;
; The block's colour does not live in the tile. It lives in a separate little
; table - the palette - and the tile only points at it. Change the palette and
; the same tile changes colour, with no change to the screen's memory at all.
; ============================================================================

.segment "HEADER"
    .byte "NES", $1a
    .byte 2
    .byte 1
    .byte $00, $00

.segment "CODE"

reset:
    sei
    cld
    ldx #$40
    stx $4017
    ldx #$ff
    txs
    inx
    stx $2000
    stx $2001
    stx $4010
warm1:
    bit $2002
    bpl warm1
warm2:
    bit $2002
    bpl warm2

    ; --- the palette: a small table of colours the tiles point at ---
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006               ; aim at palette address $3F00
    lda #$21                ; $3F00 backdrop      = light blue
    sta $2007
    lda #$16                ; $3F01 palette-0 col 1 = red   (the block's colour)
    sta $2007
    lda #$27                ; $3F02 palette-0 col 2 = orange (unused here)
    sta $2007
    lda #$30                ; $3F03 palette-0 col 3 = white  (unused here)
    sta $2007

    ; --- the same block as last unit: tile 1 at the top-left cell ---
    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    lda #$01
    sta $2007

    ; --- square the picture up and turn it on ---
    bit $2002
    lda #$00
    sta $2006
    sta $2006
    sta $2005
    sta $2005
    lda #$1e
    sta $2001

forever:
    jmp forever

nmi:
    rti
irq:
    rti

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq

.segment "CHARS"
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 8192 - 32, $00
