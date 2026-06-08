; ============================================================================
; Meet the Machine (NES) - Unit 4: A Street of Numbered Boxes
;
; Same sealed harness - it shows whatever colour you leave in A. This time the
; value takes a round trip out to a box in memory and back, to prove the box
; held it. The NES has only 2 KB of these boxes: $0000 to $07FF.
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

    ; ----------------------------------------------------------- YOUR CODE START
    lda #$2a                ; A = $2a (a green)
    sta $0300               ; store A into the box at $0300
    lda #$00                ; wipe A clean
    lda $0300               ; read the box back into A
    ; ------------------------------------------------------------- YOUR CODE END

    sta $00
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    lda $00
    sta $2007

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
