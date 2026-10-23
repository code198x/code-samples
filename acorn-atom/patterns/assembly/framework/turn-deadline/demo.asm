!source "settings.inc"
OSWRCH = $fff4
* = $6000
start:
    cld
    lda #0
    ldx #9
clear_state:
    sta STATE,x
    dex
    bpl clear_state
    lda #<DURATION
    sta DEADLINE
    lda #>DURATION
    sta DEADLINE+1
    lda #<INITIAL_CLOCK
    sta STATE
    lda #>INITIAL_CLOCK
    sta STATE+1
    lda $b002
    and #128
    sta STATE+2
    lda STATE
    ldx STATE+1
    jsr deadline_init
    jsr display
next_sample:
    jsr sample_clock
    jsr deadline_poll
    jsr sample_keys
    lda DEADLINE+5
    bne no_toggle
    lda STATE+8
    and #2
    beq no_toggle
    lda DEADLINE+4
    beq enable_timer
    lda #0
    sta DEADLINE+4
    beq no_toggle
enable_timer:
    jsr deadline_start
no_toggle:
    jsr dispatch
    lda STATE+7
    beq next_sample
    jsr display
    lda #0
    sta STATE+7
    jmp next_sample
; Count observed falling edges of PC7. No wait; missed flybacks are lost.
sample_clock:
    lda $b002
    and #128
    cmp STATE+2
    beq clock_sampled
    sta STATE+2
    cmp #0
    bne clock_sampled
    inc STATE
    bne clock_sampled
    inc STATE+1
clock_sampled:
    lda STATE
    ldx STATE+1
    rts
; Space=bit 0, T=bit 1. Preserve the display-mode nibble and old selector.
sample_keys:
    lda $b000
    pha
    and #$f0
    ora #9
    sta $b000
    lda $b001
    eor #255
    and #1
    sta STATE+9
    lda $b000
    and #$f0
    ora #7
    sta $b000
    lda $b001
    and #32
    bne no_t
    lda STATE+9
    ora #2
    sta STATE+9
no_t:
    pla
    sta $b000
    lda STATE+3
    eor #255
    and STATE+9
    sta STATE+8
    lda STATE+9
    sta STATE+3
    rts
commit_turn:
    inc STATE+4
    bne turn_committed
    inc STATE+5
turn_committed:
    rts
!source "dispatch.inc"
!source "../../../../../cross-platform/patterns/framework/elapsed-deadline/6502.inc"
display:
    lda #12
    jsr OSWRCH
    ldx #0
print_label:
    lda label,x
    beq print_value
    jsr OSWRCH
    inx
    bne print_label
print_value:
    lda STATE+4
    lsr
    lsr
    lsr
    lsr
    jsr hex_digit
    lda STATE+4
    and #15
hex_digit:
    tax
    lda digits,x
    jmp OSWRCH
label: !text "SPACE:TURN T:TIMER TURN "
    !byte 0
digits: !text "0123456789ABCDEF"
