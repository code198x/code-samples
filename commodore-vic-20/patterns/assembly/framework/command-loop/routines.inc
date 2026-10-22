; In: A=PETSCII command, turn_count/turn_step bytes.
; Out: turn_accepted=1 for A ($41), otherwise 0.
; Preserves X/Y. Clobbers A and processor flags; decimal mode must be clear.
apply_command:
    pha
    lda #0
    sta turn_accepted
    pla
    cmp #65
    bne command_done
    lda turn_count
    clc
    adc turn_step
    sta turn_count
    lda #1
    sta turn_accepted
command_done:
    rts
turn_count: !byte 0
turn_step: !byte 1
turn_accepted: !byte 0
