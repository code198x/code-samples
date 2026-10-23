dispatch:
    lda DEADLINE+5
    beq consider_action
    inc STATE+6
    lda #2
    sta STATE+7
    jsr commit_turn
    jmp deadline_start
consider_action:
    lda STATE+8
    and #1
    beq dispatch_done
    lda #1
    sta STATE+7
    jsr commit_turn
    lda DEADLINE+4
    beq dispatch_done
    jsr deadline_start
dispatch_done:
    rts
