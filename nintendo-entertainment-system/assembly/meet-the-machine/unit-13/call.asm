; ============================================================================
; Meet the Machine (NES) - Unit 13: Call, Return, and a Stack You Can See
;
; Package a job into a subroutine: write it once, jsr to it from anywhere, and
; rts back. draw_bar fills 8 cells from wherever the window is aimed. We aim,
; call, aim, call - two bars on two rows, one routine.
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

    ; --- palette: backdrop + the bars' colour ---
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    lda #$21                ; backdrop light blue
    sta $2007
    lda #$16                ; colour 1 red
    sta $2007

    ; --- first bar: aim at the top-left cell, then call ---
    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006
    jsr draw_bar

    ; --- second bar: aim at the start of row 2 ($2040), then call ---
    bit $2002
    lda #$20
    sta $2006
    lda #$40
    sta $2006
    jsr draw_bar

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

; --- draw_bar: pour 8 blocks from wherever the window is currently aimed ------
draw_bar:
    ldx #0
db_loop:
    lda #$01
    sta $2007
    inx
    cpx #8
    bne db_loop
    rts

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
