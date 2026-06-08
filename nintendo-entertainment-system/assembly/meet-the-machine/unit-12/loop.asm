; ============================================================================
; Meet the Machine (NES) - Unit 12: The Counted Loop
;
; Hand the repetition to the machine. The PPU's data port auto-steps to the
; next cell after every write, so a counted loop pouring tile 1 thirty-two
; times paints a whole row across the top of the screen.
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

    ; --- palette: backdrop + the row's colour ---
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    lda #$21                ; backdrop light blue
    sta $2007
    lda #$16                ; colour 1 red
    sta $2007

    ; --- aim the window at the top-left cell of the screen ---
    bit $2002
    lda #$20
    sta $2006
    lda #$00
    sta $2006

    ; --- the loop: write tile 1 to 32 cells. The port auto-steps each time. ---
    ldx #0                  ; the counter, and how many we have done
fill:
    lda #$01
    sta $2007               ; pour a block; the PPU steps to the next cell
    inx
    cpx #32                 ; a row is 32 cells wide - done them all?
    bne fill                ; if not, go round again

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

.segment "CHARS"
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .byte $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
    .byte $00,$00,$00,$00,$00,$00,$00,$00
    .res 8192 - 32, $00
