; ============================================================================
; Meet the Machine (NES) - Unit 8: Test, Then Jump
;
; There is no IF. You compare (which sets flags), then branch on a flag. The
; YOUR CODE block decides which colour ends up in A; the harness shows it.
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
    lda #5                  ; the value we'll ask about
    cmp #5                  ; compare it with 5 - sets the zero flag if equal
    beq equal               ; branch if equal
    lda #$16                ; not equal: red
    jmp show_it
equal:
    lda #$2a                ; equal: green
    ; ------------------------------------------------------------- YOUR CODE END

show_it:
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
