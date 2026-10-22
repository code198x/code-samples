!source "settings.inc"
* = $0600
start:
    pla                       ; consume USR's zero argument count
    cld
    lda #INITIAL
    jsr init_turn
    lda #STEP
    sta T+5
    lda #165
    sta T+7
    lda #90
    sta T+8
    jsr draw_counter
main:
    jsr wait_frame
    jsr service_tick
    lda $0284                 ; STRIG0, maintained by normal OS VBI
    eor #1
    and #1
    jsr sample_turn
    lda T+6
    beq main
    jsr draw_counter
    jmp main
!source "frame.inc"
!source "../../../../../cross-platform/patterns/framework/atari-turn-loops/turn.inc"
draw_counter:
    lda T
    lsr
    lsr
    lsr
    lsr
    ldy #5
    jsr digit
    lda T
    and #15
    iny
digit:
    tax
    lda screen_digits,x
    sta ($58),y               ; current SAVMSC, not a fixed display address
    rts
screen_digits:
    !byte 16,17,18,19,20,21,22,23,24,25,33,34,35,36,37,38
code_end:
!if code_end > T { !error "Caller overlaps its state" }
