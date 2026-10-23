!source "settings.inc"
OSWRCH = $ffd2
* = $0801
    !word basic_end
    !word 10
    !byte $9e
    !text "2064"
    !byte 0
basic_end:
    !word 0
    !fill $0810-*,0
start:
    cld
    cli
    jsr $ffcc
    lda #147
    jsr OSWRCH
    lda #0
    ldx #7
clear_clock:
    sta CLOCK,x
    dex
    bpl clear_clock
    lda #0
    ldx #9
clear_state:
    sta STATE,x
    dex
    bpl clear_state
    lda #165
    sta DEADLINE+12
    lda #90
    sta DEADLINE+13
    lda #<DURATION
    sta DEADLINE
    lda #>DURATION
    sta DEADLINE+1
    jsr sample_clock
    jsr deadline_init
    jsr display
next_sample:
    jsr sample_clock
    jsr deadline_poll
    jsr sample_keys
    jsr dispatch
    lda STATE+7
    beq next_sample
    jsr display
    lda #0
    sta STATE+7
    jmp next_sample
commit_turn:
    inc STATE+4
    bne turn_committed
    inc STATE+5
turn_committed:
    inc STATE+7
    rts
!source "clock.inc"
!source "input.inc"
!source "../../../../../bbc-micro/patterns/assembly/framework/turn-deadline/dispatch.inc"
!source "../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc"
; Draw only after changes, leaving the service loop free to poll.
display:
    lda #19
    jsr OSWRCH
    lda STATE+5
    jsr hex_byte
    lda STATE+4
    jsr hex_byte
    lda #32
    jsr OSWRCH
    lda STATE+6
    jsr hex_byte
    lda #32
    jsr OSWRCH
    lda DEADLINE+4
    jsr hex_byte
    rts
hex_byte:
    pha
    lsr
    lsr
    lsr
    lsr
    jsr hex_digit
    pla
    and #15
hex_digit:
    tax
    lda digits,x
    jmp OSWRCH
digits: !text "0123456789ABCDEF"
