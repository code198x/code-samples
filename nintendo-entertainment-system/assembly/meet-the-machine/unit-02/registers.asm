; ============================================================================
; Meet the Machine (NES) - Unit 2: LDA Is Not LET
;
; The harness is the same sealed box as Unit 1: it shows whatever colour you
; leave in A. This time the YOUR CODE block sends a value from A into X and
; back again, to prove a register copy is real.
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
    tax                     ; X = $2a   - copy A into X
    lda #$00                ; A = 0     - wipe A, so we must trust X
    txa                     ; A = $2a   - bring it back from X
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
