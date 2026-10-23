; Consume expiry before input; one overdue event, no catch-up turns.
dispatch:
    lda DEADLINE+5
    beq consider_input
    inc STATE+6
    jsr commit_turn
    jmp deadline_start
consider_input:
    lda STATE+8
    and #2
    beq consider_action
    lda DEADLINE+4
    beq enable_timer
    lda #0
    sta DEADLINE+4
    sta DEADLINE+2
    sta DEADLINE+3
    inc STATE+7
    rts
enable_timer:
    inc STATE+7
    jmp deadline_start
consider_action:
    lda STATE+8
    and #1
    beq dispatch_done
    jsr commit_turn
    lda DEADLINE+4
    beq dispatch_done
    jsr deadline_start
dispatch_done:
    rts
