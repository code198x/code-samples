; ============================================================================
; Meet the Machine (NES) - Unit 14: Adding and Taking Away
;
; Arithmetic at last. There is no "add 1 to A" - you go through adc, which
; always folds in the carry, so you clear it first. We compute a colour instead
; of loading it: start at $27, clear the carry, add one three times -> $2a.
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
    lda #$27                ; start at $27
    clc                     ; clear the carry BEFORE adding
    adc #1                  ; $28
    adc #1                  ; $29
    adc #1                  ; $2a  (a green) - computed, not loaded
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
