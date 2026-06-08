; ============================================================================
; Meet the Machine (NES) - Unit 11: A Finger on the Boxes
;
; Instead of baking a value into the instruction, keep a table of values and
; point a finger at one. X is the finger: lda table,x reads the entry it rests
; on. Here a table of four colours; the finger picks one.
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
    ldx #3                  ; rest the finger on entry 3
    lda colours, x          ; read the colour the finger points at -> $28 yellow
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

; a table of four colours, sitting in ROM
colours:
    .byte $16, $2a, $12, $28    ; 0:red  1:green  2:blue  3:yellow

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
