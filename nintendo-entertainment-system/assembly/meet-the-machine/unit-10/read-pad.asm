; ============================================================================
; Meet the Machine (NES) - Unit 10: The Joypad in Your Hand
;
; You read the controller yourself: strobe it to latch the buttons, then read
; them out one at a time from $4016. Here we read button A and paint the screen
; green while it is held, red while it is not - re-reading every pass.
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

read:
    ; --- strobe the controller: a 1 then a 0 latches the current buttons ---
    lda #$01
    sta $4016
    lda #$00
    sta $4016

    ; --- the first read after a strobe is button A, in bit 0 ---
    lda $4016
    and #$01                ; keep only bit 0
    beq not_pressed         ; 0 = A is up (on the NES, pressed reads as 1)
    lda #$2a                ; A held: green
    jmp show
not_pressed:
    lda #$16                ; A up: red
show:
    ; --- paint the backdrop with the colour now in A ---
    sta $00
    bit $2002
    lda #$3f
    sta $2006
    lda #$00
    sta $2006
    lda $00
    sta $2007
    bit $2002               ; re-aim at $3F00 so the backdrop displays it
    lda #$3f
    sta $2006
    lda #$00
    sta $2006

    jmp read                ; read the pad again, forever

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
