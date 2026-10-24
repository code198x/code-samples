; 1=joystick fire, 2=SELECT, 3=OPTION. All must release to re-arm.
; A/X/flags clobbered, Y preserved. No writes to hardware/OS input shadows.
read_command:
    lda $d01f
    and #4
    beq input_quit
    lda $d01f
    and #2
    beq input_toggle
    lda $0284
    beq input_action
    lda #0
    sta HELD
    rts
input_quit:
    ldx #3
    bne input_gate
input_toggle:
    ldx #2
    bne input_gate
input_action:
    ldx #1
input_gate:
    lda HELD
    bne input_none
    inc HELD
    txa
    rts
input_none:
    lda #0
    rts
