!source "settings.inc"
OSRDCH = $ffe3
OSWRCH = $fff4
* = $2800
start:
    cld
    lda #INITIAL
    jsr init_turn
    lda #STEP
    sta TURN+1
    jsr display
next_command:
    jsr OSRDCH
    jsr dispatch
    jsr display
    jmp next_command
!source "dispatch.inc"
!source "../../../../../cross-platform/patterns/framework/command-turns/6502.inc"
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
    lda TURN
    lsr
    lsr
    lsr
    lsr
    jsr hex_digit
    lda TURN
    and #15
hex_digit:
    tax
    lda digits,x
    jmp OSWRCH
label: !text "TURN "
    !byte 0
digits: !text "0123456789ABCDEF"
