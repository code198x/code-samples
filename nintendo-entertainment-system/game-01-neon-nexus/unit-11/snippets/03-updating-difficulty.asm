update_difficulty:
    ; Check if already at max
    lda difficulty
    cmp #MAX_DIFFICULTY
    bcs @done               ; already at max

    ; Check score thresholds
    ; difficulty 1 at 50, 2 at 100, 3 at 150, etc.
    ; Target score = (difficulty + 1) * 50
    lda difficulty
    clc
    adc #1                  ; target level
    tax                     ; save in X

    ; Multiply by 50: (X * 50) = (X * 32) + (X * 16) + (X * 2)
    ; Or simpler: compare score against lookup table
    lda score
    cmp difficulty_thresholds, x
    bcc @done               ; score below threshold

    ; Score reached threshold - increase difficulty
    inc difficulty

@done:
    rts

; Score thresholds for each difficulty level
difficulty_thresholds:
    .byte 0                 ; level 0 (start)
    .byte 50                ; level 1
    .byte 100               ; level 2
    .byte 150               ; level 3
    .byte 200               ; level 4
    .byte 250               ; level 5 (max)
