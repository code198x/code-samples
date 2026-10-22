start:
    cld
    lda #0
    sta turn_count
    lda #1
    sta turn_step
redraw:
    jsr draw_count
read_command:
    jsr $ffe4
    cmp #0
    beq read_command
    cmp #81
    beq quit
    jsr apply_command
    jmp redraw
quit:
    rts
