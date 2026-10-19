; Original 9x7 board, coordinates x=0..8/y=0..6; no historical AI claim.
; Call choose_target, then choose_turn. Updates choice, not actor position.
; mode=0 targets player; nonzero targets two rows ahead, clamped to row 0.
; choice=0 Up,1 Left,2 Down,3 Right,$ff no legal turn.
; Squared-distance ties keep first in Up/Left/Down/Right order. Reversal allowed.
; Clobbers A/X/Y/flags and candidate temporaries. No hardware use; writable RAM.
choose_target:
    lda player_x
    sta target_x
    lda player_y
    ldx target_mode
    beq target_store
    sec
    sbc #2
    bcs target_store
    lda #0
target_store:
    sta target_y
    rts
choose_turn:
    lda #$ff
    sta best_score
    sta choice
    ldx #0
turn_candidate:
    lda actor_x
    clc
    adc turn_dx,x
    cmp #9
    bcs turn_next
    sta candidate_x
    lda actor_y
    clc
    adc turn_dy,x
    cmp #7
    bcs turn_next
    sta candidate_y
    tay
    lda row_offset,y
    clc
    adc candidate_x
    tay
    lda board,y
    bne turn_next
    lda candidate_x
    sec
    sbc target_x
    bcs turn_dx_positive
    eor #$ff
    clc
    adc #1
turn_dx_positive:
    tay
    lda squares,y
    sta candidate_score
    lda candidate_y
    sec
    sbc target_y
    bcs turn_dy_positive
    eor #$ff
    clc
    adc #1
turn_dy_positive:
    tay
    lda squares,y
    clc
    adc candidate_score
    cmp best_score
    bcs turn_next
    sta best_score
    stx choice
turn_next:
    inx
    cpx #4
    bne turn_candidate
    rts
; --- data
turn_dx: !byte 0,$ff,0,1
turn_dy: !byte $ff,0,1,0
row_offset: !byte 0,9,18,27,36,45,54
squares: !byte 0,1,4,9,16,25,36,49,64
board:
    !byte 1,1,1,1,1,1,1,1,1
    !byte 1,0,0,0,0,0,0,0,1
    !byte 1,0,0,0,1,1,1,0,1
    !byte 1,0,0,0,0,0,0,0,1
    !byte 1,0,1,1,1,0,0,0,1
    !byte 1,0,0,0,0,0,0,0,1
    !byte 1,1,1,1,1,1,1,1,1
actor_x: !byte 3
actor_y: !byte 3
player_x: !byte 5
player_y: !byte 3
target_mode: !byte 0
target_x: !byte 0
target_y: !byte 0
choice: !byte $ff
best_score: !byte $ff
candidate_x: !byte 0
candidate_y: !byte 0
candidate_score: !byte 0
