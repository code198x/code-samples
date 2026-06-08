; ============================================================================
; Meet the Machine (NES) - Unit 17: The Machine Trusts You
;
; This one is wrong on purpose. It is the row-fill from Unit 12 with a single
; wrong number: cpx #255 where we meant cpx #32. The machine doesn't object -
; it fills exactly 255 cells, because 255 is the number we wrote.
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

    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    lda #$21                ; backdrop light blue
    sta $2007
    lda #$16                ; colour 1 red
    sta $2007

    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006

    ldx #0
fill:
    lda #$01
    sta $2007
    inx
    cpx #255                ; BUG: we meant 32 (one row)
    bne fill

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
