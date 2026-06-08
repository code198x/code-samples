; ============================================================================
; Meet the Machine (NES) - Unit 16: Bigger Than a Byte
;
; A byte stops at 255, but addresses run to 65535. The 6502 has no 16-bit
; registers, so a big number is two bytes - low and high - added low-first, and
; the carry is the bridge that climbs from one to the other.
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
    ; hold the 16-bit value $2FF0 as two bytes: low in $10, high in $11
    lda #$f0
    sta $10                 ; low byte
    lda #$2f
    sta $11                 ; high byte

    ; add $28 to it - 16 bits, low byte first
    clc
    lda $10
    adc #$28                ; $F0 + $28 = $118 -> keeps $18, SETS the carry
    sta $10
    lda $11
    adc #$00                ; high + 0 + the carry that just climbed up
    sta $11                 ; $2F becomes $30

    lda $11                 ; show the high byte: it was $2F, now $30 (white)
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
