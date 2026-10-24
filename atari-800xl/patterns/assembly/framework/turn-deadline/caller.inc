TURN = $8300
EXPIRIES = $8301
KEY = $8302
HELD = $8303
DEADLINE = $8304
READY = $8310
GUARDS = $8312
start:
    pla                       ; stock BASIC USR zero-argument count, not a JSR helper
    php
    txa
    pha
    tya
    pha
    cld
    lda #0
    sta TURN
    sta EXPIRIES
    sta HELD
    lda #<DURATION
    sta DEADLINE
    lda #>DURATION
    sta DEADLINE+1
    jsr sample_clock
    jsr deadline_init
    lda #165
    sta GUARDS
    lda #90
    sta GUARDS+1
    lda #$fe
    sta READY
    lda #$ca
    sta READY+1
main:
    jsr sample_clock
    jsr deadline_poll
    jsr read_command
    sta KEY
    jsr dispatch
    jsr draw_state
    lda KEY
    cmp #3
    bne main
quit_release:
    jsr read_command
    lda HELD
    bne quit_release
    pla
    tay
    pla
    tax
    lda #0
    sta $d4                   ; USR returns unsigned integer zero through FR0
    sta $d5
    plp
    rts
draw_state:
    ldy #0
    lda TURN
    jsr draw_byte
    lda #0
    sta ($58),y
    iny
    lda EXPIRIES
    jsr draw_byte
    lda #0
    sta ($58),y
    iny
    lda DEADLINE+4
draw_byte:
    pha
    lsr
    lsr
    lsr
    lsr
    tax
    lda digits,x
    sta ($58),y
    iny
    pla
    and #15
    tax
    lda digits,x
    sta ($58),y
    iny
    rts
digits:
    !byte 16,17,18,19,20,21,22,23,24,25,33,34,35,36,37,38
