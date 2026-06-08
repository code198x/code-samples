; ============================================================================
; Meet the Machine (NES) - Unit 7: Where the Shapes Come From
;
; Tile 1 has been a "solid block" only because of 16 bytes of CHR ROM. Those
; bytes are a tiny picture. Change them and tile 1 becomes whatever you draw -
; here, a heart. The screen write is unchanged; only the shape's bytes moved.
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

    ; --- palette (as last unit): backdrop + the shape's colour ---
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    lda #$21                ; $3F00 backdrop = light blue
    sta $2007
    lda #$16                ; $3F01 colour 1 = red (the shape)
    sta $2007
    lda #$27                ; $3F02 colour 2 = orange
    sta $2007
    lda #$30                ; $3F03 colour 3 = white
    sta $2007

    ; --- the same screen write as Units 5-6: tile 1 at the top-left cell ---
    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    lda #$01
    sta $2007

    ; --- square up and turn the picture on ---
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

; --- CHR ROM: the 8x8 shapes the PPU can draw ---
; Each tile is 16 bytes: 8 for the LOW plane, then 8 for the HIGH plane.
; A pixel's colour number = (high bit * 2) + (low bit). With the high plane
; all zero, every lit pixel is colour 1.
.segment "CHARS"
    ; Tile 0: blank
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    ; Tile 1: a heart - draw it row by row, a 1 bit is a lit pixel
    .byte %01100110         ; .##..##.
    .byte %11111111         ; ########
    .byte %11111111         ; ########
    .byte %11111111         ; ########
    .byte %01111110         ; .######.
    .byte %00111100         ; ..####..
    .byte %00011000         ; ...##...
    .byte %00000000         ; ........
    .byte $00,$00,$00,$00,$00,$00,$00,$00   ; high plane: all colour 1
    .res 8192 - 32, $00
