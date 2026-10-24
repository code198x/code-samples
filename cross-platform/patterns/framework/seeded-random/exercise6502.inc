; Independent caller, optional verification transport, not part of the helper.
; Caller reserves ptr/seed_index/checkpoint/reg_x/reg_y and OUTPUT[795].
exercise_rng:
    lda #<(OUTPUT+1)
    sta ptr
    lda #>(OUTPUT+1)
    sta ptr+1
    lda #165
    sta OUTPUT
    ldx #0
exercise_seeds:
    txa
    jsr rng_seed
    jsr store_byte
    jsr rng_next
    jsr store_byte
    inx
    bne exercise_seeds
    lda #1
    jsr rng_seed
    ldx #0
exercise_cycle:
    jsr rng_next
    jsr store_byte
    inx
    cpx #255
    bne exercise_cycle
    lda #$5a
    jsr rng_seed
    ldx #7
exercise_advance:
    jsr rng_next
    dex
    bne exercise_advance
    lda RNG_STATE
    sta checkpoint
    ldx #8
exercise_first:
    jsr rng_next
    jsr store_byte
    dex
    bne exercise_first
    lda checkpoint
    jsr rng_seed
    ldx #8
exercise_replay:
    jsr rng_next
    jsr store_byte
    dex
    bne exercise_replay
; Deliberately corrupt an already-initialized state. Next must expose the trap.
    lda #0
    sta RNG_STATE
    ldx #8
exercise_zero:
    jsr rng_next
    jsr store_byte
    dex
    bne exercise_zero
    ldx #$52
    ldy #$93
    lda #$5a
    jsr rng_seed
    jsr rng_next
    stx reg_x
    sty reg_y
    lda reg_x
    jsr store_byte
    lda reg_y
    jsr store_byte
    lda #239
    jsr store_byte
    rts
store_byte:
    ldy #0
    sta (ptr),y
    inc ptr
    bne store_done
    inc ptr+1
store_done:
    rts
