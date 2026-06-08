; ============================================================================
; Meet the Machine (NES) - Unit 5: The Screen Is Behind a Window
;
; Until now the harness painted a flat backdrop with rendering OFF. Here we
; open that hatch up and use it to write to the SCREEN's own memory - the
; nametable - then turn rendering ON so a tile actually shows.
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

    ; --- set up two palette colours: the backdrop, and the block's colour ---
    bit $2002               ; reset the address latch
    lda #$3f
    sta $2006
    lda #$00
    sta $2006               ; aim at palette address $3F00
    lda #$0f                ; $3F00 backdrop = black
    sta $2007
    lda #$30                ; $3F01 palette-0 colour 1 = white
    sta $2007

    ; --- write tile $01 (the solid block) to the top-left of the screen ---
    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006               ; aim at nametable address $2000 (top-left cell)
    lda #$01                ; tile $01 = the solid block in CHR
    sta $2007

    ; --- point the PPU back at the start and clear the scroll ---
    bit $2002
    lda #$00
    sta $2006
    sta $2006
    sta $2005
    sta $2005

    ; --- turn background rendering ON ---
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
    ; Tile 0: blank
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile 1: a solid block
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 8192 - 32, $00
